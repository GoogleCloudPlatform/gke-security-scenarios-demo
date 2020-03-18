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
FROM nginx:1.17.9-alpine

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf

RUN apk update && apk add shadow=4.6-r2 openrc=0.41.2-r1 nginx \
    --no-cache && \
    groupadd -g 1000 appuser && useradd -ru 1000 -g appuser appuser && \
    chown -R appuser:appuser /usr/lib/nginx/ && \
    chown -R appuser:appuser /var/cache/nginx/ && \
    chown -R appuser:appuser /etc/nginx/ && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appuser /run

USER appuser
