#!/bin/bash

# This script should be in the same directory with Doop in order to work. The
# $LIBSD directory should have the .class files extracted from various jars
# (while keeping directory structure) and the $DEPSD directory should not
# contain anything important. When the script terminates, the jar file with the
# dependencies will be $DEPSD/deps.jar

JAR=$1
LIBSD=$(readlink -f libs)
DEPSD=$(readlink -f deps)
CURTXT=phantom.txt
OLDTXT=oldphantom.txt

rm -f $CURTXT $OLDTXT
rm -rf $DEPSD/*
touch $OLDTXT
jar cf $DEPSD/deps.jar -- 2>/dev/null

while true ; do

	./doop -a context-insensitive -i $JAR $DEPSD/deps.jar -XstopAt:facts /dev/null -XdryRun 2>/dev/null | \
		grep '^Warning:' | grep 'is a phantom class!$' | \
		sed -r 's/Warning: (.*) is a phantom class!/\1/' > $CURTXT

		if diff $CURTXT $OLDTXT > /dev/null ; then break ; fi
		cp $CURTXT $OLDTXT

	cat $CURTXT | while read line ; do
		CLASS="$(echo $line | sed -r 's/\./\//g').class"
		echo $CLASS
		(cd $LIBSD ; cp --parents $CLASS $DEPSD)
	done
	(cd $DEPSD ; rm deps.jar ; jar cf deps.jar *)
	echo
done
