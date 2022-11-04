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

echo starting autorun

echo getting updates
sudo apt-get updates
sudo apt upgrade -y
cmd_pass $? PACKAGES_UPGRADE_SUCCESS PACKAGE_UPGRADE_FAIL

echo install python related packages and tools
sudo apt install -y python3-h5py libhdf5-serial-dev hdf5-tools python3-matplotlib python3-pip libopenblas-base libopenmpi-dev
cmd_pass $? PYTHON_PACKAGES_SUCCESS PYTHON_PACKAGES_FAIL

echo downloading archiconda
wget https://github.com/Archiconda/build-tools/releases/download/0.2.3/Archiconda3-0.2.3-Linux-aarch64.sh
cmd_pass $? ARCHICONDA_DOWNLOAD_SUCCESS ARCHICONDA_DOWNLOAD_FAIL

echo installing archiconda
sudo sh Archiconda3-0.2.3-Linux-aarch64.sh
cmd_pass $? ARCHICONDA_INSTALL_SUCCESS ARCHICONDA_INSTALL_FAIL

echo creating a conda environment
conda env create -f conda_envs/environment_xav.yml
cmd_pass $? CONDA_ENV_SUCCESS CONDA_ENV_FAIL

echo adding cronjob
username="ultraviolet/"     # VARIABLE: username of system
path_to_base="Repos/"       # VARIABLE: path to jetson-scripts repository on the system
echo "cronjob to autodownload latest CV_Detection release from github at 0300 hours everyday\n0 3 * * * ./home/"$username$path_to_base"jetson-scripts/get_latest_release.sh" >> /etc/crontab
cmd_pass $? CRONJOB_ADD_SUCCESS CRONJOB_ADD_FAIL

echo setting up pyrealsense and libraries 
/bin/bash setup_realsense.sh
cmd_pass $? REALSENSE_SETUP_SUCCESS REALSENSE_SETUP_FAIL