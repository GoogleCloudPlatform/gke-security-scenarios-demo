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
This file exposes module variables that can be overridden to customize the instance
configuration
https://www.terraform.io/docs/configuration/variables.html
*/

variable "hostname" {
  description = "The hostname to be given to the created instance"
  type        = string
}

variable "machine_type" {
  description = "The machine type to use for the created instance"
  type        = string
}

variable "project" {
  description = "The project in which to create the instance"
  type        = string
}

variable "zone" {
  description = "The zone in which to create the instance"
  type        = string
}

variable "tags" {
  description = "Tags to add to the created instance tags"
  type        = list(string)
}

variable "cluster_subnet" {
  description = "The subnet in which to home the private interface of the created instance"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster to which this host will connect"
  type        = string
}

variable "service_account_email" {
  description = "Identifies the service account to use for the created instance"
  type        = string
}

variable "grant_cluster_admin" {
  description = "Determines whether the instance is granted GKE admin privileges"
  type        = string
  default     = "0"
}

variable "vpc_name" {
  description = "Names the VPC in which to create the instance"
  type        = string
  default     = "kube-net-ss"
}

