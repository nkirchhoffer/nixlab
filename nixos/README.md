# Homelab - Cluster K3s HA (3 nodes etcd)

## Architecture

| Node   | IP              | Role   |
|--------|-----------------|--------|
| knix-0 | 192.168.1.100   | server |
| knix-1 | 192.168.1.101   | server |
| knix-2 | 192.168.1.102   | server |

- 3 control plane nodes avec etcd embarque (quorum 2/3)
- Token partage dans chaque node config
- Deploiement via nixos-anywhere + nixos-rebuild

## Deploiement initial

### 1. Bootstrap du cluster (knix-0-init)

Utiliser la config `knix-0-init` qui active `clusterInit` pour creer le cluster etcd :

```bash
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./nodes/knix-0/hardware-configuration.nix \
  --flake .#knix-0-init \
  --target-host root@<IP_TEMPORAIRE>
```

### 2. Repasser knix-0 en config normale

Une fois le cluster initialise, rebuild sans `clusterInit` :

```bash
nixos-rebuild switch --flake .#knix-0 --target-host root@192.168.1.100
```

### 3. Installer knix-1 et knix-2

Creer les VMs dans Proxmox, puis :

```bash
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./nodes/knix-1/hardware-configuration.nix \
  --flake .#knix-1 \
  --target-host root@<IP_TEMPORAIRE>

nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./nodes/knix-2/hardware-configuration.nix \
  --flake .#knix-2 \
  --target-host root@<IP_TEMPORAIRE>
```

Les nodes rejoignent automatiquement le cluster grace au token partage.

### 4. Verifier le cluster

```bash
export KUBECONFIG=~/.config/homelab/nixos/k3s.yaml
kubectl get nodes
```

## Mise a jour des nodes

```bash
nixos-rebuild switch --flake .#knix-0 --target-host root@192.168.1.100
nixos-rebuild switch --flake .#knix-1 --target-host root@192.168.1.101
nixos-rebuild switch --flake .#knix-2 --target-host root@192.168.1.102
```

## Reinstallation d'une node

Si une node doit etre reinstallee from scratch :

```bash
# La node rejoint automatiquement via serverAddr (pointe vers une autre node)
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./nodes/knix-X/hardware-configuration.nix \
  --flake .#knix-X \
  --target-host root@<IP_TEMPORAIRE>
```

Pas besoin de `knix-0-init` : chaque node a un `serverAddr` qui pointe vers une autre node du cluster.

## Configs flake

| Config        | Usage                              |
|---------------|------------------------------------|
| `knix-0-init` | Premier deploy uniquement (bootstrap etcd) |
| `knix-0`      | Usage normal (rejoint via knix-1)  |
| `knix-1`      | Usage normal (rejoint via knix-0)  |
| `knix-2`      | Usage normal (rejoint via knix-0)  |

## Structure

```
nixos/
├── flake.nix
├── modules/
│   ├── common/apps.nix        # Paquets systeme communs
│   └── k3s/server.nix         # Firewall k3s (ports)
└── nodes/
    ├── knix-0/                 # Config complete k3s
    ├── knix-1/                 # Config complete k3s
    └── knix-2/                 # Config complete k3s
```
