FROM ubuntu:22.04
# FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Author info
LABEL maintainer="TaoChenyue"
LABEL maintainer-email="chenyue.Tao@qq.com"

# Set environment variables
ARG PASSWORD=000000 \
    DEBIAN_FRONTEND=noninteractive \
    GITHUB_PROXY=https://ghproxy.org/ \
    NVM_GITHUB_REPO=${GITHUB_PROXY}https://github.com/nvm-sh/nvm.git 
ENV TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=${LANG} \
    LANGUAGE=${LANG}

COPY ./startup.sh /startup.sh
# Change password
RUN echo "root:${PASSWORD}" | chpasswd && \
    # Change apt sources
    sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list && \
    apt clean && apt update && apt upgrade -y && \
    # Install basic tools
    apt install -y vim net-tools wget curl git make ripgrep  && \
    # SSH
    apt install -y openssh-server openssh-client && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir -p ~/.ssh && mkdir /run/sshd && \
    # NeoVim
    wget ${GITHUB_PROXY}https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz && \
    tar -xzvf ./nvim-linux64.tar.gz && \
    ln -s ./nvim-linux64/bin/nvim /usr/bin/nvim && \
    # Nvm
    curl -o- ${GITHUB_PROXY}https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \ 
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
    nvm install --lts && nvm use --lts && \
    # Miniconda(export base env path temporarily)
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash ./Miniconda3-latest-Linux-x86_64.sh -b && \
    ~/miniconda3/bin/conda init && export PATH=~/miniconda3/bin:$PATH && \
    # ripgrep
    # curl -LO ${GITHUB_PROXY}https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb && \
    # dpkg -i ripgrep_13.0.0_amd64.deb && \
    # Rust
    curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh && \
    # lazygit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "${GITHUB_PROXY}https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin && \
    # LunarVim
    LV_BRANCH='release-1.3/neovim-0.9' && \
    wget ${GITHUB_PROXY}https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh -O ./install_lunarvim.sh && \
    sed -i "s/https:\/\/github.com/${GITHUB_PROXY}https:\/\/github.com/g" ./install_lunarvim.sh && \
    bash ./install_lunarvim.sh && rm ./install_lunarvim.sh\
    # Run startup scripts
    chmod +x /startup.sh
EXPOSE 22
ENTRYPOINT [ "/startup.sh" ]