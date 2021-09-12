#!/bin/bash 
while getopts c:n: flag
do
    case "${flag}" in
        c) chart=${OPTARG};;
        n) namespace=${OPTARG};;
    esac
done

mkdir -p charts 
helm fetch \ 
    --untar \ 
    --untardir charts \ 
    "$chart"

mkdir -p base
helm template \
    --output-dir base \
    --namespace "$namespace" \
    --values values.yaml \
    "${chart##*/}" \
    charts/"${chart##*/}"

for filename in /base/"$name"*.txt; do
    for ((i=0; i<=3; i++)); do
        ./MyProgram.exe "$filename" "Logs/$(basename "$filename" .txt)_Log$i.txt"
    done
done
