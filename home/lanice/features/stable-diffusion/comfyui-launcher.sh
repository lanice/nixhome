#!/usr/bin/env bash
basedir="$HOME/ComfyUI"
script="$basedir/main.py"

synctarget="$basedir/output"
sharingbasedir="$HOME/Sync"

modelstargetdir="$basedir/models/checkpoints"
modelssourcedir="$sharingbasedir/models/models"

# controlnettarget="$basedir/models/ControlNet"
# controlnetsource="$sharingbasedir/models/controlnet"

# embeddingstarget="$basedir/models/embeddings"
# embeddingssource="$sharingbasedir/models/embeddings"

loratarget="$basedir/models/loras"
lorasource="$sharingbasedir/models/Lora"

syncsource="$sharingbasedir/sd/comfy"
port=9001

# [ -e $controlnettarget ] && rm -r $controlnettarget
# ln -s $controlnetsource $controlnettarget

# [ -e $embeddingstarget ] && rm -r $embeddingstarget
# ln -s $embeddingssource $embeddingstarget

[ -e $loratarget ] && rm -r $loratarget
ln -s $lorasource $loratarget

[ -e $synctarget ] && rm $synctarget
ln -s $syncsource $synctarget

# delete all symlinks in the models directory
find $modelstargetdir -type l -exec rm {} +

for d in $modelssourcedir/*; do
    ln -s $d $modelstargetdir/$(basename $d)
done

source /home/lanice/automatic/venv/bin/activate # reuse sdnext's venv
pushd $basedir
# git pull
python $script --listen --port $port
popd
