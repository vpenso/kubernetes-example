K8S_VM_IMAGE=k8s
K8S_ADMIN_NODE=lxcc01
K8S_SPECS=$K8S_PATH/var/specs
CENTOS_MIRROR=http://mirror.centos.org/centos-7/7/os/x86_64/


export K8S_VM_IMAGE \
       K8S_ADMIN_NODE \
       K8S_SPECS \
       CENTOS_MIRROR

#
# Use CentOS Kickstart to install a base VM image including all prerequisites
# required for Kubernetes deployment
#
k8s-vm-image() {
        mkdir -p $VM_IMAGE_PATH/$K8S_VM_IMAGE && cd $VM_IMAGE_PATH/$K8S_VM_IMAGE
        virt-install \
		--name $K8S_VM_IMAGE \
		--memory 2048 --virt-type kvm --network bridge=nbr0 \
             	--disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
             	--location $CENTOS_MIRROR \
             	--graphics none \
		--console pty,target_type=serial \
 	        --noreboot \
             	--initrd-inject=$K8S_PATH/var/centos/7/kickstart.cfg \
             	--extra-args "console=ttyS0,115200n8 serial inst.repo=$CENTOS_MIRROR inst.text inst.ks=file:/kickstart.cfg" \
	&& virsh undefine $K8S_VM_IMAGE
	cd - &>/dev/null
}

#
# Install all prerequisites required for Kubernetes deployment on a 
# running CentOS VM instance
#
k8s-vm-bootstrap() {
        local instance=$1
        local file=
        # set the node name
        vm exec $instance --root \
                hostname $instance
        # disable the firewall
        vm exec $instance --root -- \
                systemctl disable firewalld 
        vm exec $instance --root -- \
                systemctl stop firewalld
        # disable SELinux
        vm exec $instance --root \
                setenforce 0
        # disable IPv6
        file=/etc/sysctl.d/ipv6.conf
        vm sync $instance --root $K8S_PATH/$file :$file
        vm exec $instance --root -- \
                sysctl --load $file
        # upload the Kubernetes RPM package repo configuration file
        file=/etc/yum.repos.d/kubernetes.repo
        vm sync $instance --root $K8S_PATH/$file :$file
        vm exec $instance --root -- \
                yum update --assumeyes &>/dev/null
        vm exec $instance --root -- \
                yum install --assumeyes epel-release
        # install components
        vm exec $instance --root -- \
                yum install --assumeyes \
                        bridge-utils \
                        conntrack-tools \
                        docker \
                        jq \
                        kubelet \
                        kubeadm \
                        kubectl
        # start services
        vm exec $instance --root -- \
                systemctl enable --now docker kubelet
        # pass bridged IPv4 traffic to iptables’ chains for kube-route
        file=/etc/sysctl.d/bridge.conf
        vm exec $instance --root \
                "echo net.bridge.bridge-nf-call-iptables=1 > $file"
        vm exec $instance --root -- \
                sysctl --load $file
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

#
# upload all Kubernetes specs to the home-directory of the devops
# user on the Kubernetes admin node
#
k8s-upload-specs() {
        vm sync $K8S_ADMIN_NODE $K8S_SPECS/* :
}
