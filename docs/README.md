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

Lastly we need to choose our Ethereum clients which are also called layers. A full Ethereum node consists of an execution layer, responsible for listening for new transations, executing them in EVM and to manage the database and a consensus layer, responsible for implementing and completing the proof-of-stake algorithm. Two nodes that are well tested, laverage the speed and reliability of Rust and fit well with the rest of our stack are Reth (execution layer) and Lighthouse (consensus layer).
