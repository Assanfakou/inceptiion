#!/bin/bash

useradd -m $FTP_USER

echo "$FTP_USER:$FTP_PASS" | chpasswd

exec vsftpd /etc/vsftp.conf
