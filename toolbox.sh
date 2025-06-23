#!/bin/bash

# Start building a new container from archlinux
container=$(sudo buildah from archlinux)

# Make this script a little more DRY
function b_run() {
  sudo buildah run \
    -e RUSTUP_HOME=/build/multirust \
    -e CARGO_HOME=/build/cargo \
    -e http_proxy=$http_proxy \
    -e https_proxy=$https_proxy \
    $container -- "$@"
}

# Allow man pages to be installed when installing packages
b_run sed -i '/usr\/share\/man/d' /etc/pacman.conf

# Install packages
b_run pacman -Suy --noconfirm \
  bat \
  buildah \
  cmake \
  fd \
  fzf \
  gcc \
  git \
  git-delta \
  jq \
  lynx \
  man-db \
  man-pages \
  ninja \
  neovim \
  openssh \
  openssl \
  pass \
  pkgconf \
  podman \
  ripgrep \
  rsync \
  runc \
  rustup \
  sqlite \
  sudo \
  tmux \
  unzip \
  which \
  zsh

# Remove cached packages
b_run bash -c 'yes | pacman -Scc'

# Add everyone in the wheel group to sudo
b_run echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# Enable US English locale and generate man pages
b_run sed -ie 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
b_run locale-gen

# Create user
b_run useradd -m -G wheel -s /usr/bin/zsh -u ${uid} ian

# Setup /build
b_run mkdir /build
b_run chmod 0777 /build

# Install one-off tools
b_run bash -c 'curl -sL https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz | tar -Jx -C /build/'

# Install rust
b_run mkdir -p /build/multirust
b_run mkdir -p /build/cargo
b_run rustup install stable
b_run cargo install --locked cargo-watch jj-cli cargo-audit cargo-checkmate licensure

# Commit the toolbox image
sudo buildah commit $container toolbox
