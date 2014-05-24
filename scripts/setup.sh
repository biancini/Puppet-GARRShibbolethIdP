#!/bin/bash

BASEDIR=/etc/puppet

if [ -d "$BASEDIR/environments" ]
then
	MODULEDIR=$BASEDIR/environments/test/modules
else
	MODULEDIR=$BASEDIR/modules
fi

if [ ! -d $MODULEDIR ]
then
	echo "ERROR: Directory $MODULEDIR not found!"
	exit
fi

cd ..

for i in garr/* puppetlabs/*
do
	cp -av $i $MODULEDIR/
done
