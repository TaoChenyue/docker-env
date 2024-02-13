FROM ubuntu:22.04
# FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Author info
LABEL maintainer="TaoChenyue"
LABEL maintainer-email="chenyue.Tao@qq.com"

# Set environment variables
ARG PASSWORD=000000 \
    DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Shanghai 

WORKDIR /

SHELL [ "/bin/bash", "-c"]

RUN add-apt-repository ppa:lazygit-team/release && \
    apt update && apt upgrade -y && \
    apt install -y vim wget curl git make ripgrep lazygit && \
    # Oh my bash
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" && \
    apt install -y fonts-powerline && \
    sed -ri 's|OSH_THEME="font"|OSH_THEME="agnoster"|g' ~/.bashrc && \
    # Ble.sh
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git && \
    make -C ble.sh install PREFIX=~/.local && \
    echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc && \
    # SSH
    apt install -y openssh-server openssh-client && \
    sed -ri 's|^#?PermitRootLogin\s+.*|PermitRootLogin yes|g' /etc/ssh/sshd_config && \
    sed -ri 's|^#?PasswordAuthentication\s+.*|PasswordAuthentication yes|g' /etc/ssh/sshd_config && \
    mkdir -p ~/.ssh && mkdir /run/sshd && \
    # NeoVim
    wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz && \
    tar xzvf nvim-linux64.tar.gz && \
    ln -s nvim-linux64/bin/nvim /usr/bin/nvim && \
    # LunarVim
    LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh) && \
    # Nvm
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    source ~/.bashrc && \
    nvm install --lts && nvm use --lts && \
    # Miniconda(export base env path temporarily)
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b && \
    ~/miniconda3/bin/conda init && \
    export PATH=~/miniconda3/bin:$PATH && \
    # Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

EXPOSE 22

ENTRYPOINT ["/bin/bash","-c","/usr/sbin/sshd -D" ]
