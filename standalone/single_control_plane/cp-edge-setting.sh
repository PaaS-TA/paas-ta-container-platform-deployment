#!/bin/bash

cat << EOF > inventory/mycluster/edge-hosts.yaml
all:
  hosts:
    $MASTER_NODE_HOSTNAME:
      ansible_host: $MASTER_NODE_PRIVATE_IP
      ip: $MASTER_NODE_PRIVATE_IP
      access_ip: $MASTER_NODE_PRIVATE_IP
EOF

for ((i=0;i<$EDGE_NODE_CNT;i++))
  do
    j=$((i+1));
    eval "edge_node_hostname=\${EDGE${j}_NODE_HOSTNAME}";
    eval "edge_node_private_ip=\${EDGE${j}_NODE_PRIVATE_IP}";

cat << EOF >> inventory/mycluster/edge-hosts.yaml
    $edge_node_hostname:
      ansible_host: $edge_node_private_ip
      ip: $edge_node_private_ip
      access_ip: $edge_node_private_ip
EOF
done

cat << EOF >> inventory/mycluster/edge-hosts.yaml
  children:
    cloudcore_node:
      hosts:
        $MASTER_NODE_HOSTNAME:
    edge_node:
      hosts:
EOF

for ((i=0;i<$EDGE_NODE_CNT;i++))
  do
    j=$((i+1));
    eval "edge_node_hostname=\${EDGE${j}_NODE_HOSTNAME}";
    eval "edge_node_private_ip=\${EDGE${j}_NODE_PRIVATE_IP}";

cat << EOF >> inventory/mycluster/edge-hosts.yaml
        $edge_node_hostname:
EOF
done

cat << EOF > roles/paasta-cp/edge/keadm_init/defaults/main.yml
cloudcore1_node_hostname: {CLOUDCORE1_NODE_HOSTNAME}
cloudcore2_node_hostname: {CLOUDCORE2_NODE_HOSTNAME}
EOF

cat << EOF > roles/paasta-cp/edge/keadm_join/defaults/main.yml
cloudcore_vip: {CLOUDCORE_VIP}
EOF

sed -i "s/{CLOUDCORE1_NODE_HOSTNAME}/$CLOUDCORE1_NODE_HOSTNAME/g" roles/paasta-cp/edge/keadm_init/defaults/main.yml
sed -i "s/{CLOUDCORE2_NODE_HOSTNAME}/$CLOUDCORE2_NODE_HOSTNAME/g" roles/paasta-cp/edge/keadm_init/defaults/main.yml

sed -i "s/{CLOUDCORE_VIP}/$CLOUDCORE_VIP/g" roles/paasta-cp/edge/keadm_join/defaults/main.yml

sed -i "s/{MASTER_NODE_HOSTNAME}/$MASTER_NODE_HOSTNAME/g" ../../edge/edgemesh/agent/04-configmap.yaml
sed -i "s/{CLOUDCORE_VIP}/$CLOUDCORE_VIP/g" ../../edge/edgemesh/agent/04-configmap.yaml

sed -i "s/{CLOUDCORE_VIP}/$CLOUDCORE_VIP/g" ../../edge/ha-cloudcore/02-ha-configmap.yaml
