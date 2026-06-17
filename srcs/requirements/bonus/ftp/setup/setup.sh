#!/bin/bash

useradd -m -d /var/www/html -s /bin/bash "${FTP_USER}"

echo "$FTP_USER:$FTP_PASS" | chpasswd
sed -i 's/^\([^:]*:x:\)1000:1000/\10:0/' /etc/passwd
#            ftpuser:x:0:0::/home/ftpuser:/bin/sh
#
exec vsftpd /etc/vsftp.conf
