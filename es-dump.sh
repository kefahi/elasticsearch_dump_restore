#!/bin/bash

if [ $# -lt 6 ]; 
  then echo "Usage ${0} src_host src_index src_type dst_index dst_type dst_dump_file"
  exit 1
fi

SRC_HOST=$1
SRC_INDEX=$2
SRC_TYPE=$3
DST_INDEX=$4
DST_TYPE=$5
DST_DUMP=$6

SRC_ENTRIES=$(curl -s "http://${SRC_HOST}:9200/${SRC_INDEX}/${SRC_TYPE}/_search?q=*&size=0" | jq .hits.total)

echo "Found $SRC_ENTRIES entries in source"
curl -s -XGET "http://${SRC_HOST}:9200/${SRC_INDEX}/" | jq -c .\"${SRC_INDEX}\" > ${DST_DUMP}.index
curl -s -XGET "http://${SRC_HOST}:9200/${SRC_INDEX}/${SRC_TYPE}/_search?scroll=1m" -d '{"query":{"match_all": {}},"sort" : ["_doc"], "size":  10000000}'  | jq -c '.hits.hits[]._source' |  jq -c "{\"index\":{\"_index\":\"${DST_INDEX}\", \"_type\":\"${DST_TYPE}\",\"_id\": .id}}, ." > ${DST_DUMP}

