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
sudo apt update
sudo apt upgrade -y
cmd_pass $? PACKAGES_UPGRADE_SUCCESS PACKAGE_UPGRADE_FAIL

echo install python related packages and tools
sudo apt install -y python3-h5py libhdf5-serial-dev hdf5-tools python3-matplotlib python3-pip libopenblas-base libopenmpi-dev git nano cmake
cmd_pass $? PYTHON_PACKAGES_SUCCESS PYTHON_PACKAGES_FAIL

echo installing jetpack components
# sudo bash -c 'echo "deb https://repo.download.nvidia.com/jetson/common r34.1 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list'
# sudo bash -c 'echo "deb https://repo.download.nvidia.com/jetson/t234 r34.1 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list'
sudo apt update
sudo apt dist-upgrade -y
sudo apt install nvidia-jetpack
cmd_pass $? CUDA_SETUP_SUCCESS CUDA_SETUP_FAIL

echo setting up CUDA
echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bashrc 
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64' >> ~/.bashrc 
echo 'export PATH=$PATH:$CUDA_HOME/bin' >> ~/.bashrc 

echo downloading archiconda
wget https://github.com/Archiconda/build-tools/releases/download/0.2.3/Archiconda3-0.2.3-Linux-aarch64.sh
cmd_pass $? ARCHICONDA_DOWNLOAD_SUCCESS ARCHICONDA_DOWNLOAD_FAIL

echo installing archiconda
sudo sh Archiconda3-0.2.3-Linux-aarch64.sh
cmd_pass $? ARCHICONDA_INSTALL_SUCCESS ARCHICONDA_INSTALL_FAIL

echo creating a conda environment
conda env create -f conda_envs/environment_xav.yml
cmd_pass $? CONDA_ENV_SUCCESS CONDA_ENV_FAIL

echo installing torch and torchvision 
JP_VERSION=$(apt-cache show nvidia-jetpack | grep Version | head -n 1 | awk '{print substr($2, 1, length($2)-5)}')
sudo apt-get install -y libopenblas-base libopenmpi-dev libjpeg-dev zlib1g-dev
if [ $JP_VERSION=4.6 ]
then    
    # https://github.com/ultralytics/yolov5/issues/9627 - 4.6
    
    wget https://nvidia.box.com/shared/static/fjtbno0vpo676a25cgvuqc1wty0fkkg6.whl -O torch-1.10.0-cp36-cp36m-linux_aarch64.whl
    conda activate CV
    pip3 install torch-1.10.0-cp36-cp36m-linux_aarch64.whl

    git clone --branch v0.11.1 https://github.com/pytorch/vision torchvision
    cd torchvision
    sudo python3 setup.py install 
    cd ..
else
    # https://github.com/ultralytics/yolov5/issues/9627 - 5.0
    wget https://developer.download.nvidia.com/compute/redist/jp/v50/pytorch/torch-1.12.0a0+2c916ef.nv22.3-cp38-cp38-linux_aarch64.whl -O torch-1.12.0a0+2c916ef.nv22.3-cp38-cp38-linux_aarch64.whl
    conda activate CV
    pip3 install torch-1.12.0a0+2c916ef.nv22.3-cp38-cp38-linux_aarch64.whl

    git clone --branch v0.13.0 https://github.com/pytorch/vision torchvision
    cd torchvision
    sudo python3 setup.py install 
    cd ..
fi

echo adding cronjob
username="ultraviolet/"     # VARIABLE: username of system
path_to_base="Repos/"       # VARIABLE: path to jetson-scripts repository on the system
echo "cronjob to autodownload latest CV_Detection release from github at 0300 hours everyday\n0 3 * * * ./home/"$username$path_to_base"jetson-scripts/get_latest_release.sh" >> /etc/crontab
cmd_pass $? CRONJOB_ADD_SUCCESS CRONJOB_ADD_FAIL

echo setting up pyrealsense and libraries 
/bin/bash setup_realsense.sh
cmd_pass $? REALSENSE_SETUP_SUCCESS REALSENSE_SETUP_FAIL