# Kubernetes

This document is the complete procedure for the Kubernetes cluster managed by this repository. It covers control plane bootstrap, worker join, administrator access, and per-user `kubectl` access from `argus` and other machines.

## Cluster layout

| Host | Role | Address |
| --- | --- | --- |
| `argus` | control plane | `10.0.0.110` |
| `slab` | worker | `10.0.0.111` |
| `tiny-slab-alpha` | worker | `10.0.0.112` |
| `tiny-slab-beta` | worker | `10.0.0.113` |
| `tiny-slab-delta` | worker | `10.0.0.114` |

The cluster uses these settings:

- API server: `https://10.0.0.110:6443`
- Kubernetes: `v1.36.3` from the `nixos-26.05` input
- Cluster CIDR: `10.244.0.0/16`
- Service CIDR: `10.96.0.0/16`
- CNI: Flannel VXLAN
- DNS addon: CoreDNS
- Certificates: `easyCerts` with automatic renewal by `certmgr`
- Authorization: RBAC and Node

`argus` runs the control plane and does not schedule workload pods. The worker nodes run workloads.

## Source files

| File | Purpose |
| --- | --- |
| `common/kubernetes.nix` | Shared settings, node addresses, API address, CIDRs, DNS, firewall |
| `hosts/argus/kubernetes.nix` | Master role, advertise address, extra firewall ports |
| `hosts/<worker>/kubernetes.nix` | Node role |
| `hosts/argus/software.nix` | Installs `kubectl` on `argus` |

## Prerequisites

- NixOS is installed on all hosts from this flake.
- `argus` keeps the address `10.0.0.110`. The API certificate and the user kubeconfigs use this address. `/etc/hosts` also maps `argus` to `127.0.0.2`, so client configurations must use the IP address.
- DNS or `/etc/hosts` resolves the node names. `common/kubernetes.nix` writes the node entries to `/etc/hosts`.
- The firewall allows these ports:
  - TCP 6443 on `argus` for the API server.
  - TCP 8888 on `argus` for `cfssl`, which `certmgr` uses on every node during worker join.
  - TCP 10250 on all nodes for `kubelet`.
  - UDP 8285 and 8472 on all nodes for Flannel. The NixOS Flannel module opens these ports automatically.
- Time is synchronized. TLS certificate validation fails when the clocks differ.
- Use a `kubectl` version within one minor version of the cluster. The `nixos-26.05` input provides a matching version.
- Run the `nixos-rebuild` commands from the root of this repository.
- The user has SSH access to `argus` for copying the kubeconfig.
- Administrative commands on `argus` use `sudo`.

## Bootstrap the control plane

1. Apply the `argus` configuration:

   ```bash
   sudo nixos-rebuild switch --flake .#argus
   ```

2. Check the control plane services:

   ```bash
   systemctl status etcd kube-apiserver kube-controller-manager kube-scheduler \
     kubelet kube-proxy flannel certmgr kube-addon-manager
   ```

   All services must be `active`.

3. Check the API server:

   ```bash
   sudo kubectl --kubeconfig=/etc/kubernetes/cluster-admin.kubeconfig get nodes
   ```

   Expected output: `argus` is `Ready`. The master may also be marked unschedulable, which is correct for this cluster.

4. Check the system pods:

   ```bash
   sudo kubectl --kubeconfig=/etc/kubernetes/cluster-admin.kubeconfig get pods -A
   ```

   CoreDNS pods may stay `Pending` until a worker joins.

## Join worker nodes

1. Apply the worker configuration before joining. Replace `<host>` with the worker name:

   ```bash
   sudo nixos-rebuild switch --flake .#<host>
   ```

   The first switch installs `certmgr`, `kubelet`, `kube-proxy`, and Flannel. `kubelet` fails to start until the node receives certificates in step 3.

2. Get the join token on `argus`:

   ```bash
   sudo cat /var/lib/kubernetes/secrets/apitoken.secret
   ```

3. On the worker, run the join command with the exact 32-character token:

   ```bash
   echo 'TOKEN' | sudo nixos-kubernetes-node-join
   ```

   The command performs these steps:

   - Stores the token at `/var/lib/kubernetes/secrets/apitoken.secret` on the worker.
   - Restarts `certmgr`.
   - Waits for the node certificates.
   - Restarts `kubelet`, `kube-proxy`, and `flannel`.

4. Repeat steps 1 to 3 for each worker.

5. Verify the nodes on `argus`:

   ```bash
   sudo kubectl --kubeconfig=/etc/kubernetes/cluster-admin.kubeconfig get nodes -o wide
   ```

   All nodes must be `Ready`.

