

virsh net-destroy networktest
virsh net-undefine networktest

virsh vol-delete /var/lib/libvirt/images/commoninit-test.iso
virsh vol-delete /var/lib/libvirt/images/alpine

virsh pool-destroy mycentos_dev
virsh pool-undefine mycentos_dev

virsh net-list