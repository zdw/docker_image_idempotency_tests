#!/usr/bin/env bash

set -e

# image lists, used to compare the docker image list to see if new images were created
IL=
ILQ=

function indent4() { sed 's/^/    /'; }

function set_image_list() {
  IL=`docker images`
  ILQ=`docker images -q`
  echo ""
}

function compare_image_list() {
#  echo " prev_ilq:"
#  echo $ILQ | sed 's/^/  /'
  local next_ilq=`docker images -q`
#  echo " next_ilq:"
#  echo $next_ilq | sed 's/^/  /'
  local uniq_ilq=`echo $ILQ $next_ilq | sed $'s/ /\\\n/g' | sort | uniq -u`
  echo " unique new containers: $uniq_ilq"
  local count_ilq=`echo $uniq_ilq | wc -w`
  echo " number of new images created: $count_ilq"
  sleep 1
}

echo "test prep, pulling image"
docker pull alpine:latest

echo "test_1: creating two images from the same dockerfile"
pushd test_1
echo " first build of test_1"
docker build -t "test_1" . | indent4

set_image_list
echo " second build of test_2 (should do nothing)"
docker build -t "test_1" . | indent4
compare_image_list

set_image_list
echo " second build of test_2 (should do nothing, --no-cache)"
docker build --no-cache -t "test_1" . | indent4
compare_image_list
popd

echo "test_2: touch file in context, rebuild"
pushd test_2
echo " first build of test_2"
docker build -t "test_2" . | indent4

set_image_list
touch testfile
echo " second build of test_2 (after touch file in context)"
docker build -t "test_2" . | indent4
compare_image_list

set_image_list
echo " third build of test_2 (after touch file in context, --no-cache)"
docker build --no-cache -t "test_2" . | indent4
compare_image_list
popd

echo "test_3: modify file in context, copy, rebuild"
pushd test_3
echo " first build of test_3"
docker build -t "test_3" . | indent4

set_image_list
echo "anotherline" >> testfile
echo " second build of test_3 (after modify file in context)"
docker build -t "test_3" . | indent4
compare_image_list

set_image_list
echo " third build of test_3 (after modify file in context, --no-cache)"
docker build --no-cache -t "test_3" . | indent4
compare_image_list
popd

echo "test_4: modify file in context, no copy, rebuild"
pushd test_4
echo " first build of test_4"
docker build -t "test_4" . | indent4

set_image_list
echo "anotherline" >> testfile
echo " second build of test_4 (after modify file in context)"
docker build -t "test_4" . | indent4
compare_image_list

set_image_list
echo " third build of test_4 (after modify file in context, --no-cache)"
docker build --no-cache -t "test_4" . | indent4
compare_image_list
popd

echo "test_5: modify file in subdir of context, copy, rebuild"
pushd test_5
echo " first build of test_5"
docker build -t "test_5" . | indent4

set_image_list
echo "anotherline" >> testdir/testfile
echo " second build of test_5 (after modify file in context)"
docker build -t "test_5" . | indent4
compare_image_list

set_image_list
echo " third build of test_5 (after modify file in context, --no-cache)"
docker build --no-cache -t "test_5" . | indent4
compare_image_list
popd


