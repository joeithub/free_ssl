#!/usr/bin/env bash 

DIR=`pwd`

tar -zcvf enca.tar.gz  acme.sh-master

mv -f enca.tar.gz $DIR/enca

cd $DIR/enca

chmod +x *.sh

cd $DIR

tar -zcvf enca.tar enca