#!/bin/bash
#
# Updated for $.broswer-msie error; will populate tracker list properly ; create check/start scripts; 
# create crontab entries. Rest is all perfect from Notos. Thanks.
#
# The Seedbox From Scratch Script
#   By Notos ---> https://github.com/Notos/
#     Modified by dannyti ---> https://github.com/dannyti/
#
######################################################################
#
#  Copyright (c) 2013 Notos (https://github.com/Notos/) & dannyti (https://github.com/dannyti/)
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
#
#  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#  --> Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
#
######################################################################
#
#
apt-get --yes install lsb-release
SBFSCURRENTVERSION1=14.06
OS1=$(lsb_release -si)
OSV1=$(lsb_release -rs)
OSV11=$(sed 's/\..*//' /etc/debian_version)
logfile="/dev/null"
#
#
#
######################################################################
#
#
#
######################################################################
#
#
#
######################################################################
#
#
#
######################################################################
#
#
#
######################################################################
#
#
function getString
{
  local ISPASSWORD=$1
  local LABEL=$2
  local RETURN=$3
  local DEFAULT=$4
  local NEWVAR1=a
  local NEWVAR2=b
  local YESYES=YESyes
  local NONO=NOno
  local YESNO=$YESYES$NONO

  while [ ! $NEWVAR1 = $NEWVAR2 ] || [ -z "$NEWVAR1" ];
  do
    clear
    echo "#"
    echo "#"
    echo "# The Seedbox From Scratch Script"
    echo "#   By Notos ---> https://github.com/Notos/"
    echo "#   Modified by dannyti ---> https://github.com/dannyti/"
    echo "#"
    echo "#"
    echo

    if [ "$ISPASSWORD" == "YES" ]; then
      read -s -p "$DEFAULT" -p "$LABEL" NEWVAR1
    else
      read -e -i "$DEFAULT" -p "$LABEL" NEWVAR1
    fi
    if [ -z "$NEWVAR1" ]; then
      NEWVAR1=a
      continue
    fi

    if [ ! -z "$DEFAULT" ]; then
      if grep -q "$DEFAULT" <<< "$YESNO"; then
        if grep -q "$NEWVAR1" <<< "$YESNO"; then
          if grep -q "$NEWVAR1" <<< "$YESYES"; then
            NEWVAR1=YES
          else
            NEWVAR1=NO
          fi
        else
          NEWVAR1=a
        fi
      fi
    fi

    if [ "$NEWVAR1" == "$DEFAULT" ]; then
      NEWVAR2=$NEWVAR1
    else
      if [ "$ISPASSWORD" == "YES" ]; then
        echo
        read -s -p "Retype: " NEWVAR2
      else
        read -p "Retype: " NEWVAR2
      fi
      if [ -z "$NEWVAR2" ]; then
        NEWVAR2=b
        continue
      fi
    fi


    if [ ! -z "$DEFAULT" ]; then
      if grep -q "$DEFAULT" <<< "$YESNO"; then
        if grep -q "$NEWVAR2" <<< "$YESNO"; then
          if grep -q "$NEWVAR2" <<< "$YESYES"; then
            NEWVAR2=YES
          else
            NEWVAR2=NO
          fi
        else
          NEWVAR2=a
        fi
      fi
    fi
    echo "---> $NEWVAR2"

  done
  eval $RETURN=\$NEWVAR1
}
# 0.

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

clear

# 1.

#localhost is ok this rtorrent/rutorrent installation
IPADDRESS1=`ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1`
CHROOTJAIL1=NO

#those passwords will be changed in the next steps
PASSWORD1=a
PASSWORD2=b

getString NO  "You need to create an user for your seedbox: " NEWUSER1
getString YES "Password for user $NEWUSER1: " PASSWORD1
getString NO  "IP address of your box: " IPADDRESS1 $IPADDRESS1
getString NO  "SSH port: " NEWSSHPORT1 21976
getString NO  "vsftp port (usually 21): " NEWFTPPORT1 21201
getString NO  "OpenVPN port: " OPENVPNPORT1 31195
#getString NO  "Do you want to have some of your users in a chroot jail? " CHROOTJAIL1 YES
getString NO "Is this Single User Seedbox? " SINGLEUSER1 YES
getString NO  "Install Webmin? " INSTALLWEBMIN1 YES
getString NO  "Install Fail2ban? " INSTALLFAIL2BAN1 YES
getString NO  "Install OpenVPN? " INSTALLOPENVPN1 NO
getString NO  "Install SABnzbd? " INSTALLSABNZBD1 NO
getString NO  "Install Rapidleech? " INSTALLRAPIDLEECH1 NO
getString NO  "Install Deluge? " INSTALLDELUGE1 NO
getString NO  "Wich RTorrent version would you like to install, '0.9.2' or '0.9.3' or '0.9.4'? " RTORRENT1 0.9.4


