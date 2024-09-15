#!/bin/bash

if [[ -z ${USER} ]]; then
  echo "USER variable is undefined"; exit 1
fi

if [[ -z ${SSH_KEY} ]]; then
  echo "USER variable is undefined"; exit 1
fi

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

yum update -y
yum install -y python3

id ${USER} &>/dev/null
if [[ $? -ne 0 ]]; then
  useradd -m ${USER}
fi
if ! [[ -d /home/${USER}/.ssh ]]; then
  mkdir -p /home/${USER}/.ssh
  chmod 700 /home/${USER}/.ssh
  chown ${USER}. /home/${USER}/.ssh
else
  echo "${USER} ssh directory already exist"
fi
echo ${SSH_KEY} > /home/${USER}/.ssh/authorized_keys
chmod 600 /home/${USER}/.ssh/authorized_keys
chown ${USER}. /home/${USER}/.ssh/authorized_keys

grep ^${USER} /etc/sudoers &>/dev/null
if [[ $? -ne 0 ]]; then
  echo "${USER}  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
else
  echo "user already exists on sudoers file"
fi

reboot
