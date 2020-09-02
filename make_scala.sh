#!/bin/bash

if [ "$1" == "" ] ; then
    echo "Usage: $0 ProjectName"
    exit 1
fi

renamed=$(echo $1 | perl -pne 's/ //g;')
mkdir $renamed
if [ "$?" != "0" ] ; then
    echo "Can't make directory ${renamed}"
    exit 1
fi

cd $renamed

mkdir -p src/{main.test}/{java,resources,scala}
mkdir lib project target


# Create the initial build.sbt file

echo "name := \"$1\"

version := \"1.0\" 

scalaVersion := \"$SCALA_VERSION\"" > build.sbt


