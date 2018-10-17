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

/*
This file exposes module variables that can be overridden to customize the network
configuration
https://www.terraform.io/docs/configuration/variables.html
*/

variable "project" {
  description = "the project for this network"
  type        = "string"
}

variable "tags" {
  description = "Tags to add to the created instance tags"
  type        = "list"
}

variable "ip_range" {
  description = "Specifies the CIDR for the network's primary subnetwork"
  type        = "string"
  default     = "10.0.96.0/22"
}

variable "region" {
  description = "The region in which to create the network"
  type        = "string"
}

variable "secondary_ip_range" {
  description = "Specifies the CIDR for the secondary network required when using a private GKE cluster"
  type        = "string"
  default     = "10.0.92.0/22"
}

variable "vpc_name" {
  description = "Names the VPC in which to create the network"
  type        = "string"
  default     = "kube-net-ss"
}
