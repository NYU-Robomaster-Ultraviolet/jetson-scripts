#!/bin/bash
# commented code - not useful - saving for future use/reference
# LOCATION=$(curl -s https://api.github.com/repos/NYU-Robomaster-Ultraviolet/CV_Detection/releases/latest \
# | grep "tag_name" \
# | awk '{print "https://github.com/NYU-Robomaster-Ultraviolet/CV_Detection/archive/" substr($2, 2, length($2)-3) ".zip"}') \
# ; wget -O release.zip $LOCATION


# function to compare versions
# input: 2 strings
# output: 0 if equal
#         1 if >
#         2 if <
# reference: https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# get latest git tag using github api
# The api returns lot of metadata, use only tag_name
# https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
# read actual github documentation for all metadata
L_GIT_TAG=$(curl -s https://api.github.com/repos/NYU-Robomaster-Ultraviolet/CV_Detection/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 2, length($2)-3)}') \
;
URL=$(echo "https://github.com/NYU-Robomaster-Ultraviolet/CV_Detection/archive/"$L_GIT_TAG".zip")

# some variables to play with
declare GIT_TAG
base_path='/home/ultraviolet/Repos'
shadow_copy='/CV_Detection_old'
base_name='/CV_Detection'
statefile=$base_path/jetson-scripts/data.txt
got_latest=0

echo Latest git tag = $L_GIT_TAG

#get existing git tag
# check if statefile exists
if [ -e "$statefile" ]
then
    read -r GIT_TAG <"$statefile"
    # compare git tags
    vercomp $L_GIT_TAG $GIT_TAG
    case $? in
        0) echo Already running latest!! Exiting...
            exit 0;; # No need to update
        1) echo New version available!! Downloading...
            echo $L_GIT_TAG > $statefile #update latest version in statefile
            wget -O release.zip $URL
            got_latest=1;;

    esac
else
    # statefile does not exist
    # first run / statefile deleted
    echo Creating state file
    echo $L_GIT_TAG > $statefile
    wget -O release.zip $URL
    got_latest=1
fi

# only if a new release is found
if [ got_latest=1 ];
then
    unzip release.zip
    name=$base_name-${L_GIT_TAG:1}
    # create directory if not exist
    if [ ! -d $base_path$base_name ]
    then
        echo Creating CV_Detection
        mkdir $base_path$base_name/
    fi  
    # check if CV_Detection is empty
    number_of_files=$(ls $base_path$base_name/ | wc -l)
    if [ number_of_files=0 ] 
    then
        # create shadow directory if deleted
        if [ ! -d $base_path$shadow_copy/ ]
        then
            echo Creating shadow directory
            mkdir $base_path$shadow_copy/
        fi 
        # copy to shadow directory
        # cp -r !(.git/) $base_path$base_name/. $base_path$shadow_copy/
        rsync -ax --exclude [.git/] $base_path$base_name/. $base_path$shadow_copy/

    fi
    # copy latest release
    # cp -r !(.git/) $name/. $base_path$base_name/
    rsync -ax --exclude [.git/] $base_path/jetson-scripts$name/. $base_path$base_name/
fi

# cleanup
echo Cleaning up!
rm $base_path/jetson-scripts/release.zip
rm -rf $base_path/jetson-scripts/CV_Detection-${L_GIT_TAG:1}
echo Script end!
