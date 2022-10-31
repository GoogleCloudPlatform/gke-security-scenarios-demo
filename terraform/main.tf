/*
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
// https://www.terraform.io/docs/providers/google/r/google_container_cluster.html
// Create the primary cluster for this project.

// Provides access to available Google Container Engine versions in a zone for a given project.
// https://www.terraform.io/docs/providers/google/d/google_container_engine_versions.html
data "google_container_engine_versions" "on-prem" {
  location = var.zone
  project  = var.project
}

# Syntax for using a custom module, which is a collection of resources
# This module is called 'network' and is defined in the modules folder
# We are creating an instance also called 'network'
module "network" {
  source   = "./modules/network"
  project  = var.project
  region   = var.region
  vpc_name = "kube-net-ss"
  tags     = var.bastion_tags
}

# This is another custom module called 'firewall' in the modules folder
# We are creating an instance also called 'firewall'
module "firewall" {
  source   = "./modules/firewall"
  project  = var.project
  vpc      = module.network.network_self_link
  net_tags = var.bastion_tags
}

# This is another custom module called 'instance' in the modules folder
# We are creating an instance called 'bastion'
module "bastion" {
  source                = "./modules/instance"
  project               = var.project
  hostname              = "gke-tutorial-bastion"
  machine_type          = var.bastion_machine_type
  zone                  = var.zone
  tags                  = var.bastion_tags
  cluster_subnet        = module.network.subnet_self_link
  cluster_name          = var.cluster_name
  service_account_email = google_service_account.admin.email
  grant_cluster_admin   = "1"
  vpc_name              = "kube-net-ss"
}

# This builds our Kubernetes Engine cluster
resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  project            = var.project
  location           = var.zone
  network            = module.network.network_self_link
  subnetwork         = module.network.subnet_self_link
  min_master_version = data.google_container_engine_versions.on-prem.latest_master_version
  initial_node_count = 3

  lifecycle {
    ignore_changes = [ip_allocation_policy.0.services_secondary_range_name]
  }
  

  // Scopes necessary for the nodes to function correctly
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    machine_type = var.node_machine_type
    image_type   = "COS_CONTAINERD"

    // (Optional) The Kubernetes labels (key/value pairs) to be applied to each node.
    labels = {
      status = "poc"
    }

    // (Optional) The list of instance tags applied to all nodes.
    // Tags are used to identify valid sources or targets for network firewalls.
    tags = ["poc"]
  }

  // (Required for private cluster, optional otherwise) Configuration for cluster IP allocation.
  // As of now, only pre-allocated subnetworks (custom type with
  // secondary ranges) are supported. This will activate IP aliases.
  ip_allocation_policy {
    cluster_secondary_range_name = "secondary-range"
  }

  // In a private cluster, the master has two IP addresses, one public and one
  // private. Nodes communicate to the master through this private IP address.
  private_cluster_config {
    enable_private_nodes   = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "10.0.90.0/28"
  }

  // (Required for private cluster, optional otherwise) network (cidr) from which cluster is accessible
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "gke-tutorial-bastion"
      cidr_block   = "${module.bastion.external_ip}/32"
    }
  }

  // (Required for Calico, optional otherwise) Configuration options for the NetworkPolicy feature
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  // (Required for network_policy enabled cluster, optional otherwise)
  // Addons config supports other options as well, see:
  // https://www.terraform.io/docs/providers/google/r/container_cluster.html#addons_config
  addons_config {
    network_policy_config {
      disabled = false
    }
  }
}