if [ "$RTORRENT1" != "0.9.3" ] && [ "$RTORRENT1" != "0.9.2" ] && [ "$RTORRENT1" != "0.9.4" ]; then
  echo "$RTORRENT1 typed is not 0.9.4 or 0.9.3 or 0.9.2!"
  exit 1
fi

if [ "$OSV1" = "14.04" ]; then
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
fi
echo "........"
echo "............."
echo "Work in Progres..........   "
echo "Please Standby................   "
apt-get --yes update >> $logfile 2>&1
apt-get --yes install whois sudo makepasswd git nano >> $logfile 2>&1

rm -f -r /etc/seedbox-from-scratch
git clone -b v$SBFSCURRENTVERSION1 https://github.com/dannyti/seedbox-from-scratch.git /etc/seedbox-from-scratch >> $logfile 2>&1
mkdir -p cd /etc/seedbox-from-scratch/source
mkdir -p cd /etc/seedbox-from-scratch/users

if [ ! -f /etc/seedbox-from-scratch/seedbox-from-scratch.sh ]; then
  clear
  echo Looks like something is wrong, this script was not able to download its whole git repository.
  set -e
  exit 1
fi

# 3.1

#show all commands
set -x verbose

# 4.
perl -pi -e "s/Port 22/Port $NEWSSHPORT1/g" /etc/ssh/sshd_config
perl -pi -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
perl -pi -e "s/#Protocol 2/Protocol 2/g" /etc/ssh/sshd_config
perl -pi -e "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config

groupadd sshdusers
groupadd sftponly

mkdir -p /usr/share/terminfo/l/
cp /lib/terminfo/l/linux /usr/share/terminfo/l/
#echo '/usr/lib/openssh/sftp-server' >> /etc/shells
if [ "$OS1" = "Ubuntu" ]; then
  echo "" | tee -a /etc/ssh/sshd_config > /dev/null
  echo "UseDNS no" | tee -a /etc/ssh/sshd_config > /dev/null
  echo "AllowGroups sshdusers root" >> /etc/ssh/sshd_config
  echo "Match Group sftponly" >> /etc/ssh/sshd_config
  echo "ChrootDirectory %h" >> /etc/ssh/sshd_config
  echo "ForceCommand internal-sftp" >> /etc/ssh/sshd_config
  echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
fi

service ssh reload

# 6.
#remove cdrom from apt so it doesn't stop asking for it
perl -pi -e "s/deb cdrom/#deb cdrom/g" /etc/apt/sources.list
perl -pi.orig -e 's/^(deb .* universe)$/$1 multiverse/' /etc/apt/sources.list
#add non-free sources to Debian Squeeze# those two spaces below are on purpose
perl -pi -e "s/squeeze main/squeeze  main contrib non-free/g" /etc/apt/sources.list
perl -pi -e "s/squeeze-updates main/squeeze-updates  main contrib non-free/g" /etc/apt/sources.list

#apt-get --yes install python-software-properties
#Adding debian pkgs for adding repo and installing ffmpeg
apt-get --yes install software-properties-common
if [ "$OSV11" = "8" ]; then
  apt-add-repository --yes "deb http://www.deb-multimedia.org jessie main non-free"
  apt-get update >> $logfile 2>&1
  apt-get --force-yes --yes install ffmpeg >> $logfile 2>&1
fi

# 7.
# update and upgrade packages
apt-get --yes install python-software-properties software-properties-common
if [ "$OSV1" = "14.04" ] || [ "$OSV1" = "15.04" ] || [ "$OSV1" = "14.10" ]; then
  apt-add-repository --yes ppa:kirillshkrogalev/ffmpeg-next
