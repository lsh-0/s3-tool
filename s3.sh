#!/bin/sh
set -eu

function venv {
    if [ ! -d venv ]; then
        python -m venv venv
    fi
    source venv/bin/activate
    hash aws 2> /dev/null || pip install awscli
}

function buckets {
    aws s3 ls --output json | tee last-listing.txt
}

function list {
    bucket=$1
    aws s3 ls "$bucket" | tee last-listing.txt
}

function listAllBuckets {
    for bucket in $(aws s3api list-buckets | jq ".Buckets[].Name" | tr -d \")
    do
        echo "bucket: $bucket"
        list $bucket
        echo "---"
    done
}

function download {
    bucket=$1
    path=$2
    aws s3 cp "s3://$bucket/$path" . --quiet
    echo "wrote $path"
}

function download_dir {
    bucket=$1
    path=$2
    mkdir -p dirs
    aws s3 cp "s3://$bucket/$path" dirs/ --recursive
    echo "wrote $path"
}

function upload {
    destination_bucket=$1
    source_file=$2
    aws s3 cp "$source_file" "s3://$destination_bucket/" --quiet
    echo "uploaded $source_file"
}

function copy_between_buckets {
    source_path=$1
    destination_path=$2
    aws s3 cp "s3://$source_path" "s3://$destination_path" --quiet
    echo "copied $source_path to $destination_path"
}

venv

$@
