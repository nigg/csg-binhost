#!/bin/bash

### check network settings first

USER="nick"
HOST="192.168.2.100"
SYNC_DIRS=(/etc/portage/ /etc/make.conf /var/lib/portage/ /etc/make.profile/ /usr/share/portage/config /etc/make.globals)
for SYNC_DIR in ${SYNC_DIRS[@]} do
   echo rsync -avze ssh $SYNC_DIR $USER@$HOST:/$SYNC_DIR
done

EMERGE_OPTS="--root /opt/csg-binhost/$USER/ --config-root /opt/csg-binhost/$USER/"
ssh $USER@$HOST 'emerge $EMERGE_OPTS --sync'
ssh $USER@$HOST 'PKG_DIR="/usr/portage/packages" emerge $EMERGE_OPTS -uDN world'
ssh $USER@$HOST 'revdep-rebuild $EMERGE_OPTS'

sshfs $USER@$HOST:/usr/portage/ /usr/portage
PORTAGE_BINHOST=/usr/portage/packages emerge -uDN world # +binpkd zusatz