fi
apt-get --yes update >> $logfile 2>&1
apt-get --yes upgrade >> $logfile 2>&1
# 8.
#install all needed packages
apt-get --yes install apache2 apache2-utils autoconf build-essential ca-certificates comerr-dev curl cfv quota mktorrent dtach htop irssi libapache2-mod-php5 libcloog-ppl-dev libcppunit-dev libcurl3 libcurl4-openssl-dev libncurses5-dev libterm-readline-gnu-perl libsigc++-2.0-dev libperl-dev openvpn libssl-dev libtool libxml2-dev ncurses-base ncurses-term ntp openssl patch libc-ares-dev pkg-config php5 php5-cli php5-dev php5-curl php5-geoip php5-mcrypt php5-gd php5-xmlrpc pkg-config python-scgi screen ssl-cert subversion texinfo unzip zlib1g-dev expect flex bison debhelper binutils-gold libarchive-zip-perl libnet-ssleay-perl libhtml-parser-perl libxml-libxml-perl libjson-perl libjson-xs-perl libxml-libxslt-perl libxml-libxml-perl libjson-rpc-perl libarchive-zip-perl tcpdump >> $logfile 2>&1
if [ $? -gt 0 ]; then
  set +x verbose
  echo
  echo
  echo *** ERROR ***
  echo
  echo "Looks like something is wrong with apt-get install, aborting."
  echo
  echo
  echo
  set -e
  exit 1
fi
apt-get --yes install zip >> $logfile 2>&1

apt-get --yes install ffmpeg >> $logfile 2>&1
apt-get --yes install automake1.9

apt-get --force-yes --yes install rar
if [ $? -gt 0 ]; then
  apt-get --yes install rar-free
fi

apt-get --yes install unrar
if [ $? -gt 0 ]; then
  apt-get --yes install unrar-free
fi
if [ "$OSV1" = "8.1" ]; then
  apt-get --yes install unrar-free 
fi

apt-get --yes install dnsutils

if [ "$CHROOTJAIL1" = "YES" ]; then
  cd /etc/seedbox-from-scratch
  tar xvfz jailkit-2.15.tar.gz -C /etc/seedbox-from-scratch/source/
  cd source/jailkit-2.15
  ./debian/rules binary
  cd ..
  dpkg -i jailkit_2.15-1_*.deb
fi

# 8.1 additional packages for Ubuntu
# this is better to be apart from the others
apt-get --yes install php5-fpm >> $logfile 2>&1
apt-get --yes install php5-xcache libxml2-dev >> $logfile 2>&1

if [ "$OSV1" = "13.10" ]; then
  apt-get install php5-json
fi

#Check if its Debian and do a sysvinit by upstart replacement:
#Commented the follwoing three lines for testing
#if [ "$OS1" = "Debian" ]; then
#  echo 'Yes, do as I say!' | apt-get -y --force-yes install upstart
#fi

# 8.3 Generate our lists of ports and RPC and create variables

#permanently adding scripts to PATH to all users and root
echo "PATH=$PATH:/etc/seedbox-from-scratch:/sbin" | tee -a /etc/profile > /dev/null
echo "export PATH" | tee -a /etc/profile > /dev/null
echo "PATH=$PATH:/etc/seedbox-from-scratch:/sbin" | tee -a /root/.bashrc > /dev/null
echo "export PATH" | tee -a /root/.bashrc > /dev/null

rm -f /etc/seedbox-from-scratch/ports.txt
for i in $(seq 51101 51999)
do
  echo "$i" | tee -a /etc/seedbox-from-scratch/ports.txt > /dev/null
done

rm -f /etc/seedbox-from-scratch/rpc.txt
for i in $(seq 2 1000)
do
  echo "RPC$i"  | tee -a /etc/seedbox-from-scratch/rpc.txt > /dev/null
done

# 8.4

if [ "$INSTALLWEBMIN1" = "YES" ]; then
  #if webmin isup, download key
  WEBMINDOWN=YES
  ping -c1 -w2 www.webmin.com > /dev/null
  if [ $? = 0 ] ; then
    wget -t 5 http://www.webmin.com/jcameron-key.asc
    apt-key add jcameron-key.asc
    if [ $? = 0 ] ; then
      WEBMINDOWN=NO
    fi
  fi

  if [ "$WEBMINDOWN"="NO" ] ; then
    #add webmin source
    echo "" | tee -a /etc/apt/sources.list > /dev/null
    echo "deb http://download.webmin.com/download/repository sarge contrib" | tee -a /etc/apt/sources.list > /dev/null
    cd /tmp
  fi

  if [ "$WEBMINDOWN" = "NO" ]; then
    apt-get --yes update >> $logfile 2>&1
    apt-get --yes install webmin >> $logfile 2>&1
  fi
fi

if [ "$INSTALLFAIL2BAN1" = "YES" ]; then
  apt-get --yes install fail2ban >> $logfile 2>&1
  cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.original
  cp /etc/seedbox-from-scratch/etc.fail2ban.jail.conf.template /etc/fail2ban/jail.conf
  fail2ban-client reload
