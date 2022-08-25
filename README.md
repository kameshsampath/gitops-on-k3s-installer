# Drone Plugin to Setup Drone, ArgoCD and Gitea Stack

A [Drone](https://drone.io) plugin to install and configure local k3s cluster with [Drone, ArgoCD and Gitea](https://github.com/kameshsampath/dag-stack)

## Usage

The following settings changes this plugin's behavior.

* `create_k3d_cluster`: true/false, flag to indicate if k3s cluster needs to be created
* `k3d_cluster_name`: The k3d cluster to use
* `dag_stack_clone_path`: The path where dag-stack repo is cloned
* `install_components`: List of components to install. e.g gitea, argocd etc.,
* `check_install`: Check installation to make sure all components are installed and running
