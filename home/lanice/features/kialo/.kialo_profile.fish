set -gx SSH_AUTH_SOCK "$(gpgconf --list-dirs agent-ssh-socket)"
set -gx GPG_TTY $(tty)
gpgconf --launch gpg-agent

set -gx MFA_SERIAL arn:aws:iam::123448139561:mfa/ln
set -gx USE_YKMAN_MFA aws

fish_add_path -gp $(yarn global bin)

set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path -g $PYENV_ROOT/bin
eval "$(pyenv init -)"

set -gx KIALO_ROOT $HOME/work/kialo
set -gx KIALO_INITIALS ln
set -gx KIALO_BACKEND_CONFIG $KIALO_ROOT/development/config/local/backend_config.yaml
# source $KIALO_ROOT/documentation/tasks/shell-utilities.sh

fish_add_path -g $KIALO_ROOT/development/bin

set -gx DOCKER_BUILDKIT 1