fi

# 9.
a2enmod ssl
a2enmod auth_digest
a2enmod reqtimeout
a2enmod rewrite
#a2enmod scgi ############### if we cant make python-scgi works
#cd /etc/apache2
#rm apache2.conf
#wget --no-check-certificate https://raw.githubusercontent.com/dannyti/sboxsetup/master/apache2.conf
cat /etc/seedbox-from-scratch/add2apache2.conf >> /etc/apache2/apache2.conf
# 10.

#remove timeout if  there are any
perl -pi -e "s/^Timeout [0-9]*$//g" /etc/apache2/apache2.conf

echo "" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "#seedbox values" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "ServerSignature Off" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "ServerTokens Prod" | tee -a /etc/apache2/apache2.conf > /dev/null
echo "Timeout 30" | tee -a /etc/apache2/apache2.conf > /dev/null
cd /etc/apache2
rm ports.conf
wget --no-check-certificate https://raw.githubusercontent.com/dannyti/sboxsetup/master/ports.conf >> $logfile 2>&1
service apache2 restart
mkdir /etc/apache2/auth.users 

echo "$IPADDRESS1" > /etc/seedbox-from-scratch/hostname.info

# 11.

export TEMPHOSTNAME1=tsfsSeedBox
export CERTPASS1=@@$TEMPHOSTNAME1.$NEWUSER1.ServerP7s$
export NEWUSER1
export IPADDRESS1

echo "$NEWUSER1" > /etc/seedbox-from-scratch/mainuser.info
echo "$CERTPASS1" > /etc/seedbox-from-scratch/certpass.info

bash /etc/seedbox-from-scratch/createOpenSSLCACertificate 

mkdir -p /etc/ssl/private/
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem -config /etc/seedbox-from-scratch/ssl/CA/caconfig.cnf

if [ "$OSV11" = "7" ]; then
  echo "deb http://ftp.cyconet.org/debian wheezy-updates main non-free contrib" >> /etc/apt/sources.list.d/wheezy-updates.cyconet.list
  apt-get update
  apt-get install -y --force-yes -t wheezy-updates debian-cyconet-archive-keyring vsftpd libxml2-dev libcurl4-gnutls-dev subversion >> $logfile 2>&1
elif [ "$OSV1" = "12.04" ]; then
  add-apt-repository -y ppa:thefrontiergroup/vsftpd
  apt-get update
  apt-get -y install vsftpd
else
  apt-get -y install vsftpd
fi


#if [ "$OSV1" = "12.04" ]; then
#  dpkg -i /etc/seedbox-from-scratch/vsftpd_2.3.2-3ubuntu5.1_`uname -m`.deb
#fi

perl -pi -e "s/anonymous_enable\=YES/\#anonymous_enable\=YES/g" /etc/vsftpd.conf
perl -pi -e "s/connect_from_port_20\=YES/#connect_from_port_20\=YES/g" /etc/vsftpd.conf
perl -pi -e 's/rsa_private_key_file/#rsa_private_key_file/' /etc/vsftpd.conf
perl -pi -e 's/rsa_cert_file/#rsa_cert_file/' /etc/vsftpd.conf
#perl -pi -e "s/rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem/#rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem/g" /etc/vsftpd.conf
#perl -pi -e "s/rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key/#rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key/g" /etc/vsftpd.conf
echo "listen_port=$NEWFTPPORT1" | tee -a /etc/vsftpd.conf >> /dev/null
echo "ssl_enable=YES" | tee -a /etc/vsftpd.conf >> /dev/null
echo "allow_anon_ssl=YES" | tee -a /etc/vsftpd.conf >> /dev/null
echo "force_local_data_ssl=NO" | tee -a /etc/vsftpd.conf >> /dev/null
echo "force_local_logins_ssl=NO" | tee -a /etc/vsftpd.conf >> /dev/null
echo "ssl_tlsv1=YES" | tee -a /etc/vsftpd.conf >> /dev/null
echo "ssl_sslv2=NO" | tee -a /etc/vsftpd.conf >> /dev/null
echo "ssl_sslv3=NO" | tee -a /etc/vsftpd.conf >> /dev/null
echo "require_ssl_reuse=NO" | tee -a /etc/vsftpd.conf >> /dev/null
echo "ssl_ciphers=HIGH" | tee -a /etc/vsftpd.conf >> /dev/null
echo "rsa_cert_file=/etc/ssl/private/vsftpd.pem" | tee -a /etc/vsftpd.conf >> /dev/null
echo "local_enable=YES" | tee -a /etc/vsftpd.conf >> /dev/null
echo "write_enable=YES" | tee -a /etc/vsftpd.conf >> /dev/null
echo "local_umask=022" | tee -a /etc/vsftpd.conf >> /dev/null
echo "chroot_local_user=YES" | tee -a /etc/vsftpd.conf >> /dev/null
echo "chroot_list_file=/etc/vsftpd.chroot_list" | tee -a /etc/vsftpd.conf >> /dev/null
echo "passwd_chroot_enable=YES" | tee -a /etc/vsftpd.conf >> /dev/null
echo "allow_writeable_chroot=YES" | tee -a /etc/vsftpd.conf >> /dev/null
#sed -i '147 d' /etc/vsftpd.conf
#sed -i '149 d' /etc/vsftpd.conf

