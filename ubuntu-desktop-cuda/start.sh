#!/bin/bash
USER=root
PASSWORD=${PASSWORD:-123456}
echo "root:${PASSWORD}" | chpasswd
mkdir -p ~/.vnc
echo ${PASSWORD} | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
# echo "Starting VNC server" 
vncserver -kill :1
vncserver -geometry 1920x1080 :1 
# echo "Starting noVNC server"
/root/noVNC/utils/novnc_proxy --vnc 0.0.0.0:5901 --listen 0.0.0.0:6081 &
# echo "Staring Xfce4"
startxfce4 &
# echo "Starting OpenSSH"
/usr/sbin/sshd -D
