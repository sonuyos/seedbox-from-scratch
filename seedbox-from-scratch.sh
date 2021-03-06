##################### FIRST LINE
# ---------------------------
#!/bin/bash
# ---------------------------
#
#
# The Seedbox From Scratch Script
#   By Notos ---> https://github.com/Notos/
#
#
#  git clone -b master https://github.com/Notos/seedbox-from-scratch.git /etc/scripts
#  sudo git stash; sudo git pull
#
#
# Changelog
#
#  Version 2.00 (testing)
#  Oct 26 2012 16:19
#     - chroot jail for users, using JailKit (http://olivier.sessink.nl/jailkit/)
#     - Fail2ban for apache and ssh exploits: bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc.
#     - OpenVPN (after install you can download your key from http://<IP address or host name of your box>/rutorrent/vpn.zip)
#     - createSeedboxUser script now asks if you want your user jailed, to have SSH access and if it should be added to sudoers
#     - Optionally install packages JailKit, Webmin, Fail2ban and OpenVPN
#     - Full automated install, now you just have to download script and run it in your box:
#        > wget -N https://raw.github.com/Notos/seedbox-from-scratch/fullCreate/seedbox-from-scratch.sh
#        > time bash ~/seedbox-from-scratch.sh
#     - Due to a recent outage of Webmin site and SourceForge's svn repositories, some packages are now in git and will not be downloaded from those sites
#     - Updated list of trackers in Autodl-irssi
#
#  Version 1.30
#  Oct 23 2012 04:54:29
#     - Scripts now accept a full install without having to create variables and do anything else
#
#  Version 1.20
#  Oct 19 2012 03:24 (by Notos)
#    - Install OpenVPN - (BETA) Still not in the script, just an outside script
#      Tested client: http://openvpn.net/index.php?option=com_content&id=357
#
#  Version 1.11
#  Oct 18 2012 05:13 (by Notos)
#    - Added scripts to downgrade and upgrade rTorrent
#
#    - Added all supported plowshare sites into fileupload plugin: 115, 1fichier, 2shared, 4shared, bayfiles, bitshare, config, cramit, data_hu, dataport_cz,
#      depositfiles, divshare, dl_free_fr, euroshare_eu, extabit, filebox, filemates, filepost, freakshare, go4up, hotfile, mediafire, megashares, mirrorcreator, multiupload, netload_in,
#      oron, putlocker, rapidgator, rapidshare, ryushare, sendspace, shareonline_biz, turbobit, uploaded_net, uploadhero, uploading, uptobox, zalaa, zippyshare
#
#  Version 1.10
#  06/10/2012 14:18 (by Notos)
#    - Added Fileupload plugin
#
#    - Added all supported plowshare sites into fileupload plugin: 115, 1fichier, 2shared, 4shared, bayfiles, bitshare, config, cramit, data_hu, dataport_cz,
#      depositfiles, divshare, dl_free_fr, euroshare_eu, extabit, filebox, filemates, filepost, freakshare, go4up, hotfile, mediafire, megashares, mirrorcreator, multiupload, netload_in,
#      oron, putlocker, rapidgator, rapidshare, ryushare, sendspace, shareonline_biz, turbobit, uploaded_net, uploadhero, uploading, uptobox, zalaa, zippyshare
#
#  Version 1.00
#  30/09/2012 14:18 (by Notos)
#    - Changing some file names and depoying version 1.00
#
#  Version 0.99b
#  27/09/2012 19:39 (by Notos)
#    - Quota for users
#    - Download dir inside user home
#
#  Version 0.99a
#  27/09/2012 19:39 (by Notos)
#    - Quota for users
#    - Download dir inside user home
#
#  Version 0.92a
#  28/08/2012 19:39 (by Notos)
#    - Also working on Debian now
#
#  Version 0.91a
#  24/08/2012 19:39 (by Notos)
#    - First multi-user version sent to public
#
#  Version 0.90a
#  22/08/2012 19:39 (by Notos)
#    - Working version for OVH Kimsufi 2G Server - Ubuntu Based
#
#  Version 0.89a
#  17/08/2012 19:39 (by Notos)
#
# to get IP address = ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1 | head -1 | awk '{print $2}'`
#
# quota notes
#  fstab:,usrjquota=quota.user,grpjquota=quota.group,jqfmt=vfsv0
#  quotacheck -avugm
#  quotaon -avug
#
#
# Fail2ban -> Fail2ban scans log files (e.g. /var/log/apache/error_log) and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc. Generally Fail2Ban then used to update firewall rules to reject the IP addresses for a specified amount of time, although any arbitrary other action (e.g. sending an email, or ejecting CD-ROM tray) could also be configured. Out of the box Fail2Ban comes with filters for various services (apache, curier, ssh, etc).
#   http://www.fail2ban.org/wiki/index.php/Main_Page
#
#   apt-get install fail2ban
#   ed /etc/fail2ban/jail.local **** SSH? Apache2??
#
# Jailkit -> http://olivier.sessink.nl/jailkit/
#   apt-get install build-essential autoconf automake1.9 libtool flex bison debhelper binutils-gold
#
#   cd /etc/scripts
#   wget http://olivier.sessink.nl/jailkit/jailkit-2.15.tar.gz
#   tar xvfz jailkit-2.15.tar.gz -C /etc/scripts/source/
#   cd source/jailkit-2.15
#   ./debian/rules binary
#   cd ..
#   dpkg -i jailkit_2.15-1_*.deb
#   rm -rf jailkit-2.15*
#   ---- creating a jailed user
#   # Initialise the jail
#   mkdir /home/aline
#   chown root:root /home/aline
#   chmod 0755 /home/aline
#   jk_init -j /home/aline jk_lsh
#   jk_init -j /home/aline sftp
#   jk_init -j /home/aline scp
#   jk_init -j /home/aline ssh
#   # Create the account
#   jk_jailuser
#   useradd --create-home --user-group --password $(mkpasswd -s -m md5 txu) --shell /bin/bash aline
#   jk_jailuser --jail=/home/aline/ aline
#   ############ DEPRECATED ############# jk_addjailuser -j /home/aline test
#   # Edit the jk_lsh configfile in the jail; see man jk_lsh..
#   # You can use every editor you want; I choose 'joe'
#   joe /home/aline/etc/jailkit/jk_lsh.ini
#   # Restart jk_socketd so that log messages are transferred
#   killall jk_socketd
#   jk_socketd
#   # Test the account
#   sftp test@localhost
#   # Check the logs to see if everything is correct
#   tail /var/log/daemon.log /var/log/auth.log
#
#add to /etc/jailkit/jk_init.ini
#[rtorrent]
#comment = rtorrent
#paths = /usr/bin/rtorrent
#
#[irssi]
#comment = irssi
#paths = /usr/bin/irssi
function getString
{
  local ISPASSWORD=$1
  local LABEL=$2
  local RETURN=$3
  local DEFAULT=$4
  local NEWVAR1=a
  local NEWVAR2=b

  while [ ! $NEWVAR1 = $NEWVAR2 ] || [ -z "$NEWVAR1" ];
  do
    clear
    echo "#"
    echo "#"
    echo "# The Seedbox From Scratch Script"
    echo "#   By Notos ---> https://github.com/Notos/"
    echo "#"
    echo "#"
    echo "#"
    echo

    if [ "$ISPASSWORD" == "YES" ]; then
      read -s -p "$DEFAULT" -p "$LABEL" NEWVAR1
    else
      read -e -i "$DEFAULT" -p "$LABEL" NEWVAR1
    fi

    if [ "$NEWVAR1" == "$DEFAULT" ]
    then
      NEWVAR2=$NEWVAR1
    else
      if [ "$ISPASSWORD" == "YES" ]; then
        echo
        read -s -p "Retype: " NEWVAR2
      else
        read -p "Retype: " NEWVAR2
      fi
    fi
  done
  eval $RETURN=\$NEWVAR1
}
# 0.

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install whois sudo makepasswd git