apt-get install --yes subversion >> $logfile 2>&1
apt-get install --yes dialog >> $logfile 2>&1
# 13.

if [ "$OSV1" = "14.04" ] || [ "$OSV1" = "14.10" ] || [ "$OSV1" = "15.04" ] || [ "$OSV11" = "8" ]; then
  cp /var/www/html/index.html /var/www/index.html 
  mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.ORI
  rm -f /etc/apache2/sites-available/000-default.conf
  cp /etc/seedbox-from-scratch/etc.apache2.default.template /etc/apache2/sites-available/000-default.conf
  perl -pi -e "s/http\:\/\/.*\/rutorrent/http\:\/\/$IPADDRESS1\/rutorrent/g" /etc/apache2/sites-available/000-default.conf
  perl -pi -e "s/<servername>/$IPADDRESS1/g" /etc/apache2/sites-available/000-default.conf
  perl -pi -e "s/<username>/$NEWUSER1/g" /etc/apache2/sites-available/000-default.conf
else
  mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.ORI
  rm -f /etc/apache2/sites-available/default
  cp /etc/seedbox-from-scratch/etc.apache2.default.template /etc/apache2/sites-available/default
  perl -pi -e "s/http\:\/\/.*\/rutorrent/http\:\/\/$IPADDRESS1\/rutorrent/g" /etc/apache2/sites-available/default
  perl -pi -e "s/<servername>/$IPADDRESS1/g" /etc/apache2/sites-available/default
  perl -pi -e "s/<username>/$NEWUSER1/g" /etc/apache2/sites-available/default
fi
#mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.ORI
#rm -f /etc/apache2/sites-available/default
#cp /etc/seedbox-from-scratch/etc.apache2.default.template /etc/apache2/sites-available/default
#perl -pi -e "s/http\:\/\/.*\/rutorrent/http\:\/\/$IPADDRESS1\/rutorrent/g" /etc/apache2/sites-available/default
#perl -pi -e "s/<servername>/$IPADDRESS1/g" /etc/apache2/sites-available/default
#perl -pi -e "s/<username>/$NEWUSER1/g" /etc/apache2/sites-available/default

echo "ServerName $IPADDRESS1" | tee -a /etc/apache2/apache2.conf > /dev/null

# 14.
a2ensite default-ssl
#ln -s /etc/apache2/mods-available/scgi.load /etc/apache2/mods-enabled/scgi.load
#service apache2 restart
#apt-get --yes install libxmlrpc-core-c3-dev

#14.1 Download xmlrpc, rtorrent & libtorrent for 0.9.4
#cd
#svn co https://svn.code.sf.net/p/xmlrpc-c/code/stable /etc/seedbox-from-scratch/source/xmlrpc
cd /etc/seedbox-from-scratch/
#wget -c http://libtorrent.rakshasa.no/downloads/rtorrent-0.9.4.tar.gz
#wget -c http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.4.tar.gz
wget -c http://pkgs.fedoraproject.org/repo/pkgs/rtorrent/rtorrent-0.9.4.tar.gz/fd9490a2ac67d0fa2a567c6267845876/rtorrent-0.9.4.tar.gz >> $logfile 2>&1
wget -c http://pkgs.fedoraproject.org/repo/pkgs/libtorrent/libtorrent-0.13.4.tar.gz/e82f380a9d4b55b379e0e73339c73895/libtorrent-0.13.4.tar.gz >> $logfile 2>&1

