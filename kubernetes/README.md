# kubernetes

This subdirectory is monitored by ArgoCD and uses an [App-of-Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) pattern.

The main app is held at `/root`, and any specific app is within the `/apps` directory.

To add a new app, just add to the `root/values.yaml`:

```diff
repo: https://github.com/robherley/homelab.git

apps:
  - name: argocd
    namespace: argocd
+ - name: plex
+   namespace: media
```
