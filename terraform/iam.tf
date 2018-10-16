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

# Service accounts are used to provide credentials to software running in
# your GCP account. They can be given privileges in the IAM panel just
# like a user
resource "google_service_account" "admin" {
  account_id   = "gke-tutorial-admin-ss"
  display_name = "GKE Tutorial Admin Security Scenarios"
}

# We are giving privileges to the service account
# In this case we are assigning a role, 'roles/container.admin'
resource "google_project_iam_member" "kube-api-admin" {
  project = "${var.project}"
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.admin.email}"
}
