#!/usr/bin/env bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#k
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# bash "strict-mode", fail immediately if there is a problem
set -o nounset
set -o pipefail

# A helper method to make calls to the gke cluster through the bastion.
call_bastion() {
  local command=$1; shift;
  # shellcheck disable=SC2005
  echo "$(gcloud compute ssh "$USER"@gke-tutorial-bastion --command "${command}")"
}

# Setup Nginx on the host
call_bastion "kubectl apply -f manifests/nginx.yaml"

# Verify that the pods are blocked
call_bastion "kubectl get pods" | grep "Blocked" &> /dev/null || exit 1
echo "Step 1 of the validation passed."

# Verify that the pods are stuck in a "Pending" state with Message "Cannot enforce AppArmor:"
echo "Checking pods"
call_bastion "kubectl describe pods" | grep "Cannot enforce AppArmor:" &> /dev/null || exit 1
echo "step 2 of the validation passed."

# Deploy the AppArmor loader daemonset
echo "Deploying AppArmor"
call_bastion "kubectl apply -f manifests/apparmor-loader.yaml" | grep "created" &> /dev/null || exit 1
echo "step 3 of the validation passed."

# Delete the nginx pods
echo "Deleting nginx pods"
call_bastion "kubectl delete pods -l app=nginx" | grep "deleted" &> /dev/null || exit 1
echo "step 4 of the validation passed."

# Verify that the new nginx pods are created to replace the old and that they are started successfully
call_bastion "kubectl get pods -n dev" | grep "Running" &> /dev/null || exit 1
echo "step 5 of the validation passed."

# Grab the external IP of the nginx pod to confirm that it is deployed correctly.
EXT_IP="$(call bastion "kubectl get svc 'nginx-lb' -n default \
  -ojsonpath='{.status.loadBalancer.ingress[0].ip}'")"

# Verify that the external IP returns the "Welcome to nginx!" page.
curl "$EXT_IP" | grep "Welcome to nginx!" &> /dev/null || exit 1
echo "step 6 of the validation passed."

# Setup the pod labeler
call_bastion "kubectl apply -f manifests/pod-labeler.yaml" | grep "created" &> /dev/null || exit 1
echo "step 7 of the validation passed."

# Sleep for a few minutes to let the new pod create
sleep 2m

# Verify that the new nginx pods are created to replace the old and that they are started successfully
call_bastion "kubectl get pods --show-labels" | grep "pod-labeler" &> /dev/null || exit 1
echo "step 8 of the validation passed."
