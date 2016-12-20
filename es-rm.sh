#!/bin/bash

if [ $# -lt 2 ]; 
  then echo "Usage ${0} host index"
  exit 1
fi

HOST=$1
INDEX=$2

curl -XDELETE http://${HOST}:9200/${INDEX}
