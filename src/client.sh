#!/bin/bash

if [ $(whoami) != 'root' ];then
   echo 'You must be root to run this script!'
   exit 1	
fi

### check network settings first

echo "Syncing Portage Config files with 'client specific gentoo binary host': csg-binhost"
USER="nick" 				# TODO: Rename var!
HOST="192.168.2.100"			# TODO: Rename var!
BIN_HOST_REMOTE_DIR="/opt/csg-binhost"
SYNC_DIRS=(/etc/portage/ /etc/make.conf /var/lib/portage/ /etc/make.profile/ /usr/share/portage/config /etc/make.globals)
for SYNC_DIR in ${SYNC_DIRS[@]} do
   echo "Syncing " $SYNC_DIR
   rsync -avze ssh $SYNC_DIR $USER@$HOST:$BIN_HOST_REMOTE_DIR/$USER/$SYNC_DIR
done

echo "Syncing Portage Tree and buid updates"
PORTAGE="/usr/portage"
#PKG_DIR="/usr/portage/packages"	# TODO: set var in /etc/make.conf
#PORTAGE_BINHOST=/usr/portage/packages	# not used, PKG_DIR is used with nfs/sshfs and 'emerge --usepkg' parameter
EMERGE_OPTS="--root $BIN_HOST_REMOTE_DIR/$USER/ --config-root $BIN_HOST_REMOTE_DIR/$USER/"
ssh $USER@$HOST "emerge $EMERGE_OPTS --sync"
ssh $USER@$HOST "emerge $EMERGE_OPTS --buildpkg --update --deep --newuse world"
ssh $USER@$HOST "revdep-rebuild $EMERGE_OPTS"
echo "Mounting Portage filesystem to $PORTAGE"
sshfs $USER@$HOST:/$BIN_HOST_REMOTE_DIR/$USER/$PORTAGE/ /$PORTAGE
emerge --usepkg --update --deep --newuse world

echo "Umounting Portage"
umount /$Portage

exit 0