#configure & make xmlrpc BASED ON RTORRENT VERSION
if [ "$RTORRENT1" = "0.9.4" ]; then
  tar xvfz /etc/seedbox-from-scratch/xmlrpc-c-1.33.17.tgz -C /etc/seedbox-from-scratch/ >> $logfile 2>&1
  cd /etc/seedbox-from-scratch/xmlrpc-c-1.33.17
  ./configure --prefix=/usr --enable-libxml2-backend --disable-libwww-client --disable-wininet-client --disable-abyss-server --disable-cgi-server >> $logfile 2>&1
  make -j$(grep -c ^processor /proc/cpuinfo) >> $logfile 2>&1
  make install >> $logfile 2>&1
else
  tar xvfz /etc/seedbox-from-scratch/xmlrpc-c-1.16.42.tgz -C /etc/seedbox-from-scratch/source/ >> $logfile 2>&1
  cd /etc/seedbox-from-scratch/source/
  unzip ../xmlrpc-c-1.31.06.zip >> $logfile 2>&1
  cd xmlrpc-c-1.31.06
  ./configure --prefix=/usr --enable-libxml2-backend --disable-libwww-client --disable-wininet-client --disable-abyss-server --disable-cgi-server >> $logfile 2>&1
  make -j$(grep -c ^processor /proc/cpuinfo) >> $logfile 2>&1
  make install >> $logfile 2>&1
fi
# 15.


# 16.
#cd xmlrpc-c-1.16.42 ### old, but stable, version, needs a missing old types.h file
#ln -s /usr/include/curl/curl.h /usr/include/curl/types.h


# 21.
bash /etc/seedbox-from-scratch/installRTorrent $RTORRENT1 >> $logfile 2>&1

######### Below this /var/www/rutorrent/ has been replaced with /var/www/rutorrent for Ubuntu 14.04

# 22.
cd /var/www/
rm -f -r rutorrent
svn checkout https://github.com/Novik/ruTorrent/trunk rutorrent >> $logfile 2>&1
#svn checkout http://rutorrent.googlecode.com/svn/trunk/plugins
#rm -r -f rutorrent/plugins
#mv plugins rutorrent/

cp /etc/seedbox-from-scratch/action.php.template /var/www/rutorrent/plugins/diskspace/action.php

groupadd admin

echo "www-data ALL=(root) NOPASSWD: /usr/sbin/repquota" | tee -a /etc/sudoers > /dev/null

cp /etc/seedbox-from-scratch/favicon.ico /var/www/

# 26. Installing Mediainfo from source
apt-get install --yes mediainfo
if [ $? -gt 0 ]; then
  cd /tmp
  wget http://downloads.sourceforge.net/mediainfo/MediaInfo_CLI_0.7.56_GNU_FromSource.tar.bz2 >> $logfile 2>&1
  tar jxvf MediaInfo_CLI_0.7.56_GNU_FromSource.tar.bz2 >> $logfile 2>&1
  cd MediaInfo_CLI_GNU_FromSource/
  sh CLI_Compile.sh >> $logfile 2>&1
  cd MediaInfo/Project/GNU/CLI
  make install >> $logfile 2>&1
fi

cd /var/www/rutorrent/js/
git clone https://github.com/gabceb/jquery-browser-plugin.git >> $logfile 2>&1
mv jquery-browser-plugin/dist/jquery.browser.js .
rm -r -f jquery-browser-plugin
sed -i '31i\<script type=\"text/javascript\" src=\"./js/jquery.browser.js\"></script> ' /var/www/rutorrent/index.html

cd /var/www/rutorrent/plugins
git clone https://github.com/autodl-community/autodl-rutorrent.git autodl-irssi >> $logfile 2>&1
#cp autodl-irssi/_conf.php autodl-irssi/conf.php
#svn co https://svn.code.sf.net/p/autodl-irssi/code/trunk/rutorrent/autodl-irssi/
cd autodl-irssi


# 30. 
cp /etc/jailkit/jk_init.ini /etc/jailkit/jk_init.ini.original
echo "" | tee -a /etc/jailkit/jk_init.ini >> /dev/null
bash /etc/seedbox-from-scratch/updatejkinit

# 31. ZNC
#Have put this in script form

# 32. Installing poweroff button on ruTorrent
cd /var/www/rutorrent/plugins/
wget http://rutorrent-logoff.googlecode.com/files/logoff-1.0.tar.gz >> $logfile 2>&1
tar -zxf logoff-1.0.tar.gz >> $logfile 2>&1
rm -f logoff-1.0.tar.gz