rm -f -r /etc/scripts
mkdir -p /etc/scripts
git clone -b fullCreate https://github.com/Notos/seedbox-from-scratch.git /etc/scripts
#git clone -b master https://github.com/Notos/seedbox-from-scratch.git /etc/scripts

if [ ! -f /etc/scripts/seedbox-from-scratch.sh ]
then
  clear
  echo Looks like somethig is wrong, this script was not able to download its whole git repository.
  set -e
  exit 1
fi

# 1.
clear

# 1.1 functions

# 3.1

#localhost is ok this rtorrent/rutorrent installation
IPADDRESS1=`grep address /etc/network/interfaces | grep -v 127.0.0.1  | awk '{print $2}'`

#those passwords will be changed in the next steps
PASSWORD1=a
PASSWORD2=b

getString NO  "You need to create an user for your seedbox: " NEWUSER1
getString YES "ruTorrent password for user $NEWUSER1: " PASSWORD1
getString NO  "IP address or hostname of your box: " NEWHOSTNAME1 $IPADDRESS1
getString NO  "New SSH port: " NEWSSHPORT1 21976
getString NO  "Wich rTorrent would you like to use, '0.8.9' (older stable) or '0.9.2' (newer but banned in some trackers)? " RTORRENT1 0.9.2
getString NO  "Do you want to have some of your users in a chroot jail? " CHROOTJAIL1 YES
getString NO  "Install OpenVPN? " INSTALLOPENVPN1 YES
getString NO  "Install Webmin? " INSTALLWEBMIN1 NO
getString NO  "Install Fail2ban? " INSTALLFAIL2BAN1 NO

