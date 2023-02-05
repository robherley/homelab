# kubernetes

## k3s

### initial setup

add this to `/etc/rancher/k3s/config.yaml`:

```yaml
write-kubeconfig-mode: "0644"
tls-san:
  - "k3s.lab.reb.gg"
```

install:

```
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest sh -
```

## argo

### install

bootstrap:

```
kustomize build kubernetes/apps/argocd | kubectl apply -n argocd -f -
```

nab the default password:

```
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d
```

port forward:

```
kubectl port-forward svc/argocd-server 8080:80
```

```bash
REPO=https://github.com/robherley/homelab.git

argocd login \
  --port-forward \
  --port-forward-namespace argocd \
  --username admin \
  --password $ADMIN_PASS \
  --insecure \
  --plaintext

argocd repo add $REPO \
  --port-forward \
  --port-forward-namespace argocd \
  --github-app-id $GH_APP_ID \
  --github-app-installation-id $GH_APP_INSTALL_ID \
  --github-app-private-key-path $GH_APP_PEM_PATH \
  --insecure \
  --plaintext

argocd app create root \
  --port-forward \
  --port-forward-namespace argocd \
  --dest-namespace argocd \
  --dest-server https://kubernetes.default.svc \
  --repo $REPO \
  --path kubernetes/root \
  --insecure \
  --plaintext
```

### app of apps

this subdirectory is monitored by ArgoCD and uses an [App-of-Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) pattern.

the main app is held at `/root`, and any specific app is within the `/apps` directory.

to add a new app, just add to the `root/values.yaml`:

```diff
repo: https://github.com/robherley/homelab.git

apps:
  - name: argocd
    namespace: argocd
+ - name: plex
+   namespace: media
```
