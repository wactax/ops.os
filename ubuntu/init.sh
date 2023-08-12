#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
ROOT=$(dirname $DIR)
cd $DIR
set -ex

if [ -x "$(command -v enable_ipv6)" ]; then
enable_ipv6
fi

export DEBIAN_FRONTEND=noninteractive
export PNPM_HOME=/opt/pnpm
export PATH=$PNPM_HOME:$PATH

ZHOS=$ROOT/build/ubuntu_zh/os

if [ -x "$(command -v snap)" ]; then
  systemctl stop snapd || true
  apt remove --purge --assume-yes snapd gnome-software-plugin-snap
  systemctl disable snapd.service || true
  systemctl disable snapd.socket || true
  systemctl disable snapd.seeded.service || true
  apt autoremove -y --purge snapd
  apt purge snapd -y
  rm -rf /var/cache/snapd
fi

if ! [ -x "$(command -v rsync)" ]; then
  apt-get update -y
  apt-get install -y rsync git
fi

CURL="curl --connect-timeout 5 --max-time 10 --retry 99 --retry-delay 0"

if [ -z "$GFW" ]; then
  curl --connect-timeout 2 -m 4 -s https://t.co >/dev/null || GFW=1
fi

gfw_git() {
  if [ -n "$GFW" ]; then
    git config --global url."https://ghproxy.com/https://github.com".insteadOf "https://github.com"
  fi
}

gfw_git

if [ -n "$GFW" ]; then
  cd /etc/apt
  sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list
  rsync -avI $ZHOS/ /
  source $ZHOS/root/.export
  if ! [ -x "$(command -v pip3)" ]; then
    apt-get install -y python3 python3-pip
  fi
  pip3 install apt-select --break-system-packages && apt-select --country CN && mv /root/sources.list /etc/apt/ || true
fi

apt-get update &&
  apt-get install -y tzdata zram-config cron
# smartdns

if [ -n "$CN" ]; then
  export LANG=zh_CN.UTF-8
  export LC_ALL=zh_CN.UTF-8
  export LANGUAGE=zh_CN.UTF-8
  export TZ=Asia/Shanghai
  apt-get install -y language-pack-zh-hans
  rsync -avI $ZHOS/etc/profile.d/lang.sh /etc/profile.d
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime &&
    echo $TZ >/etc/timezone &&
    locale-gen zh_CN.UTF-8
  $DIR/cron.sh
fi

cd ~

export DEBIAN=_FRONTEND noninteractive
export TERM=xterm-256color

apt-get update &&
  apt-get upgrade -y &&
  apt-get dist-upgrade -y &&
  apt-get install -y unzip gcc build-essential musl-tools g++ git \
    libffi-dev zlib1g-dev liblzma-dev libssl-dev pkg-config pgformatter \
    libreadline-dev libbz2-dev libsqlite3-dev \
    glances libzstd-dev protobuf-compiler zsh \
    software-properties-common curl wget cmake git-lfs \
    autoconf automake libtool supervisor rsyslog

systemctl enable --now supervisor
git lfs install

chsh -s /bin/zsh root

apt-get install -y fd-find ncdu exuberant-ctags asciinema man \
  tzdata sudo tmux openssh-client libpq-dev \
  rsync mlocate gist less util-linux apt-utils socat \
  htop postgresql-client bsdmainutils \
  direnv iputils-ping dstat zstd pixz jq git-extras \
  aptitude clang-format p7zip-full openssh-server

if ! [ -x "$(command -v mosh)" ]; then
  git clone --depth=1 https://github.com/mobile-shell/mosh.git &&
    cd mosh && ./autogen.sh && ./configure &&
    make && make install && cd .. && rm -rf mosh
fi

export CARGO_HOME=/opt/rust
export RUSTUP_HOME=/opt/rust

$CURL https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path

source $CARGO_HOME/env

cargo install --root /usr/local sd

#$DIR/dns.sh

$DIR/zram.sh

if ! [ -x "$(command -v rg)" ]; then
  cargo install --root /usr/local --git https://github.com/wacfork/ripgrep.git
fi

if ! [ -x "$(command -v ntpd-rs)" ]; then
  cargo install --root /usr/local --git https://github.com/memorysafety/ntpd-rs ntpd
fi

if ! [ -x "$(command -v watchexec)" ]; then
  cargo install --root /usr/local --locked watchexec-cli
fi

cargo install --root /usr/local \
  stylua exa cargo-cache tokei atuin \
  diskus cargo-edit cargo-update rtx-cli bat

rtx_add() {
  rtx install $1@latest
  rtx global $1@latest
}

rtx_add nodejs
rtx_add golang
rtx_add lua
rtx_add python
rtx list | awk '{print $1 " " $2}' >~/.tool-versions

eval $(rtx env)

cd $CARGO_HOME

rm -rf config
mkdir -p ~/.cargo
touch ~/.cargo/config
ln -s ~/.cargo/config .

# 官方的neovim没编译python，所以用neovim-ppa/unstable

add-apt-repository -y ppa:neovim-ppa/unstable &&
  apt-get update &&
  apt-get install -y neovim

if ! [ -x "$(command -v czmod)" ]; then
  git clone --depth=1 https://github.com/skywind3000/czmod.git && cd czmod && ./build.sh && mv czmod /usr/local/bin && cd .. && rm -rf czmod
