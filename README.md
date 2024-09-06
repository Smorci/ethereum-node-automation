# Ethereum Node Automation
Simple to use, packaged, continuously deployed solution to start 3 monitored ethereum nodes in your local environment.

## Pre-requisite

- Nix version 2.18.2 or higher. Follow the [installation instructions](https://nix.dev/install-nix.html) for your operating system
- Github personal access token. Follow the [official documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic) or take a look at the detailed application specific documentation in this repository
- Direnv. Follow the [installation instructions](https://direnv.net/docs/installation.html)

## `.env` file
Create a `.env` file in the repository root, adding your github access token
```
export GITHUB_TOKEN=<your-github-access-token>
```

## Devshell
If you would like to use the development shell provided by the nix flake, run:
```
direnv allow
```

In the shell you can use tools such as `kind` `flux` `kubectl` and `kubectx`

## Usage
### Bootstrap cluster
To start a kubernetes cluster and deploy 3 ethereum [full nodes](https://ethereum.org/en/developers/docs/nodes-and-clients/#what-are-nodes-and-clients) (two clients each), grafana and prometheus in the *ethereum-node-automation* namespace, run: 
```
nix run
```
This will start each deployment and continuously sync with the *main* branch of this repository, with Flux

### Delete cluster
To stop and destroy the cluster on your local machine, you can run:
```
nix run .#delete
```

### Suspend Flux continuous deployment
To stop Flux from continuously syncing the cluster, you can suspend the Flux kustomization, run:
```
flux suspend kustomization ethereum-node-automation
```

### Get Flux continuous deployment status
To see the status of the deployment, run:
```
flux get kustomizations
```



## Monitoring
After deploying the applications, there will be a Grafana and a Prometheus deployment in the namespace. To access the Grafan UI, you should port-forward the HTTP port of Grafana:
```
kubectl port-forward svc/grafana 3000:3000
```
After that you can access the UI from your browser at `localhost:3000`.

The password for the admin user is `admin`. After logging in it is advised to update the password.

The instance is provisioned with two dashboards that use Prometheus as a datasource. Prometheus is configured to scrape data from the ethereum clients themselves and the kubernetes resources.

## More details
If you would wish to read more about implementation details check out the detailed documentation in the docs folder.

## Contributing 
Contributions are welcome, feel free to open a discussion on the repository.
