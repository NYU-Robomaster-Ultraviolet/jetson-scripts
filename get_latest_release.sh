# LOCATION=$(curl -s https://api.github.com/repos/NYU-Robomaster-Ultraviolet/CV_Detection/releases/latest \
# | grep "tag_name" \
# | awk '{print "https://github.com/NYU-Robomaster-Ultraviolet/CV_Detection/archive/" substr($2, 2, length($2)-3) ".zip"}') \
# ; wget -O release.zip $LOCATION
# function to compare versions
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
# get latest git tag
L_GIT_TAG=$(curl -s https://api.github.com/repos/NYU-Robomaster-Ultraviolet/CV_Detection/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 2, length($2)-3)}') \
;
URL=$(echo "https://github.com/NYU-Robomaster-Ultraviolet/CV_Detection/archive/"$L_GIT_TAG".zip")
declare GIT_TAG
statefile=data.txt
echo Latest git tag = $L_GIT_TAG
#get existing git tag
if [ -e "$statefile" ]
then
    read -r GIT_TAG <"$statefile"
    # compare git tags
    vercomp $L_GIT_TAG $GIT_TAG
    case $? in
        0) echo Already running latest!! Exiting...
            exit 0;;
        1) echo New version available!! Downloading...
            echo $L_GIT_TAG > $statefile
            wget -O release.zip $URL;;
    esac
else
    # first run / statefile deleted
    echo Creating state file
    echo $L_GIT_TAG > $statefile
    wget -O release.zip $URL
fi


