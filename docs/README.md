# Detailed documentation
This document holds a comprehensive description of the whole system architecture and the system components. The solution focuses on creating a development environment, so further in this document the word environment refers to the local development environment.

When designing the system the key concepts that guided the decisions were: scalability, observability, simplicity of use, reproducibility, declarativity and reliability.

## Architecture
The engine of choice for virtualisation is Docker which provides great tooling and support for running workloads in the environment. Docker also enables us to use countless images, integrate with a ton of software and update our workloads seemlessly. Overall it is a great tool to base our architecture on.

Next, to achieve a scalable solution we needed a container orchestration tool. The most supported one is Kubernetes, which provides great tooling for managing containers and other resources.

`kind` proved as a great and simple tool for creating clusters in the local environment. Together with `kubectx` it is easy to manage Kubernetes nodes and switch between contexts and namespaces.

To ensure a reliable system that uses GitOps principles a continuous deployment tool is needed. This role is taken by Flux which is a tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories), and automating updates to configuration when there is new code to deploy. Flux works by installing custom Kubernetes resources on the cluster and polling Git sources and Kustomizations to compare them with the actual cluster state. 
Flux is a system capable of many things and can be developed in complex and trusted systems, so it is a good choice for a project that could grow. 
Having said that, the idea is simple: setup Flux once, than push to the repository and let Flux take care of the rest.

Achieving observability means that we need a tool for gathering metrics from our workloads and one to visualize the data gathered. The tools of choice are Prometheus for gathering metrics and Grafana for visualizing. These two go hand in hand and are supported by many tools in our stack.

We also need to choose our Ethereum clients which are also called layers. A full Ethereum node consists of an execution layer, responsible for listening for new transations, executing them in EVM and to manage the database and a consensus layer, responsible for implementing and completing the proof-of-stake algorithm. Two nodes that are well tested, laverage the speed and reliability of Rust and fit well with the rest of our stack are Reth (execution layer) and Lighthouse (consensus layer).

Lastly to encapsulate everything and abstract away the implementation details from the user the Nix package manager was chosen which is famous for it's reproducible builds. This way the user can start the process by just executing the `nix run` command.

In the following diagram you can see a visualisation of the architecture

![image](https://github.com/user-attachments/assets/ad1bab83-d5a8-4731-b929-c99507e54281)

## Breakdown of the bootstrap process
In Nix, the package is basically a shell application. The function `writeShellApplication` creates a shell script that has some runtime inputs and is checked by `shellcheck`. 

- The bootstrap package (default package in the nix context) starts with sourcing the `.env` file which holds the access token of the user. We will need that for Flux to authenticate the users actions on Github.

- Afterwards, we use `kind` to create a cluster name `ethereum-node-automation` in the environment of the user. The user can inspect this cluster with `kubectx and kubens`. For further information about how `kind` creates the cluster, see the kind [documentation](https://kind.sigs.k8s.io/).

- After the cluster is created, we create a namespace for our Ethereum nodes and select that namespace with kubens.

- The node need a JWT token. We create this with the script found under `scripts/generate-token.sh` which also creates a kubernetes secret from this token. That secret will be mounted in our nodes containers.

- Here comes Flux. We bootstrap Flux to our cluster, installing the custom resources it needs to automate our infrastructures deployment.

- We create two Flux resources: GitRepository and Kustomization. The GitRepository resource is responsible for telling Flux what is the source of truth for the cluster configuration. In our case it's this repository's main branch. The Kustomization tells Flux the target of the deployment, the path to the Kubernetes manifests that should be monitored and the sync interval. With these two in the repository, Flux will start syncing the cluster with the repository.

The deletion process is quite simple, the command `nix run .#delete` runs the delete package, which is a shell application running `kind delete` to delete the local cluster.

## Monitoring
It is simple in concept: Prometheus scrapes the metrics from the metrics endpoints exposed by the containers and we consume those metrics by providing Prometheus as a datasource for Grafana.

The Prometheus configuration is as follows: Prometheus scrapes any metrics from kubernetes resources that implement the `metrics-path, port and scrape` Prometheus annotations. It also scrapes metrics from the Kubelet CAdvisor API which provide us metrics about the kubernetes resources (cpu, memory, state, etc.)

These scraped metrics than are transmitted to Grafana via a datasource. This is provisioned at the time fo deployment. This datasource is then used by two dashboards, which are downloaded and provisined via a shell script in an init container. The dashboards provide information about the nodes and the kubernetes resources.

## Shortcomings
This solution is not perfect by any means, it has many advantages but it has a lot of flaws. Let's enumerate:
- Although it is simple to use, it is complex underneat, it has many points of failure
- Many things are hardcoded, configuration of the system is not an option
- It is not suitable for a staging or production environment
- It is hard to maintain

Most of these problems have a solution and they can be fixed with some refactoring and appropiate tooling.

## Future plans

- Make a Helm package for the ethereum node
- Use [helmfile](https://github.com/helmfile/helmfile) to create declarative environments
- Refactor code to use variables
- Flux auto image updates