fi

export BUN_INSTALL=/opt/bun

[ $CN ] && export GITHUB=https://ghproxy.com/https://github.com

if [ ! -d "$BUN_INSTALL/bin/bun" ]; then
  $CURL https://ghproxy.com/https://raw.githubusercontent.com/oven-sh/bun/main/src/cli/install.sh | bash
  #$CURL https://bun.sh/install | bash
fi

if [ ! -f "$BUN_INSTALL/bin/bunx" ]; then
  ln -s /opt/bun/bin/bun /opt/bun/bin/bunx
fi

export BUN_INSTALL="/opt/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

bun install -g pnpm

pnpm install -g neovim npm-check-updates coffeescript node-pre-gyp \
  diff-so-fancy rome@next @antfu/ni prettier \
  @prettier/plugin-pug stylus-supremacy @w5/gitreset &

go install github.com/charmbracelet/glow@latest
go install mvdan.cc/sh/cmd/shfmt@latest
go install github.com/muesli/duf@master
go install github.com/louisun/heyspace@latest

if [ ! -s "/usr/bin/gist" ]; then
  ln -s /usr/bin/gist-paste /usr/bin/gist
fi

cd /usr/local &&
  wget https://cdn.jsdelivr.net/gh/junegunn/fzf/install -O fzf.install.sh &&
  yes | bash ./fzf.install.sh && rm ./fzf.install.sh && cd ~ &&
  echo 'PATH=/opt/rust/bin:$PATH' >>/etc/profile.d/path.sh

rsync -avI $ROOT/os/root/ /root

gfw_git

declare -A ZINIT
ZINIT_HOME=/opt/zinit/zinit.git
ZINIT[HOME_DIR]=/opt/zinit
ZPFX=/opt/zinit/polaris
mkdir -p /opt/zinit && git clone --depth=1 https://github.com/zdharma-continuum/zinit.git $ZINIT_HOME || true

cat /root/.zinit.zsh | grep --invert-match "^zinit ice" | zsh
/opt/zinit/plugins/romkatv---powerlevel10k/gitstatus/install
rsync -avI $ROOT/os/usr/share/nvim/ /usr/share/nvim
rsync -avI $ROOT/os/etc/vim/ /etc/vim

update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 1 &&
  update-alternatives --set vi /usr/bin/nvim &&
  update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 1 &&
  update-alternatives --set vim /usr/bin/nvim

update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 1 &&
  update-alternatives --set editor /usr/bin/nvim

$CURL -fLo /etc/vim/plug.vim --create-dirs https://cdn.jsdelivr.net/gh/junegunn/vim-plug/plug.vim
vi -E -s -u /etc/vim/sysinit.vim +PlugInstall +qa
vi +UpdateRemotePlugins +qa
vi +'CocInstall -sync coc-json coc-yaml coc-css coc-python coc-vetur coc-tabnine coc-svelte' +qa
find /etc/vim -type d -exec chmod 755 {} +

pip install --upgrade pip pylint python-language-server ipython xonsh pynvim ruff

ldconfig

ssh_ed25519=/root/.ssh/id_ed25519
if [ ! -f "$ssh_ed25519" ]; then
  ssh-keygen -t ed25519 -P "" -f $ssh_ed25519
fi

cd /
rsync -avI $ROOT/os/ /
rsync -avI $DIR/os/ /

gfw_git

useradd -s /usr/sbin/nologin -M ntpd-rs || true
systemctl daemon-reload && systemctl daemon-reexec
systemctl enable --now ntpd-rs

# 内存小于1GB不装 docker
mesize=$(cat /proc/meminfo | grep -oP '^MemTotal:\s+\K\d+' /proc/meminfo)
[ $mesize -gt 999999 ] && $DIR/init-docker.sh

sd -s "#cron.*" "cron.*" /etc/rsyslog.d/50-default.conf
systemctl restart rsyslog

# ipinfo=$(curl -s ipinfo.io)
#
# iporg=$(echo $ipinfo | jq -r ".org")
#
# case $iporg in
# *"Tencent"*) iporg=qq ;;
# *"Contabo"*) iporg=con ;;
# *"Alibaba"*) iporg=ali ;;
# *"Amazon"*) iporg=aws ;;
# *) iporg=any ;;
# esac

# ipaddr=$(echo $ipinfo | jq -r '.city' | dd conv=lcase 2>/dev/null | sed 's/\s//g')
#
# mem=$(expr $(free -m | sed -n '2p' | awk '{print $2}') / 1000)
#
# name=$iporg-${mem}g-$(date +'%Y%m%d')-$ipaddr

# echo $name

#hostnamectl set-hostname $name

apt-get autoremove -y

rm -rf /root/.cache/pip &&
  python -m pip cache purge &&
  go clean --cache &&
  npm cache clean -f &&
  apt-get clean -y

rm -rf $CARGO_HOME/registry &&
  cargo-cache --remove-dir git-repos,registry-sources &&
  cargo-cache -e

sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config
sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/g" /etc/ssh/sshd_config
service sshd reload || service ssh reload
apt autoremove -y

rm /etc/supervisord.conf
ln -s /etc/supervisor/supervisord.conf /etc/supervisord.conf

echo '👌 ✅'
