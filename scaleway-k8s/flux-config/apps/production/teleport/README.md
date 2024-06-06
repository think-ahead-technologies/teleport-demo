## Teleport configuration files

These files contain configuration for the Teleport cluster once it's set up. They can be applied on the CLI, after logging into the cluster, with:
```
kubectl exec -i deployment/teleport-cluster-auth -n teleport -- tctl create -f < filename.yaml
```


TODO add `system:masters` to `kubernetes_groups`