if [ "$RTORRENT1" != "0.9.2" ] && [ "$RTORRENT1" != "0.9.2" ]; then
  echo "$RTORRENT1 is not 0.9.2 or 0.8.9!"
  exit 1
fi

if [ "$RTORRENT1" = "0.9.2" ]; then
  LIBTORRENT1=0.13.2
else
  LIBTORRENT1=0.12.9
fi

# 3.2

#show all commands
set -x verbose

# 4.
perl -pi -e "s/Port 22/Port $NEWSSHPORT1/g" /etc/ssh/sshd_config
#perl -pi -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
perl -pi -e "s/#Protocol 2/Protocol 2/g" /etc/ssh/sshd_config
perl -pi -e "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config

groupadd sshdusers
echo "" | tee -a /etc/ssh/sshd_config > /dev/null
echo "UseDNS no" | tee -a /etc/ssh/sshd_config > /dev/null
echo "AllowGroups sshdusers" >> /etc/ssh/sshd_config
sudo cp /lib/terminfo/l/linux /usr/share/terminfo/l/

service ssh restart

# 6.
#remove cdrom from apt so it doesn't stop asking for it
perl -pi -e "s/deb cdrom/#deb cdrom/g" /etc/apt/sources.list

#add non-free sources to Debian Squeeze
perl -pi -e "s/squeeze main/squeeze main non-free/g" /etc/apt/sources.list
perl -pi -e "s/squeeze\/updates main/squeeze\/updates main non-free/g" /etc/apt/sources.list

# 7.
# update and upgrade packages

sudo apt-get --yes update
apt-get --yes upgrade

# 8.
#install all needed packages

apt-get --yes build-dep znc
apt-get --yes install apache2 apache2-utils autoconf build-essential ca-certificates comerr-dev curl cfv quota mktorrent dtach htop irssi libapache2-mod-php5 libcloog-ppl-dev libcppunit-dev libcurl3 libcurl4-openssl-dev libncurses5-dev libterm-readline-gnu-perl libsigc++-2.0-dev libperl-dev openvpn libssl-dev libtool libxml2-dev ncurses-base ncurses-term ntp openssl patch pkg-config php5 php5-cli php5-dev php5-curl php5-geoip php5-mcrypt php5-xmlrpc pkg-config python-scgi screen ssl-cert subversion texinfo unrar-free unzip zlib1g-dev expect joe automake1.9 flex bison debhelper binutils-gold ffmpeg libarchive-zip-perl libnet-ssleay-perl libhtml-parser-perl libxml-libxml-perl libjson-perl libjson-xs-perl libxml-libxslt-perl libxml-libxml-perl libjson-rpc-perl libarchive-zip-perl znc rar zip
if [ $? -gt 0 ]; then
  set +x verbose
  echo
  echo
  echo *** ERROR ***
  echo
  echo "Looks like somethig is wrong with apt-get install, aborting."
  echo
  echo
  echo
  set -e
  exit 1
fi

if [ "$CHROOTJAIL1" = "YES" ]; then
  cd /etc/scripts
  tar xvfz jailkit-2.15.tar.gz -C /etc/scripts/source/
  cd source/jailkit-2.15
  ./debian/rules binary
  cd ..
  dpkg -i jailkit_2.15-1_*.deb
fi

# 8.1 additional packages for Ubuntu
# this is better to be apart from the others
apt-get --yes install php5-fpm
apt-get --yes install php5-xcache

