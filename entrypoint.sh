#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update Server
if [ ! -z ${SRCDS_APPID} ]; then
   ./steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${SRCDS_APPID} +quit
fi

#Mod updates
cleanmodids=$(echo ${MODIDS} | tr -d ' ')
updatelist=""
if [ ! -z $cleanmodids ]; then
  #Conan Exiles
  if [[ ${SRCDS_APPID} == "443030" ]]; then
    printf "Updating Conan Exiles mods\n"
    for i in $(echo $cleanmodids | sed "s/,/ /g")
    do
      updatelist="$updatelist +workshop_download_item 440900 $i validate"
    done
    ./steam/steamcmd.sh +login anonymous +force_install_dir /home/container $updatelist +quit
    mkdir -p /home/container/ConanSandbox/Mods
    find /home/container/steamapps/workshop/content/440900 -iname "*.pak" -exec cp {} /home/container/ConanSandbox/Mods \;
    cd /home/container/ConanSandbox/Mods
    rm modlist.txt
    ls |grep "\.pak$" > modlist.txt
    cd /home/container
    printf "\n\nMods updated\n\n"
  fi
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}
