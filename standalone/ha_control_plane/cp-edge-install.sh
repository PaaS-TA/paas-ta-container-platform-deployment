#!/bin/bash

ansible-playbook -i inventory/mycluster/edge-hosts.yaml  --become --become-user=root edge.yml
