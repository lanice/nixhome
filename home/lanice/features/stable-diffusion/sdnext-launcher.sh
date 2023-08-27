#!/usr/bin/env bash
basedir="$HOME/automatic"
script="$basedir/webui.sh"

synctarget="$basedir/outputs/sync"
sharingbasedir="$HOME/Sync"

modelstargetdir="$basedir/models/Stable-diffusion"
modelssourcedir="$sharingbasedir/models/models"

controlnettarget="$basedir/models/ControlNet"
controlnetsource="$sharingbasedir/models/controlnet"

embeddingstarget="$basedir/models/embeddings"
embeddingssource="$sharingbasedir/models/embeddings"

if [ -z "${SD_ADMIN}" ]; then
    syncsource="$sharingbasedir/stable-diffusion"
    port=9000
else
    syncsource="$sharingbasedir/sd"
    port=9001
fi

. $basedir/.env
export COMMANDLINE_ARGS="--listen --port $port --insecure"
# export COMMANDLINE_ARGS="--listen --port $port --enable-insecure-extension-access --api --api-auth $API_AUTH"

[ -e $controlnettarget ] && rm -r $controlnettarget
ln -s $controlnetsource $controlnettarget

[ -e $embeddingstarget ] && rm -r $embeddingstarget
ln -s $embeddingssource $embeddingstarget

[ -e $synctarget ] && rm $synctarget
ln -s $syncsource $synctarget

# delete all symlinks in the models directory
find $modelstargetdir -type l -exec rm {} +

for d in $modelssourcedir/*; do
    ln -s $d $modelstargetdir/$(basename $d)
done

pushd $basedir
git pull
. $script
popd
