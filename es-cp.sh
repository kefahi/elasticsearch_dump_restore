#!/bin/bash

if [ $# -lt 6 ]; 
  then echo "Usage ${0} src_host src_index src_type dst_host dst_index dst_type"
  exit 1
fi

SRC_HOST=$1
SRC_INDEX=$2
SRC_TYPE=$3
DST_HOST=$4
DST_INDEX=$5
DST_TYPE=$6

SRC_ENTRIES=$(curl -s "http://${SRC_HOST}:9200/${SRC_INDEX}/${SRC_TYPE}/_search?q=*&size=0" | jq .hits.total)
DST_ENTRIES=$(curl -s "http://${DST_HOST}:9200/${DST_INDEX}/${DST_TYPE}/_search?q=*&size=0" | jq .hits.total)

echo "Found $SRC_ENTRIES entries in source"
echo "Found $DST_ENTRIES entries in destintation before copying"
curl -s -XGET "http://${SRC_HOST}:9200/${SRC_INDEX}/" | jq -c .\"${SRC_INDEX}\" | curl -XPUT http://${DST_HOST}:9200/${DST_INDEX}/ --data-binary @-
curl -s -XGET "http://${SRC_HOST}:9200/${SRC_INDEX}/${SRC_TYPE}/_search?scroll=1m" -d '{"query":{"match_all": {}},"sort" : ["_doc"], "size":  10000000}'  | jq -c '.hits.hits[]._source' |  jq -c "{\"index\":{\"_index\":\"${DST_INDEX}\", \"_type\":\"${DST_TYPE}\",\"_id\": .id}}, ." | curl -XPUT http://${DST_HOST}:9200/_bulk --data-binary @-
DST_ENTRIES=$(curl -s "http://${DST_HOST}:9200/${DST_INDEX}/${DST_TYPE}/_search?q=*&size=0" | jq .hits.total)
echo "Found $DST_ENTRIES entries in destintation after copying"

