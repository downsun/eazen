#!/bin/bash

while getopts :u: opt ; do
case $opt in
u) ZENDOO_USER=$OPTARG
;;
esac
done
echo "ZENDOO_USER = $ZENDOO_USER"
echo "export ZENDOO_USER=$ZENDOO_USER" >> /home/$ZENDOO_USER/.bashrc
export ZENDOO_DIR=/opt/zend_oo
export ZENDOO_CONF_DIR=~/.zen
export ZENDOO_CONF_FILE=$ZENDOO_CONF_DIR/zen.conf
export ZENDOO_USER=$ZENDOO_USER
apt -y update && apt -y upgrade
apt -y install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python zlib1g-dev bsdmainutils automake curl wget vim sudo
mkdir $ZENDOO_DIR
chown $ZENDOO_USER:$ZENDOO_DIR
git clone https://github.com/ZencashOfficial/zend_oo.git $ZENDOO_DIR
cd $ZENDOO_DIR && ./zcutil/build.sh -j$(nproc) && ./zcutil/fetch-params.sh
cd $ZENDOO_DIR && bash -c "./src/zend"
sed -i -e "s/#testnet=0/testnet=1/" $ZENDOO_CONF_FILE
ln -s /opt/zend_oo/src/zend /usr/local/bin/zend
cp /root/.zcash-params /home/$ZENDOO_USER/ -R
cp $ZENDOO_CONF_DIR /home/$ZENDOO_USER/.zen -R
chown $ZENDOO_USER:$ZENDOO_USER /home/$ZENDOO_USER/.zen -R