# Installing Filemanager and MediaStream
rm -f -R /var/www/rutorrent/plugins/filemanager
rm -f -R /var/www/rutorrent/plugins/fileupload
rm -f -R /var/www/rutorrent/plugins/mediastream
rm -f -R /var/www/stream

cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/mediastream >> $logfile 2>&1

cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/filemanager >> $logfile 2>&1

cp /etc/seedbox-from-scratch/rutorrent.plugins.filemanager.conf.php.template /var/www/rutorrent/plugins/filemanager/conf.php

mkdir -p /var/www/stream/
ln -s /var/www/rutorrent/plugins/mediastream/view.php /var/www/stream/view.php
chown www-data: /var/www/stream
chown www-data: /var/www/stream/view.php

echo "<?php \$streampath = 'http://$IPADDRESS1/stream/view.php'; ?>" | tee /var/www/rutorrent/plugins/mediastream/conf.php > /dev/null

# 32.2 # FILEUPLOAD
cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/fileupload >> $logfile 2>&1
chmod 775 /var/www/rutorrent/plugins/fileupload/scripts/upload
apt-get --yes -f install >> $logfile 2>&1
rm /var/www/rutorrent/plugins/unpack/conf.php
# 32.2
chown -R www-data:www-data /var/www/rutorrent
chmod -R 755 /var/www/rutorrent

#32.3
perl -pi -e "s/\\\$topDirectory\, \\\$fm/\\\$homeDirectory\, \\\$topDirectory\, \\\$fm/g" /var/www/rutorrent/plugins/filemanager/flm.class.php
perl -pi -e "s/\\\$this\-\>userdir \= addslash\(\\\$topDirectory\)\;/\\\$this\-\>userdir \= \\\$homeDirectory \? addslash\(\\\$homeDirectory\) \: addslash\(\\\$topDirectory\)\;/g" /var/www/rutorrent/plugins/filemanager/flm.class.php
perl -pi -e "s/\\\$topDirectory/\\\$homeDirectory/g" /var/www/rutorrent/plugins/filemanager/settings.js.php

#32.4
#unzip /etc/seedbox-from-scratch/rutorrent-oblivion.zip -d /var/www/rutorrent/plugins/
#echo "" | tee -a /var/www/rutorrent/css/style.css > /dev/null
#echo "/* for Oblivion */" | tee -a /var/www/rutorrent/css/style.css > /dev/null
#echo ".meter-value-start-color { background-color: #E05400 }" | tee -a /var/www/rutorrent/css/style.css > /dev/null
#echo ".meter-value-end-color { background-color: #8FBC00 }" | tee -a /var/www/rutorrent/css/style.css > /dev/null
#echo "::-webkit-scrollbar {width:12px;height:12px;padding:0px;margin:0px;}" | tee -a /var/www/rutorrent/css/style.css > /dev/null
perl -pi -e "s/\$defaultTheme \= \"\"\;/\$defaultTheme \= \"Oblivion\"\;/g" /var/www/rutorrent/plugins/theme/conf.php
git clone https://github.com/InAnimaTe/rutorrent-themes.git /var/www/rutorrent/plugins/theme/themes/Extra >> $logfile 2>&1
cp -r /var/www/rutorrent/plugins/theme/themes/Extra/OblivionBlue /var/www/rutorrent/plugins/theme/themes/
cp -r /var/www/rutorrent/plugins/theme/themes/Extra/Agent46 /var/www/rutorrent/plugins/theme/themes/
rm -r /var/www/rutorrent/plugins/theme/themes/Extra
#ln -s /etc/seedbox-from-scratch/seedboxInfo.php.template /var/www/seedboxInfo.php

# 32.5
cd /var/www/rutorrent/plugins/
rm -r /var/www/rutorrent/plugins/fileshare
rm -r /var/www/share
svn co http://svn.rutorrent.org/svn/filemanager/trunk/fileshare >> $logfile 2>&1
mkdir /var/www/share
ln -s /var/www/rutorrent/plugins/fileshare/share.php /var/www/share/share.php
ln -s /var/www/rutorrent/plugins/fileshare/share.php /var/www/share/index.php
chown -R www-data:www-data /var/www/share
cp /etc/seedbox-from-scratch/rutorrent.plugins.fileshare.conf.php.template /var/www/rutorrent/plugins/fileshare/conf.php
perl -pi -e "s/<servername>/$IPADDRESS1/g" /var/www/rutorrent/plugins/fileshare/conf.php

mv /etc/seedbox-from-scratch/unpack.conf.php /var/www/rutorrent/plugins/unpack/conf.php

