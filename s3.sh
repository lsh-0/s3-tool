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
    aws s3 ls
}

function contents {
    bucket=$1
    aws s3 ls "$bucket" | tee last-listing.txt
}

function download {
    bucket=$1
    path=$2
    aws s3 cp "s3://$bucket/$path" . --quiet
    echo "wrote $path"
}

function upload {
    destination_bucket=$1
    source_file=$2
    aws s3 cp "$source_file" "s3://$destination_bucket/" --quiet
    echo "uploaded $source_file"
}

venv

$@
