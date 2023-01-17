# Drone Plugin to Setup Drone, ArgoCD and Gitea Stack

A [Drone](https://drone.io) plugin to install and configure local k3s cluster with [Drone, ArgoCD and Gitea](https://github.com/kameshsampath/drag-stack).

## Usage

The following settings changes this plugin's behavior.

* `create_cluster`: true/false, flag to indicate if k3s cluster needs to be created
* `delete_cluster`: true/false, flag to indicate if k3s cluster needs to be delete. `create_cluster` and `delete_cluster` are mutually exclusive. `delete_cluster`  takes precedence over `create_cluster`
* `k3d_cluster_name`: The k3d cluster to use
* `install_source`: The git repository source for installer. Defaults to <https://github.com/kameshsampath/gitops-on-k3s>
* `clone_path`: Where to clone the installer. Defaults `/tmp/work`
* `install_components`: List of components to install. e.g gitea, argocd etc.,
* `check_install`: Check installation to make sure all components are installed and running
