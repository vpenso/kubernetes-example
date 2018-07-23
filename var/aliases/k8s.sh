K8S_VM_IMAGE=centos7
K8S_ADMIN_NODE=lxcc01

export K8S_IMAGE \
       K8S_ADMIN_NODE

#
# install all components comment on all nodes
#
k8s-vm-bootstrap() {
        local instance=$1
        local file=
        # set the node name
        vm exec $instance --root hostname $instance
        # disable the firewall
        vm exec $instance --root -- systemctl disable --now firewalld
        # disable SELinux
        vm exec $instance --root setenforce 0
        # disable IPv6
        file=/etc/sysctl.d/ipv6.conf
        vm sync $instance --root $K8S_PATH/$file :$file
        vm exec $instance --root -- sysctl --load $file
        # upload the Kubernetes RPM package repo configuration file
        file=/etc/yum.repos.d/kubernetes.repo
        vm sync $instance --root $K8S_PATH/$file :$file
        vm exec $instance --root -- yum update --assumeyes
        # install components
        vm exec $instance --root -- \
                yum install --assumeyes docker kubelet kubeadm kubectl
        # start services
        vm exec $instance --root -- systemctl enable --now docker kubelet
}

#
# print the join command on a node with admin access to the cluster,
# and execute it on the target VM instance
#
k8s-vm-join() {
        local instance=$1
        vm exec $instance --root \
                "$(vm exec $K8S_ADMIN_NODE --root -- kubeadm token create --print-join-command)"
}
