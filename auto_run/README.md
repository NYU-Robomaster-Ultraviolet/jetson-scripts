# Autorun 
This script is designed to setup new boards designed to run CV_Detection repository (Xavier, Nano, Coral etc) right out of the box.

## Prerequisites
- Display
- Keyboard
- Mouse
- Internet
- Github setup on browser + command line (This is important else major chunk of the script will fail!!!)
- Set variable values before running
  - username
  - path_to_base

## Current tasks
- [X] upgrade packages
- [X] install python packages and tools
- [X] install archiconda
- [X] create conda environment
- [X] add cronjob to get latest release
- [X] setup pyrealsense and librealsense 
- [ ] automate Github setup

## Run
<b>Go through prerequisites first</b>
```shell
cd scripts
./auto_run.sh
```

