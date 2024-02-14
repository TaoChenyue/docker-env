FROM ubuntu:22.04
# FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Author info
LABEL maintainer="TaoChenyue"
LABEL maintainer-email="chenyue.Tao@qq.com"

# Set environment variables
ARG PASSWORD=000000 \
    DEBIAN_FRONTEND=noninteractive \
    GITHUB_PROXY=https://ghproxy.org/

ENV TZ=Asia/Shanghai 

WORKDIR /

SHELL [ "/bin/bash", "-c"]

# Change apt sources
RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list && \
    apt clean && apt update && apt upgrade -y && \
    apt install -y vim wget curl git make ripgrep gawk 
# Oh my bash
RUN bash -c "$(curl -fsSL ${GITHUB_PROXY}https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" && \
    apt install -y fonts-powerline && \
    sed -ri 's|OSH_THEME="font"|OSH_THEME="agnoster"|g' ~/.bashrc 
# Ble.sh
RUN git clone --recursive --depth 1 --shallow-submodules ${GITHUB_PROXY}https://github.com/akinomyoga/ble.sh.git && \
    make -C ble.sh install PREFIX=~/.local && \
    echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc
# SSH
RUN apt install -y openssh-server openssh-client && \
    sed -ri 's|^#?PermitRootLogin\s+.*|PermitRootLogin yes|g' /etc/ssh/sshd_config && \
    sed -ri 's|^#?PasswordAuthentication\s+.*|PasswordAuthentication yes|g' /etc/ssh/sshd_config && \
    mkdir -p ~/.ssh && mkdir /run/sshd
# NeoVim
RUN wget ${GITHUB_PROXY}https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz && \
    tar xzvf nvim-linux64.tar.gz && \
    ln -s nvim-linux64/bin/nvim /usr/bin/nvim
# Nvm
RUN curl -o- ${GITHUB_PROXY}https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  && \
    nvm install --lts && nvm use --lts 
# Miniconda(export base env path temporarily)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b && \
    ~/miniconda3/bin/conda init && \
    export PATH=~/miniconda3/bin:$PATH
# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 
# Lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "${GITHUB_PROXY}https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin
# LunarVim
RUN LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s ${GITHUB_PROXY}https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)

EXPOSE 22

ENTRYPOINT ["/bin/bash","-c","/usr/sbin/sshd -D" ]
