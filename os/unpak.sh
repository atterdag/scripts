#!/bin/sh

if [ "$1" = "" ]; then
	echo "please speficy location of image files"
	exit 1
fi

for i in `ls -1 "$1"`; do 

	IMAGE=`echo $i | awk -F. '{print $1}'`
	EXT=`echo $i | awk -F. '{print $2}'`

	if [ $EXT = zip ] || [ $EXT = tar ] || [ $EXT = taz ] || [ $EXT = tgz ]; then

		echo Unpacking file "$i"

		mkdir $IMAGE
		cd $IMAGE

		case $EXT in
			zip)
				if unzip -q -o "$1/$i"; then
					ERROR=0
				fi
				;;
			tar)
				if tar xf "$1/$i"; then
					ERROR=0
				fi
				;;
			taz|tgz)
				if tar zxf "$1/$i"; then
					ERROR=0
				fi
				;;
		esac

		cd ..

		if [ $ERROR = 0 ]; then
			echo "$i" DONE
		else
			echo "$i" FAILED
			exit 1
		fi

	fi

	unset $IMAGE
	unset $EXT

done