6. Verify the system pods:

   ```bash
   sudo kubectl --kubeconfig=/etc/kubernetes/cluster-admin.kubeconfig get pods -A
   ```

   CoreDNS pods must be `Running` after at least one worker joins.

## Administrator access on argus

The cluster creates the administrator kubeconfig at `/etc/kubernetes/cluster-admin.kubeconfig`. It references these files:

- `/var/lib/kubernetes/secrets/ca.pem`
- `/var/lib/kubernetes/secrets/cluster-admin.pem`
- `/var/lib/kubernetes/secrets/cluster-admin-key.pem`

The private key is `0600 root:kubernetes`. A normal user cannot read it. Use `sudo` for administrator commands:

```bash
sudo kubectl --kubeconfig=/etc/kubernetes/cluster-admin.kubeconfig get nodes
```

Do not change the key permissions. Create a separate user credential for daily use, as described in the next section.

## User kubectl access

The goal is a plain `kubectl` command with no `sudo`, no `--kubeconfig` flag, and no certificate file argument. The kubeconfig at `~/.kube/config` contains the CA data and the user token.

### 1. Create a ServiceAccount and RBAC binding

Run these commands on `argus` as administrator:

```bash
ADMIN=/etc/kubernetes/cluster-admin.kubeconfig

sudo kubectl --kubeconfig="$ADMIN" -n kube-system \
  create serviceaccount whatever-admin

sudo kubectl --kubeconfig="$ADMIN" \
  create clusterrolebinding whatever-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:whatever-admin
```

`whatever-admin` is a cluster-wide administrator identity. For read-only access, replace `cluster-admin` with `view`. For namespace-scoped access, create a `RoleBinding` instead of a `ClusterRoleBinding`.

### 2. Create a long-lived token secret

```bash
ADMIN=/etc/kubernetes/cluster-admin.kubeconfig

sudo kubectl --kubeconfig="$ADMIN" -n kube-system apply -f - <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: whatever-admin-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: whatever-admin
type: kubernetes.io/service-account-token
EOF
```

Wait until the controller fills the token:

```bash
ADMIN=/etc/kubernetes/cluster-admin.kubeconfig

until sudo kubectl --kubeconfig="$ADMIN" -n kube-system \
  get secret whatever-admin-token -o jsonpath='{.data.token}' | grep -q .; do
  sleep 1
done
```

