#!/bin/bash

if [ $# -lt 4 ]; 
  then echo "Usage ${0} dst_host dst_index dst_type src_dump_file"
  exit 1
fi

DST_HOST=$1
DST_INDEX=$2
DST_TYPE=$3
SRC_DUMP=$4

DST_ENTRIES=$(curl -s "http://${DST_HOST}:9200/${DST_INDEX}/${DST_TYPE}/_search?q=*&size=0" | jq .hits.total)

echo "Found $DST_ENTRIES entries in destintation before copying"
curl -XPUT http://${DST_HOST}:9200/${DST_INDEX}/ --data-binary @${SRC_DUMP}.index
curl -XPUT http://${DST_HOST}:9200/_bulk --data-binary @${SRC_DUMP}
DST_ENTRIES=$(curl -s "http://${DST_HOST}:9200/${DST_INDEX}/${DST_TYPE}/_search?q=*&size=0" | jq .hits.total)
echo "Found $DST_ENTRIES entries in destintation after copying"

