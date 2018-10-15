#! /usr/bin/env bash

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# bash "strict-mode", fail immediately if there is a problem
set -euo pipefail
CALICO="calico-"
ZERO="0/1"
UPDATED="updated="
OUTPUT=""
NGINX_MESSAGE="deployment \"nginx\" successfully rolled out"
PL_MESSAGE="deployment \"pod-labeler\" successfully rolled out"

command -v curl >/dev/null 2>&1 || { \
 echo >&2 "I require curl but it's not installed.  Aborting."; exit 1; }

command -v gcloud >/dev/null 2>&1 || { \
 echo >&2 "I require gcloud but it's not installed.  Aborting."; exit 1; }

# Any command passed will get executed on the gke-tutorial-bastion with stderr
# redirected to stdout.
remote_exec() {
  local command=$1; shift;

  # shellcheck disable=SC2005
  echo "$(gcloud compute ssh gke-tutorial-bastion --command "${command}" 2>&1)"
}

remote_exec "source /etc/profile && exit"

# Our expected output should contain a calico pod, which will match 'calico-'
OUTPUT=$CALICO
remote_exec "kubectl get pods --all-namespaces --show-labels" | grep "$OUTPUT" \
 &> /dev/null || exit 1
echo "step 1 of the validation passed."

remote_exec "kubectl apply -f manifests/nginx.yaml" &> /dev/null

<<<<<<< HEAD

# The apparmor profile doesn't yet exist, so the string: '0/1' will appear.
OUTPUT=$ZERO
remote_exec "kubectl get pods --show-labels" | grep "$OUTPUT" \
 &> /dev/null || exit 1
echo "step 2 of the validation passed."

remote_exec "kubectl apply -f manifests/apparmor-loader.yaml" &> /dev/null
remote_exec "kubectl delete pods -l app=nginx" &> /dev/null


# Wait for the rollout of nginx to finish, now that the apparmor profile
# has been deployed.
while true
do
  ROLLOUT=$(remote_exec "kubectl rollout status --watch=false deployment/nginx") &> /dev/null
  if [[ $ROLLOUT = *"$NGINX_MESSAGE"* ]]; then
    break
  fi
  sleep 2
done
echo "step 3 of the validation passed."
=======
# Verify that the pods are stuck in a "Pending" state with Message "Cannot enforce AppArmor:"
echo "Checking pods"
call_bastion "kubectl describe pods" | grep "Cannot enforce AppArmor:" &> /dev/null || exit 1
echo "Step 2 of the validation passed."

# Deploy the AppArmor loader daemonset
echo "Deploying AppArmor"
call_bastion "kubectl apply -f manifests/apparmor-loader.yaml" | grep "created" &> /dev/null || exit 1
echo "Step 3 of the validation passed."

# Delete the nginx pods
echo "Deleting nginx pods"
call_bastion "kubectl delete pods -l app=nginx" | grep "deleted" &> /dev/null || exit 1
echo "Step 4 of the validation passed."

# Verify that the new nginx pods are created to replace the old and that they are started successfully
call_bastion "kubectl get pods -n dev" | grep "Running" &> /dev/null || exit 1
echo "Step 5 of the validation passed."
>>>>>>> 0ee092e... Fix an issue with make

# Grab the external IP of the service to confirm that nginx deployed correctly.
EXT_IP=""
while true
do
  sleep 1

<<<<<<< HEAD
  EXT_IP="$(remote_exec "kubectl get svc 'nginx-lb' -ojsonpath='{.status.loadBalancer.ingress[0].ip}'")"
  if [[ $EXT_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    break
  else
    continue
  fi
done
[ "$(curl -s -o /dev/null -w '%{http_code}' "$EXT_IP"/)" -eq 200 ] || exit 1
echo "step 4 of the validation passed."

remote_exec "kubectl apply -f manifests/pod-labeler.yaml" &> /dev/null
=======
# Verify that the external IP returns the "Welcome to nginx!" page.
curl "$EXT_IP" | grep "Welcome to nginx!" &> /dev/null || exit 1
echo "Step 6 of the validation passed."

# Setup the pod labeler
call_bastion "kubectl apply -f manifests/pod-labeler.yaml" | grep "created" &> /dev/null || exit 1
echo "Step 7 of the validation passed."
>>>>>>> 0ee092e... Fix an issue with make

# Wait for the rollout of the pod-labeler to finish.
while true
do
  ROLLOUT=$(remote_exec "kubectl rollout status --watch=false deployment/pod-labeler") &> /dev/null
  if [[ $ROLLOUT = *"$PL_MESSAGE"* ]]; then
    break
  fi
  sleep 2
done

<<<<<<< HEAD
# Now that the pod-labeler has finished, the label 'updated=' will appear.
OUTPUT=$UPDATED
remote_exec "kubectl get pods --show-labels" | grep "$OUTPUT" \
 &> /dev/null || exit 1
 echo "step 5 of the validation passed."
=======
# Verify that the new nginx pods are created to replace the old and that they are started successfully
call_bastion "kubectl get pods --show-labels" | grep "pod-labeler" &> /dev/null || exit 1
echo "Step 8 of the validation passed."
>>>>>>> 0ee092e... Fix an issue with make