# 33.
bash /etc/seedbox-from-scratch/updateExecutables >> $logfile 2>&1

#34.
echo $SBFSCURRENTVERSION1 > /etc/seedbox-from-scratch/version.info
echo $NEWFTPPORT1 > /etc/seedbox-from-scratch/ftp.info
echo $NEWSSHPORT1 > /etc/seedbox-from-scratch/ssh.info
echo $OPENVPNPORT1 > /etc/seedbox-from-scratch/openvpn.info

# 36.
wget -P /usr/share/ca-certificates/ --no-check-certificate https://certs.godaddy.com/repository/gd_intermediate.crt https://certs.godaddy.com/repository/gd_cross_intermediate.crt 
update-ca-certificates
c_rehash

# 96.
if [ "$INSTALLOPENVPN1" = "YES" ]; then
  bash /etc/seedbox-from-scratch/installOpenVPN
fi

if [ "$INSTALLSABNZBD1" = "YES" ]; then
  bash /etc/seedbox-from-scratch/installSABnzbd
fi

if [ "$INSTALLRAPIDLEECH1" = "YES" ]; then
  bash /etc/seedbox-from-scratch/installRapidleech
fi

if [ "$INSTALLDELUGE1" = "YES" ]; then
  bash /etc/seedbox-from-scratch/installDeluge
fi

# 97. First user will not be jailed
#  createSeedboxUser <username> <password> <user jailed?> <ssh access?> <Chroot User>
bash /etc/seedbox-from-scratch/createSeedboxUser $NEWUSER1 $PASSWORD1 YES YES YES NO >> $logfile 2>&1

# 98. Cosmetic corrections & installing plowshare
#cd /var/www/rutorrent/plugins/autodl-irssi
#rm AutodlFilesDownloader.js
#wget --no-check-certificate https://raw.githubusercontent.com/dannyti/sboxsetup/master/AutodlFilesDownloader.js
#cd /var/www/rutorrent/js
#rm webui.js
#wget --no-check-certificate https://raw.githubusercontent.com/dannyti/sboxsetup/master/webui.js
cd /var/www
chown -R www-data:www-data /var/www/rutorrent
chmod -R 755 /var/www/rutorrent
cd 
git clone https://github.com/mcrapet/plowshare.git plowshare >> $logfile 2>&1
cd ~/plowshare
make install >> $logfile 2>&1
cd
rm -r plowshare

#if [ "$OS1" = "Debian" ]; then
#  apt-get install -y --force-yes -t wheezy-updates debian-cyconet-archive-keyring vsftpd subversion
#fi
## Installing xrdp && Mate Desktop Env.
#apt-get -y install tightvncserver
#dpkg -i /etc/seedbox-from-scratch/xrdp_0.6.1-1_`uname -m`.deb
#apt-get -f -y install
#apt-get -y install mate-core mate-desktop-environment mate-notification-daemon
#apt-get -y install firefox
 
export EDITOR=nano
# 100
if [ "$SINGLEUSER1" = "NO" ]; then
  cd /var/www/rutorrent/plugins
  sleep 1
  rm -frv diskspace
  wget --no-check-certificate https://bintray.com/artifact/download/hectortheone/base/pool/main/b/base/hectortheone.rar >> $logfile 2>&1
#wget http://dl.bintray.com/novik65/generi...ace-3.6.tar.gz
#tar -xf diskspace-3.6.tar.gz
  unrar x hectortheone.rar
#rm diskspace-3.6.tar.gz
  rm hectortheone.rar
  cd quotaspace
  chmod 755 run.sh
  cd ..
fi
chown -R www-data:www-data /var/www/rutorrent

if [ "$OSV11" = "8" ]; then
  systemctl enable apache2
  service apache2 start 
fi
set +x verbose
clear

echo ""
echo "<<< The Seedbox From Scratch Script >>>"
echo "Script Modified by dannyti ---> https://github.com/dannyti/"
echo ""
echo "Looks like everything is set."
echo ""
echo "Remember that your SSH port is now ======> $NEWSSHPORT1"
echo ""
echo "Your Login info can also be found at https://$IPADDRESS1/private/SBinfo.txt"
echo "Download Data Directory is located at https://$IPADDRESS1/private "
echo "To install ZNC, run installZNC from ssh as main user"
echo "System will reboot now, but don't close this window until you take note of the port number: $NEWSSHPORT1"
echo ""
echo ""

reboot

##################### LAST LINE ###########
