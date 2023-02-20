#!/usr/bin/env bash
basedir="$HOME/stable-diffusion-webui"
script="$basedir/webui.sh"

modelstargetdir="$basedir/models/Stable-diffusion"
modelssourcedir="$HOME/sd-models"

lntarget="$basedir/outputs/dropbox"
sharingbasedir="$HOME/Sync"

inspirationlntarget="$basedir/extensions/stable-diffusion-webui-inspiration/inspiration"

if [ -z "${SD_ADMIN}" ]; then
    lnsource="$sharingbasedir/stable-diffusion"
    port=9000
    declare -a models=("anime" "fantasy" "general" "inpaint" "realism" "stable-diffusion")

    inspirationlnsource="$HOME/Pictures/inspiration"
else    
    lnsource="$sharingbasedir/sd"
    port=9001
    declare -a models=("admin" "anime" "fantasy" "general" "inpaint" "realism" "stable-diffusion")

    inspirationlnsource="$sharingbasedir/sd-misc/inspiration"
fi

export COMMANDLINE_ARGS="--xformers --listen --port $port --enable-insecure-extension-access"

[ -e $inspirationlntarget ] && rm -r $inspirationlntarget
ln -s $inspirationlnsource $inspirationlntarget

[ -e $lntarget ] && rm $lntarget
ln -s $lnsource $lntarget

# delete all symlinks in the models directory
find $modelstargetdir -type l -exec rm {} +

for i in "${models[@]}"
do
    ln -s $modelssourcedir/$i $modelstargetdir/$i
done

pushd $basedir
git pull
. $script
popd
