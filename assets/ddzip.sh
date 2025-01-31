#!/usr/env/bin bash
# $1 input device (e.g., /dev/sdf)
# $2 output zip file (e.g., output.zip)

if [ "$1" == "" ] || [ "$2" == "" ]; then
  echo "-=-=-=-=- ddzip help -=-=-=-=-"
  echo "made by: llbranco"
  echo "github.com/llbranco"
  echo "you need to specify the parameters"
  echo ""
  echo "to use ddzip, run \"ddzip /dev/sdf output.zip\""
  echo "ex:"
  echo "ddzip /dev/sdf /path/output.zip"
  exit
fi

# Cria o arquivo zip a partir do dispositivo
dd if="$1" bs=4M | zip "$2" -