#Check if its Debian an do a sysvinit by upstart replacement:

if [ -f /etc/debian_version ]
  then
    echo 'Yes, do as I say!' | apt-get -y --force-yes install upstart
fi

# 8.3 Generate our lists of ports and RPC and create variables

#permanently adding scripts to PATH to all users and root
echo "PATH=$PATH:/etc/scripts:/sbin" | tee -a /etc/profile > /dev/null
echo "export PATH" | tee -a /etc/profile > /dev/null
echo "PATH=$PATH:/etc/scripts:/sbin" | tee -a /root/.bashrc > /dev/null
echo "export PATH" | tee -a /root/.bashrc > /dev/null

rm -f /etc/scripts/ports.txt
for i in $(seq 51101 51999)
do
  echo "$i" | tee -a /etc/scripts/ports.txt > /dev/null
done

rm -f /etc/scripts/rpc.txt
for i in $(seq 2 1000)
do
  echo "RPC$i"  | tee -a /etc/scripts/rpc.txt > /dev/null
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
    apt-get --yes install webmin
  fi
fi

if [ "$INSTALLFAIL2BAN1" = "YES" ]; then
  apt-get --yes install fail2ban
  cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.original
  cp /etc/scripts/etc.fail2ban.jail.conf.template /etc/fail2ban/jail.conf
fi

# 9.
a2enmod ssl
a2enmod auth_digest
a2enmod reqtimeout
#a2enmod scgi ############### if we cant make python-scgi works

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

service apache2 restart

echo "<?php phpinfo(); ?>" | tee -a /var/www/info.php > /dev/null
rm -f /var/www/info.php

# 11.

openssl req -new -x509 -days 365 -nodes -newkey rsa:2048 -out /etc/apache2/apache.pem -keyout /etc/apache2/apache.pem -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US'
chmod 600 /etc/apache2/apache.pem

# 13.
mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.ORI
rm -f /etc/apache2/sites-available/default

cp /etc/scripts/etc.apache2.default.template /etc/apache2/sites-available/default
perl -pi -e "s/http\:\/\/.*\/rutorrent/http\:\/\/$IPADDRESS1\/rutorrent/g" /etc/apache2/sites-available/default

# 14.
a2ensite default-ssl

#14.1
#ln -s /etc/apache2/mods-available/scgi.load /etc/apache2/mods-enabled/scgi.load
#service apache2 restart
#apt-get --yes install libxmlrpc-core-c3-dev

# 15.
cd /etc/scripts
mkdir source
tar xvfz /etc/scripts/rtorrent-0.8.9.tar.gz -C /etc/scripts/source/
tar xvfz /etc/scripts/rtorrent-0.9.2.tar.gz -C /etc/scripts/source/
tar xvfz /etc/scripts/libtorrent-0.12.9.tar.gz -C /etc/scripts/source/
tar xvfz /etc/scripts/libtorrent-0.13.2.tar.gz -C /etc/scripts/source/
tar xvfz /etc/scripts/xmlrpc-c-1.31.06.tgz -C /etc/scripts/source/
cd source
unzip ../xmlrpc-c-1.31.06.zip

# 16.
#cd xmlrpc-c-1.16.42 ### old, but stable, version, needs a missing old types.h file
#ln -s /usr/include/curl/curl.h /usr/include/curl/types.h
cd xmlrpc-c-1.31.06
./configure --prefix=/usr --enable-libxml2-backend --disable-libwww-client --disable-wininet-client --disable-abyss-server --disable-cgi-server
make
make install

# 17.
cd ../libtorrent-$LIBTORRENT1
./autogen.sh
./configure --prefix=/usr
make -j2
make install

cd ../rtorrent-$RTORRENT1
./autogen.sh
./configure --prefix=/usr --with-xmlrpc-c
make -j2
make install
ldconfig

# 22.
cd /var/www
rm -f -r rutorrent
svn checkout http://rutorrent.googlecode.com/svn/trunk/rutorrent
svn checkout http://rutorrent.googlecode.com/svn/trunk/plugins
rm -r -f rutorrent/plugins
mv plugins rutorrent/

cp /etc/scripts/action.php.template /var/www/rutorrent/plugins/diskspace/action.php

