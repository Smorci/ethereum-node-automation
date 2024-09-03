# ethereum-node-automation
Automated solution to setup a local network of at least three ethereum nodes

```
kind create cluster --name ethereum-nodes
```

```
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=ethereum-node-automation \
  --branch=main \
  --path=./clusters/ethereum-node-automation \
  --personal 
```

```
flux create source git ethereum-node-automation \   
  --url=https://github.com/Smorci/ethereum-node-automation \
  --branch=main \
  --interval=1m \
  --export > ./clusters/ethereum-node-automation/ethereum-node-automation-source.yaml
```

```
flux create kustomization ethereum-node-automation \
  --target-namespace=ethereum-node-automation \
  --source=ethereum-node-automation \
  --path="./kustomize" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/ethereum-node-automation/ethereum-node-automation-kustomization.yaml
```

```
flux get kustomizations --watch
```
