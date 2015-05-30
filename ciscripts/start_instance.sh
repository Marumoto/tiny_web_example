#!/bin/bash

set -eu
set -o pipefail



mussel instance create \
--hypervisor kvm \
--cpu-cores 1 \
--image-id wmi-centos1d64 \
--memory-size 256 \
--ssh-key-id ssh-ruekc3bs \
--display-name vdc-instance \
--vifs vifs.json
