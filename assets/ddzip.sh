#!/usr/env/bin bash
# $1 input zip file
# $2 output device (/dev/sde, for example)

if [ "$1" == "" ] || [ "$2" == "" ]; then
  echo "-=-=-=-=- ddzip help -=-=-=-=-"
  echo "made by: llbranco"
  echo "github.com/llbranco"
  echo "you need to specify the parameters"
  echo ""
  echo "to use ddzip, run \"ddzip file.zip /dev\""
  echo "ex:"
  echo "ddzip /path/file.zip /dev/sdf"
  exit
fi

unzip -p "$1" | dd bs=4M of="$2" iflag=fullblock oflag=direct status=progress
