#!/usr/bin/env bash
basedir="$HOME/automatic"
script="$basedir/webui.sh"

lntarget="$basedir/outputs/sync"
sharingbasedir="$HOME/Sync"

modelstargetdir="$basedir/models/Stable-diffusion"
modelssourcedir="$sharingbasedir/models"

controlnettarget="$basedir/models/ControlNet"
controlnetsource="$modelssourcedir/controlnet"

embeddingstarget="$basedir/models/embeddings"
embeddingssource="$modelssourcedir/embeddings"

if [ -z "${SD_ADMIN}" ]; then
    lnsource="$sharingbasedir/stable-diffusion"
    port=9000
    declare -a models=("anime" "fantasy" "general" "inpaint" "realism" "stable-diffusion")
else
    lnsource="$sharingbasedir/sd"
    port=9001
    declare -a models=("admin" "anime" "fantasy" "general" "inpaint" "realism" "stable-diffusion")
fi

. $basedir/.env
export COMMANDLINE_ARGS="--listen --port $port --insecure"
# export COMMANDLINE_ARGS="--listen --port $port --enable-insecure-extension-access --api --api-auth $API_AUTH"

[ -e $controlnettarget ] && rm -r $controlnettarget
ln -s $controlnetsource $controlnettarget

[ -e $embeddingstarget ] && rm -r $embeddingstarget
ln -s $embeddingssource $embeddingstarget

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
