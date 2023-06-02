#!/usr/bin/env bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# [START cloudrun_fuse_script]
#!/usr/bin/env bash
set -eo pipefail


echo "Mounting GCS Fuse on bucket gs://${BUCKET}."
gcsfuse --debug_gcs --debug_fuse $BUCKET $MNT_DIR 
echo "Mounting completed."

# Entry point for distributable docker image
# This script does some setup required for bootstrapping the container
# and then runs whatever is passed as arguments to this script.
# If the CMD directive is specified in the Dockerfile, those commands
# are passed to this script. This can be overridden by the user in the
# `docker run`
set -x 

# Set up mDNS functionality, to play well with Redis Enterprise
# clusters on the network. Also, run it as a non-root user.
# https://linux.die.net/man/8/avahi-daemon
avahi-daemon --daemonize --no-drop-root

exec python entry.pyc

# Exit immediately when one of the background processes terminate.
wait -n
# [END cloudrun_fuse_script]