This is a long-lived ServiceAccount token. It does not expire. It stays valid until the secret is deleted, the ServiceAccount is removed, or the service account signing key is regenerated. See [Security](#security).

### 3. Build the kubeconfig

Run these commands on `argus`, where `kubectl` is installed and the cluster CA is readable:

```bash
ADMIN=/etc/kubernetes/cluster-admin.kubeconfig

TOKEN=$(sudo kubectl --kubeconfig="$ADMIN" -n kube-system \
  get secret whatever-admin-token -o jsonpath='{.data.token}' | base64 -d)

install -d -m 700 "$HOME/.kube"

kubectl config set-cluster homelab \
  --server=https://10.0.0.110:6443 \
  --certificate-authority=/var/lib/kubernetes/secrets/ca.pem \
  --embed-certs=true \
  --kubeconfig="$HOME/.kube/config"

kubectl config set-credentials whatever-admin \
  --token="$TOKEN" \
  --kubeconfig="$HOME/.kube/config"

kubectl config set-context homelab \
  --cluster=homelab \
  --user=whatever-admin \
  --kubeconfig="$HOME/.kube/config"

kubectl config use-context homelab \
  --kubeconfig="$HOME/.kube/config"

chmod 600 "$HOME/.kube/config"
```

Important details:

- `kubectl config set-cluster` has no `--certificate-authority-data` option. Pass the CA file with `--certificate-authority` and set `--embed-certs=true` to store the CA data inside the kubeconfig.
- Use `https://10.0.0.110:6443`, not `https://argus:6443`. The API certificate includes `10.0.0.110`, `/etc/hosts` also maps `argus` to `127.0.0.2`, and the IP address does not depend on name resolution.
- Do not set `KUBECONFIG` to another file. Plain `kubectl` reads `~/.kube/config`. If `KUBECONFIG` is already set, unset it or point it to `$HOME/.kube/config`.

### 4. Verify

```bash
kubectl get nodes
kubectl get pods -A
kubectl cluster-info
kubectl auth can-i '*' '*' --all-namespaces
```

The last command must print `yes` for a cluster administrator.

### 5. Install kubectl on other machines

`argus` installs `kubectl` from `hosts/argus/software.nix`. On another NixOS machine, add it to the system or home packages.

For `hosaka`, add `kubectl` to the existing `home.packages` list in `home.nix`:

```nix
home.packages = with pkgs; [
  # existing packages
  kubectl
];
```

Then rebuild from the `nixos-hosaka` repository:

```bash
sudo nixos-rebuild switch --flake .#hosaka
```

For a one-off run without changing the system:

```bash
nix shell nixpkgs#kubectl -c kubectl version --client
```

### 6. Copy the kubeconfig to another machine

The user kubeconfig is self-contained. Run this on the destination machine, then set mode `0600`:

```bash
install -d -m 700 "$HOME/.kube"
scp argus:.kube/config "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"
```

Then verify:

```bash
kubectl get nodes
```

Do not copy `/etc/kubernetes/cluster-admin.kubeconfig` or `cluster-admin-key.pem`. The administrator kubeconfig depends on a root-only private key, and the certificate is renewed every 30 days. Copy the user kubeconfig instead.

## Optional declarative ServiceAccount setup

The imperative commands in [User kubectl access](#user-kubectl-access) create the ServiceAccount, binding, and token secret once. A fresh cluster install does not recreate them. To make these objects part of the NixOS configuration, add the following block as a separate top-level attribute in `hosts/argus/kubernetes.nix`:

```nix
services.kubernetes.addonManager.bootstrapAddons = {
  whatever-admin-sa = {
    apiVersion = "v1";
    kind = "ServiceAccount";
    metadata = {
      name = "whatever-admin";
      namespace = "kube-system";
    };
  };

  whatever-admin-crb = {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "ClusterRoleBinding";
    metadata.name = "whatever-admin";
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "ClusterRole";
      name = "cluster-admin";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "whatever-admin";
        namespace = "kube-system";
      }
    ];
  };

  whatever-admin-token = {
    apiVersion = "v1";
    kind = "Secret";
    metadata = {
      name = "whatever-admin-token";
      namespace = "kube-system";
      annotations."kubernetes.io/service-account.name" = "whatever-admin";
    };
    type = "kubernetes.io/service-account-token";
  };
};
```

Apply the change:

```bash
sudo nixos-rebuild switch --flake .#argus
```

If the objects do not appear, restart the addon manager:

```bash
sudo systemctl restart kube-addon-manager
```

Then extract the token as described in [User kubectl access](#user-kubectl-access). The token value is generated by Kubernetes and is never stored in this repository.

Use either the imperative commands or the declarative block. The declarative block makes the objects survive a fresh cluster install. The user kubeconfig remains a user file and is not managed by Nix.

## Credential rotation

### Rotate the token

1. Delete the token secret on `argus`:

   ```bash
   ADMIN=/etc/kubernetes/cluster-admin.kubeconfig

   sudo kubectl --kubeconfig="$ADMIN" -n kube-system \
     delete secret whatever-admin-token
   ```

2. Recreate the secret with the manifest from [User kubectl access](#user-kubectl-access). If the declarative block is used, restart the addon manager:

   ```bash
   sudo systemctl restart kube-addon-manager
   ```

3. Wait for the new token, then update the kubeconfig on every machine:

   ```bash
   ADMIN=/etc/kubernetes/cluster-admin.kubeconfig

   TOKEN=$(sudo kubectl --kubeconfig="$ADMIN" -n kube-system \
     get secret whatever-admin-token -o jsonpath='{.data.token}' | base64 -d)

   kubectl config set-credentials whatever-admin \
     --token="$TOKEN" \
     --kubeconfig="$HOME/.kube/config"

   chmod 600 "$HOME/.kube/config"
   ```

On machines other than `argus`, either copy the updated kubeconfig or run the same `set-credentials` command with the new token.

### Revoke access

```bash
ADMIN=/etc/kubernetes/cluster-admin.kubeconfig

sudo kubectl --kubeconfig="$ADMIN" delete clusterrolebinding whatever-admin
sudo kubectl --kubeconfig="$ADMIN" -n kube-system delete serviceaccount whatever-admin
sudo kubectl --kubeconfig="$ADMIN" -n kube-system delete secret whatever-admin-token
```

Deleting the ServiceAccount does not remove the token secret, because the secret has no owner reference. Delete both. Delete the local kubeconfigs after revocation.

If the declarative block is present in `hosts/argus/kubernetes.nix`, remove it before revoking. Otherwise the addon manager can recreate the ServiceAccount, binding, and token secret at the next start.

## Security

- The token has the permissions of its binding. In this guide it is `cluster-admin`. Treat it as a password.
- Keep `~/.kube/config` at mode `0600`. Do not commit it. Do not add it to the Nix store. Nix store files are world-readable.
- Use full-disk encryption on machines that store the kubeconfig.
- For least privilege, bind `view` or `edit`, or use a namespaced `RoleBinding`.
- The token does not expire, but it becomes invalid if the service account signing key is regenerated. `certmgr` renews the service account certificate without changing the private key, so normal certificate renewal does not invalidate the token. If expiring credentials are required, use the TokenRequest API:

  ```bash
  kubectl create token whatever-admin -n kube-system --duration=24h
  ```

  Update the kubeconfig with the new token and repeat before it expires. This does not provide a permanently working kubeconfig.

- User access does not use the generated client certificates. `certmgr` renews those certificates every 30 days, so a copied certificate and key will stop working.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `error: unknown flag: --certificate-authority-data` | `kubectl config set-cluster` takes a CA file path, not CA data | Use `--certificate-authority=<path>` and `--embed-certs=true` |
| `error: cluster "homelab" does not exist` | The context references a cluster entry that was never created | Run the full `set-cluster` command again |
| `The connection to the server localhost:8080 was refused` | No kubeconfig, or the kubeconfig has no cluster | Check `~/.kube/config` and unset `KUBECONFIG` if it points elsewhere |
| `Unauthorized` from the API server | The token is invalid, the signing key changed, or the ServiceAccount or token secret was deleted | Check the objects. Recreate the token secret and any missing objects, then rebuild the kubeconfig |
| `Forbidden` from the API server | The RBAC binding is missing or too narrow | Check `kubectl auth can-i --list`, then check the `ClusterRoleBinding` |
| `x509: certificate signed by unknown authority` | The kubeconfig does not contain the cluster CA | Rebuild the cluster entry with `--embed-certs=true` |
| `permission denied` for `cluster-admin-key.pem` | The administrator kubeconfig is being used as a normal user | Use the user kubeconfig in `~/.kube/config` |
| The token secret has no `data.token` | The annotation or type is wrong, or `kube-controller-manager` is not running | Check the annotation, the type, and `systemctl status kube-controller-manager` |
| A node stays `NotReady` | `kubelet`, Flannel, or the firewall is failing | Run `systemctl status kubelet flannel` and `journalctl -u kubelet` on the node |
| `nixos-kubernetes-node-join` rejects the token | The token is not the exact 32-character value | Read the token again with `sudo cat` and avoid extra spaces |
| A worker cannot obtain certificates | TCP 8888 on `argus` is blocked or `cfssl` is down | Check the `argus` firewall and `systemctl status cfssl` on `argus`; check `systemctl status certmgr` on the worker |
| `kubectl` works on `argus` but fails elsewhere | The kubeconfig was not copied, or the CA data is missing | Check `kubectl config view`, then copy the full file again |
| `kubectl` hangs or uses the wrong address on `argus` | `argus` resolves to `127.0.0.2` as well as `10.0.0.110` | Use `https://10.0.0.110:6443` in the kubeconfig |

## Validation checklist

- [ ] `systemctl status` shows all control plane services as `active`.
- [ ] `sudo kubectl --kubeconfig=/etc/kubernetes/cluster-admin.kubeconfig get nodes` shows all nodes as `Ready`.
- [ ] `kubectl get nodes` works as the normal user on `argus`.
- [ ] `kubectl get nodes` works on every machine that has the copied kubeconfig.
- [ ] `kubectl auth can-i '*' '*' --all-namespaces` returns `yes` for the administrator identity.
- [ ] `kubectl get pods -A` shows the CoreDNS pods as `Running`.
- [ ] `~/.kube/config` has mode `0600`.

## Reference paths

| Path | Description |
| --- | --- |
| `/etc/kubernetes/cluster-admin.kubeconfig` | Root administrator kubeconfig |
| `/var/lib/kubernetes/secrets/ca.pem` | Cluster CA, readable by all users |
| `/var/lib/kubernetes/secrets/cluster-admin.pem` | Administrator client certificate, renewed every 30 days |
| `/var/lib/kubernetes/secrets/cluster-admin-key.pem` | Administrator private key, `0600 root:kubernetes` |
| `/var/lib/kubernetes/secrets/service-account.pem` | ServiceAccount token verification certificate |
| `/var/lib/kubernetes/secrets/service-account-key.pem` | ServiceAccount token signing key, `0600 kubernetes:kubernetes` |
| `/var/lib/kubernetes/secrets/apitoken.secret` | Worker join token |
| `~/.kube/config` | User kubeconfig, mode `0600` |
| `common/kubernetes.nix` | Shared cluster configuration |
| `hosts/argus/kubernetes.nix` | Master settings |
| `hosts/<worker>/kubernetes.nix` | Worker role |
