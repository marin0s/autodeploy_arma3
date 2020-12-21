#!bin/bash
#-------------------------------------------------------------------------
#                   DEPLOYING ARMA 3 SERVER SCRIPT
#-------------------------------------------------------------------------
# VM Type : UBUNTU SERVER 20.04 LTS
# HOST Server : HYPER-V - Windows Server 2019 Standard
#-------------------------------------------------------------------------
#                           ARMA 3 PORTS
#-------------------------------------------------------------------------
#           2302 UDP (gameport + VON)
#           2303 UDP (STEAM query port)
#           2304 UDP (STEAM master port)
#           2305 UDP (VON reserved port but not used atm.)
#           2306 UDP (BattlEye traffic port)
#           so open ports 2302-2306
#... and leave at least 100 ports between the next 2nd server set
#-------------------------------------------------------------------------

# UPDATE & UPGRADE
#log in root :
sudo -i
echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
apt update && apt upgrade -y

# INSTALL LAMP COMPONMENTS FOR WEB ADMIN PANEL
echo -e "\n\nInstalling Apache2 Web server\n"
#install apache & php
sudo apt install apache2 php libapache2-mod-php php-mysql -y
echo -e "\n\nInstalling PHP & Requirements\n"
#install lamp dependencies
sudo apt install php-curl php-gd php-intl php-json php-mbstring php-xml php-zip nodejs npm -y
echo -e "\n\nInstalling MySQL\n"
#install DB
sudo apt install mysql-server mysql-client -y
echo -e "\n\n LAMP Stack installed\n"

# PERMISSIONS FOR VAR/WWW/HTML
echo -e "\n\nPermissions for /var/www/html\n"
sudo chown -R www-data:www-data /var/www/html
echo -e "\n\n Permissions have been set\n"

# MOUNT SHARED FOLDER
echo -e "\n\nInstalling Modules\n"
sudo apt install samba cifs-utils nfs-common nano -y
echo -e "\n\nBackup fstab file\n"
sudo cp /etc/fstab /etc/fstab/BACKUP_fstab
echo -e "\n\nMounting SharedFiles\n"
sudo mkdir /media/sharedfiles
cat > /etc/fstab << eof
//10.55.1.70/SharedFiles /media/sharedfiles cifs username=Administrateur,password=WoaOt1e8rl5,uid=marinos,gid=marinos,x-systemd.automount,iocharset=utf8 0 0
eof

# INSTALL & SET ARMA 3 SERVER
echo -e "\n\nInstall wget & librairies\n"
sudo apt install wget lib32gcc1 lib32stdc++6 net-tools -y
echo -e "\n\nCreating STEAM User\n"
sudo useradd -m -s /bin/bash steam
sudo -i -u steam
echo -e "\n\nInstalling Steamcmd\n"
mkdir ~/steamcmd && cd ~/steamcmd
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar xzvf -
./steamcmd.sh
echo -e "\n\nInstalling Arma3 Server\n"
#in steamcmd console :
login marinosnetwork AzErTy1923#
#Change the directory SteamCMD will install the server in.
force_install_dir ./arma3/
#Install the Arma 3 Linux dedicated server. The validate option will check for corruption.
app_update 233780 validate
#Exit SteamCMD.
exit

#Create the directories used to store the profile files and Arma3.cfg file.
mkdir -p ~/".local/share/Arma 3" && mkdir -p ~/".local/share/Arma 3 - Other Profiles"

#Launching Arma 3 Server whith the vps hostname as server name
cd /home/steam/steamcmd/arma3
./arma3server -name=$HOSTNAME -config=server.cfg

#UPDATING ARMA 3 SERVER
#You will have to update the server whenever a patch is released on Steam.
#If the server is running, stop it by pressing Ctrl+C in the terminal (or screen/tmux instance) that the server is attached to. Otherwise, switch to the steam user.
#sudo -u steam -i
#Launch steamcmd.
#cd ~/steamcmd
#./steamcmd.sh
#Login to the Steam account used in the installation section above.
#login marinosnetwork AzErTy1923#
#Set the Arma 3 installation directory to the same directory used above.
#force_install_dir ./arma3/
#Update the Arma 3 Linux dedicated server. The validate option will check for corruption.
#app_update 233780 validate
#Exit SteamCMD
#exit

# SET APACHE2 CONFIGURATION
echo -e "\n\nEnabling Modules\n"
sudo a2enmod rewrite
sudo phpenmod mcrypt
echo -e "\n\nRestarting Apache\n"
sudo service apache2 restart
echo -e "\n\nLAMP Installation Completed"
# COPY WEBSITE PANEL FROM MOUNT SHARED FOLDER
sudo rm /var/www/html/index.html
sudo cp -a /media/sharedfilesarma-server-web-admin-master/* /var/www/html
sudo npm install


exit 0
