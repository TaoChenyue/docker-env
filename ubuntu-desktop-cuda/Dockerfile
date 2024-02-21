# Basic image
ARG BASIC_IMAGE=nvidia/cuda:11.8.0-devel-ubuntu22.04
FROM ${BASIC_IMAGE}

# Author info
LABEL maintainer="TaoChenyue"
LABEL maintainer-email="chenyue.Tao@qq.com"

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8
ENV TZ=Asia/Shanghai
RUN apt-get install -y locales \
    && locale-gen zh_CN.UTF-8

# Set build arguments
ARG DEBIAN_FRONTEND=noninteractive \
    PASSWORD=123456 
ENV PASSWORD=${PASSWORD}

# Set shell to bash
SHELL [ "/bin/bash", "-c"]
USER root
WORKDIR /root

# Change apt sources and upgrade and install basic tools
RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list \
    && sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list \
    && apt clean \
    && apt update \
    && apt upgrade -y \
    && apt install -y sudo curl wget git make net-tools 

# SSH
RUN apt install -y openssh-server openssh-client \
    && sed -ri 's|^#?PermitRootLogin\s+.*|PermitRootLogin yes|g' /etc/ssh/sshd_config \
    && sed -ri 's|^#?PasswordAuthentication\s+.*|PasswordAuthentication yes|g' /etc/ssh/sshd_config \
    && mkdir -p ~/.ssh && mkdir /run/sshd

# Tightvncserver and NoVNC
RUN apt install -y tightvncserver \
    && git clone https://github.com/novnc/noVNC.git ~/noVNC \
    && git clone https://github.com/kanaka/websockify ~/noVNC/utils/websockify 

# Xfce4
RUN apt install -y xfce4 xfce4-goodies xfce4-terminal \
    && apt -y remove xfce4-power-manage

####
# Applications
####

# Oh my bash
RUN git clone https://github.com/ohmybash/oh-my-bash.git ~/.oh-my-bash --depth 1 \
    && chmod +x ~/.oh-my-bash/oh-my-bash.sh \
    && cp ~/.bashrc ~/.bashrc.bak \
    && cp ~/.oh-my-bash/templates/bashrc.osh-template ~/.bashrc \
    && sed -ri 's|OSH_THEME="font"|OSH_THEME="agnoster"|g' ~/.bashrc \
    && apt install -y fonts-powerline 

# Ble.sh
RUN git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git \
    && apt install -y gawk \
    && make -C ble.sh install PREFIX=~/.local \
    && echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc

# Clash
RUN git clone https://github.com/Elegycloud/clash-for-linux-backup.git ~/clash-for-linux 

# NVM
RUN git clone https://github.com/nvm-sh/nvm.git ~/.nvm \
    && cd ~/.nvm && git checkout v0.39.7 && source ./nvm.sh \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.bashrc \
    && bash -c 'source $HOME/.nvm/nvm.sh && nvm install --lts && nvm use --lts'

# NeoVim
RUN wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz \
    && tar xzvf nvim-linux64.tar.gz \
    && mv nvim-linux64 /usr/local/nvim \
    && sudo ln -s /usr/local/nvim/bin/nvim /usr/bin/nvim

# Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && ~/miniconda3/bin/conda init

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 

# Lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && install lazygit /usr/local/bin

# LunarVim
RUN LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)

# Microsoft Edge
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644  microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && rm microsoft.gpg \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" \
    | sudo tee /etc/apt/sources.list.d/microsoft-edge-dev.list \
    && apt update \
    && apt install -y microsoft-edge-dev

COPY ./start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 22 5901 6081

ENTRYPOINT ["/bin/bash","-c","/start.sh" ]
