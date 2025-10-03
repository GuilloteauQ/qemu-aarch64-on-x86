set -xe

IMAGE_NAME=nocloud.qcow2

wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-arm64.qcow2 -O ${IMAGE_NAME}

virt-customize -a ${IMAGE_NAME} \
                 --ssh-inject root:file:${HOME}/.ssh/id_rsa.pub \
                 --firstboot-command 'apt-get update -y && apt-get install -y openssh-server && ssh-keygen -A && systemctl restart sshd'

qemu-system-aarch64 -m 2G -M virt -cpu max \
  -bios $(pwd)/QEMU_EFI.fd \
  -drive if=none,file=$(pwd)/${IMAGE_NAME},id=hd0 -device virtio-blk-device,drive=hd0 \
  -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:5555-:22 \
  -nographic \
  -serial mon:stdio
