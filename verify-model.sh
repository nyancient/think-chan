#!/bin/bash
model_json="$1"
assets_dir="$2"

status=0
for style in $(cat "$model_json" | jq -r ".styles | keys.[]") ; do
    for expression in $(cat "$model_json" | jq -r ".styles.$style.expressions | keys.[]") ; do
        for variant in $(cat "$model_json" | jq -r ".styles.$style.expressions.$expression | keys.[]") ; do
            for frame in $(cat "$model_json" | jq -r ".styles.$style.expressions.$expression.\"$variant\".[]") ; do
                asset_path="$assets_dir/$style/$expression/$variant/$frame"
                if ! [ -f "$asset_path" ] ; then
                    echo "ERROR: asset '$asset_path' does not exist" && status=1
                fi
            done
        done
    done
done
exit $status
