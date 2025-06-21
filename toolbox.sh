#!/bin/bash

# Start building a new container from archlinux
container=$(sudo buildah from archlinux)

# Allow man pages to be installed
sudo buildah run $container -- sed -i '/usr\/share\/man/d' /etc/pacman.conf

# Install packages
sudo buildah run $container -- pacman -Suy --noconfirm \
  bat \
  buildah \
  fzf \
  gcc \
  git \
  jq \
  lynx \
  man-db \
  man-pages \
  neovim \
  openssh \
  pass \
  ripgrep \
  rsync \
  runc \
  rustup \
  sudo \
  tmux \
  unzip \
  zsh

# Remove cached packages
sudo buildah run $container -- bash -c 'yes | pacman -Scc'

# Enable US English locale and generate man pages
sudo buildah run $container -- sed -ie 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sudo buildah run $container -- locale-gen

# Install rust
sudo buildah run $container -- mkdir -p /build/multirust
sudo buildah run $container -- mkdir -p /build/cargo
sudo buildah run -e RUSTUP_HOME=/build/multirust $container -- rustup install stable
sudo buildah run -e RUSTUP_HOME=/build/multirust -e CARGO_HOME=/build/cargo $container -- cargo install --locked cargo-watch jj-cli cargo-audit

# Commit the toolbox image
sudo buildah commit $container toolbox
