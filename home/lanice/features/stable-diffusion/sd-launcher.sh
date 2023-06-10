#!/usr/bin/env bash
basedir="$HOME/stable-diffusion-webui"
script="$basedir/webui.sh"

lntarget="$basedir/outputs/dropbox"
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
    lnsource="$sharingbasedir/stable-diffusion"
    port=9000
    declare -a models=("anime" "fantasy" "general" "inpaint" "realism" "stable-diffusion")

    inspirationlnsource="$HOME/Pictures/inspiration"
    wildcardslnsource="$HOME/Pictures/wildcards"
else
    lnsource="$sharingbasedir/sd"
    port=9001
    declare -a models=("admin" "anime" "fantasy" "general" "inpaint" "realism" "stable-diffusion")

    inspirationlnsource="$sharingbasedir/sd-misc/inspiration"
    wildcardslnsource="$sharingbasedir/sd-misc/wildcards"
fi

export COMMANDLINE_ARGS="--xformers --listen --port $port --enable-insecure-extension-access --api"

[ -e $inspirationlntarget ] && rm -r $inspirationlntarget
ln -s $inspirationlnsource $inspirationlntarget

[ -e $wildcardslntarget ] && rm -r $wildcardslntarget
ln -s $wildcardslnsource $wildcardslntarget

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
