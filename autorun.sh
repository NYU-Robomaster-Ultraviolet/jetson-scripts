#!/bin/bash
function cmd_pass()
{
    if [ $1 -eq 0 ]; then
        echo $2
    else
        echo $3
        exit
    fi
}
# function git_upload_ssh_key () 
# {
#   read -p "Enter github email : " email
#   echo "Using email $email"
#   if [ ! -f ~/.ssh/id_rsa ]; then
#     ssh-keygen -t rsa -b 4096 -C "$email"
#     ssh-add ~/.ssh/id_rsa
#   fi
#   pub=`cat ~/.ssh/id_rsa.pub`
#   read -p "Enter github username: " githubuser
#   echo "Using username $githubuser"
#   read -s -p "Enter github password for user $githubuser: " githubpass
#   echo
#   read -p "Enter github OTP: " otp
#   echo "Using otp $otp"
#   echo
#   confirm
#   curl -u "$githubuser:$githubpass" -X POST -d "{\"title\":\"`hostname`\",\"key\":\"$pub\"}" --header "x-github-otp: $otp" https://api.github.com/user/keys
# }
echo starting autorun
echo getting updates
sudo apt-get updates
sudo apt upgrade
cmd_pass $? PACKAGES_UPGRADED PACKAGE_UPGRADE_FAILED
echo install python related packages
sudo apt install -y python3-h5py libhdf5-serial-dev hdf5-tools python3-matplotlib python3-pip libopenblas-base libopenmpi-dev
cmd_pass $? PYTHON_PACKAGES_INSTALLED PYTHON_PACKAGES_FAILED
echo downloading archiconda
wget https://github.com/Archiconda/build-tools/releases/download/0.2.3/Archiconda3-0.2.3-Linux-aarch64.sh
cmd_pass $? ARCHICONDA_DOWNLOAD_COMPLETE ARCHICONDA_DOWNLOAD_FAILED
echo installing archiconda
sudo sh Archiconda3-0.2.3-Linux-aarch64.sh
cmd_pass $? ARCHICONDA_INSTALL_COMPLETE ARCHICONDA_INSTALL_FAILED
conda env create -n torch python=3.7
echo installing tools
sudo apt-get install -y git cmake autoconf bc build-essential g++-8 gcc-8 clang-8 lld-8 gettext-base gfortran-8 iputils-ping libbz2-dev libc++-dev libcgal-dev libffi-dev libfreetype6-dev libhdf5-dev libjpeg-dev liblzma-dev libncurses5-dev libncursesw5-dev libpng-dev libreadline-dev libssl-dev libsqlite3-dev libxml2-dev libxslt-dev locales moreutils openssl python-openssl rsync scons python3-pip libopenblas-dev;
cmd_pass $? TOOL_INSTALL_COMPLETE TOOL_INSTALL_FAILED
export TORCH_INSTALL=https://developer.download.nvidia.cn/compute/redist/jp/v50/pytorch/torch-1.12.0a0+84d1cb9.nv22.4-cp38-cp38-linux_aarch64.whl
source torch/bin/activate
python3 -m pip install --upgrade pip; python3 -m pip install expecttest xmlrunner hypothesis aiohttp numpy=='1.19.4' pyyaml scipy=='1.5.3' ninja 
