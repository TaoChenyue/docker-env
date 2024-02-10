#!/bin/bash
# PASSWORD
if [ $PASSWD ]; then
    echo "root:$PASSWD" | chpasswd
fi
# SSH
/usr/sbin/sshd -D