# 26.
cd /tmp
wget http://downloads.sourceforge.net/mediainfo/MediaInfo_CLI_0.7.56_GNU_FromSource.tar.bz2
tar jxvf MediaInfo_CLI_0.7.56_GNU_FromSource.tar.bz2
cd MediaInfo_CLI_GNU_FromSource/
sh CLI_Compile.sh
cd MediaInfo/Project/GNU/CLI
make install


cd /var/www/rutorrent/plugins
svn co https://autodl-irssi.svn.sourceforge.net/svnroot/autodl-irssi/trunk/rutorrent/autodl-irssi
cd autodl-irssi

# 30.

sudo cp /etc/jailkit/jk_init.ini /etc/jailkit/jk_init.ini.original
echo "" | tee -a /etc/jailkit/jk_init.ini >> /dev/null
bash /etc/scritps/updatejkinit

# 31.

#clear
#echo "ZNC Configuration"
#echo ""
#znc --makeconf
#/home/antoniocarlos/.znc/configs/znc.conf

# 32.

# Installing poweroff button on ruTorrent

cd /var/www/rutorrent/plugins/
wget http://rutorrent-logoff.googlecode.com/files/logoff-1.0.tar.gz
tar -zxf logoff-1.0.tar.gz
rm -f logoff-1.0.tar.gz

# Installing Filemanager and MediaStream

rm -f -R /var/www/rutorrent/plugins/filemanager
rm -f -R /var/www/rutorrent/plugins/fileupload
rm -f -R /var/www/rutorrent/plugins/mediastream
rm -f -R /var/www/stream

cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/mediastream

cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/filemanager

cp /etc/scripts/rutorrent.plugins.filemanager.conf.php.template /var/www/rutorrent/plugins/filemanager/conf.php

mkdir -p /var/www/stream/
ln -s /var/www/rutorrent/plugins/mediastream/view.php /var/www/stream/view.php
chown www-data: /var/www/stream
chown www-data: /var/www/stream/view.php

echo "<?php \$streampath = 'http://$NEWHOSTNAME1/stream/view.php'; ?>" | tee /var/www/rutorrent/plugins/mediastream/conf.php > /dev/null

# 32.1 # FILEUPLOAD
cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/fileupload
chmod 775 /var/www/rutorrent/plugins/fileupload/scripts/upload
wget -O /tmp/plowshare.deb http://plowshare.googlecode.com/files/plowshare_1~git20120930-1_all.deb
dpkg -i /tmp/plowshare.deb
apt-get --yes -f install

# 32.2
chown -R www-data:www-data /var/www/rutorrent
chmod -R 755 /var/www/rutorrent

#32.3

perl -pi -e "s/\\\$topDirectory\, \\\$fm/\\\$homeDirectory\, \\\$topDirectory\, \\\$fm/g" /var/www/rutorrent/plugins/filemanager/flm.class.php
perl -pi -e "s/\\\$this\-\>userdir \= addslash\(\\\$topDirectory\)\;/\\\$this\-\>userdir \= \\\$homeDirectory \? addslash\(\\\$homeDirectory\) \: addslash\(\\\$topDirectory\)\;/g" /var/www/rutorrent/plugins/filemanager/flm.class.php

# 33.
# createSeedboxUser script creation

# scripts are now in git form :)

chmod +x /etc/scripts/createSeedboxUser
chmod +x /etc/scripts/deleteSeedboxUser
chmod +x /etc/scripts/installOpenVPN
chmod +x /etc/scripts/removeWebmin
chmod +x /etc/scripts/downgradeRTorrent
chmod +x /etc/scripts/upgradeRTorrent
chmod +x /etc/scripts/ovpni

# 96.

#first user will not be jailed
#  createSeedboxUser <username> <password> <user jailed?> <ssh access?> <sudo ?>
/etc/scripts/createSeedboxUser $NEWUSER1 $PASSWORD1 NO YES YES

# 97.

if [ "$INSTALLOPENVPN1" = "YES" ]; then
  /etc/scripts/installOpenVPN
fi

# 98.

clear

echo ""
echo "<<< The Seedbox From Scratch Script >>>"
echo ""
echo ""
echo ""
echo "Looks like everything is set."
echo ""
echo "Remember that your SSH port is now ======> $NEWSSHPORT1"
echo ""
echo "System will reboot now, but don't close this window until you take note of the port number: $NEWSSHPORT1"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

# 99.

#reboot

##################### LAST LINE ###########
