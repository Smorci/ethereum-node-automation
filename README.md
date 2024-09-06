# ethereum-node-automation
Simple to use, packaged, continuously deployed solution to start 3 monitored ethereum nodes in your local environment

## Pre-requisite
1.Nix version 2.18.2 or higher. Follow the [installation instructions](https://nix.dev/install-nix.html) for your operating system.
2. Github personal access token. Follow the [official documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic) or take a look at the detailed application specific documentation in this repository.

## `.env` file

Create a `.env` file in the repository root, adding your github access token
```
export GITHUB_TOKEN=<your-github-access-token>
```
> Replace `<your-github-access-token>` with the generated access token in *pre-requisite* section

## Usage

```
kind create cluster --name ethereum-nodes
```

```
./scripts/generate-token.sh 
```

```
kubectl create namespace ethereum-node-automation
```

```
kubens ethereum-node-automation
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
