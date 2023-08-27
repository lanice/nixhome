#!/usr/bin/env bash
basedir="$HOME/stable-diffusion-webui"
script="$basedir/webui.sh"

synctarget="$basedir/outputs/dropbox"
sharingbasedir="$HOME/Sync"

modelstargetdir="$basedir/models/Stable-diffusion"
modelssourcedir="$sharingbasedir/models"

inspirationlntarget="$basedir/extensions/stable-diffusion-webui-inspiration/inspiration"
wildcardslntarget="$basedir/extensions/sd-dynamic-prompts/wildcards"

controlnettarget="$basedir/extensions/sd-webui-controlnet/models"
controlnetsource="$modelssourcedir/controlnet"

embeddingstarget="$basedir/embeddings"
embeddingssource="$modelssourcedir/embeddings"

if [ -z "${SD_ADMIN}" ]; then
    syncsource="$sharingbasedir/stable-diffusion"
    port=9000

    inspirationlnsource="$HOME/Pictures/inspiration"
    wildcardslnsource="$HOME/Pictures/wildcards"
else
    syncsource="$sharingbasedir/sd"
    port=9001

    inspirationlnsource="$sharingbasedir/sd-misc/inspiration"
    wildcardslnsource="$sharingbasedir/sd-misc/wildcards"
fi

. $basedir/.env
export COMMANDLINE_ARGS="--xformers --listen --port $port --enable-insecure-extension-access --api --api-auth $API_AUTH"

[ -e $inspirationlntarget ] && rm -r $inspirationlntarget
ln -s $inspirationlnsource $inspirationlntarget

[ -e $wildcardslntarget ] && rm -r $wildcardslntarget
ln -s $wildcardslnsource $wildcardslntarget

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
