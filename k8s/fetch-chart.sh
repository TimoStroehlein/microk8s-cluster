#!/bin/bash 
while getopts c:n: flag
do
    case "${flag}" in
        c) chart=${OPTARG};;
        n) namespace=${OPTARG};;
    esac
done

if [ -z "$chart" ] || [ -z "$namespace" ]; then
    echo "Not all parameters provided."
    echo "Required: -c chart, -n namespace"
    exit 1
fi

mkdir -p charts 
rm -r charts/"${chart##*/}"
helm fetch \
    --untar \
    --untardir charts \
    $chart

mkdir -p base
helm template \
    --output-dir base \
    --namespace "$namespace" \
    --values overlays/"${chart##*/}"/values.yaml \
    ${chart##*/} \
    charts/"${chart##*/}"

kustomization="apiVersion: kustomize.config.k8s.io/v1beta1\nkind: Kustomization\nnamespace: ${namespace}\nresources:"
for filename in $(find base/${chart##*/}/templates -name "*.yaml"); do
    mv $filename base/${chart##*/}/
    kustomization+="\n- ${filename##*/}"
done
# Remove all empty directories
find base/${chart##*/}/ -type d -empty -delete
echo -e $kustomization > base/${chart##*/}/kustomization.yaml

mkdir -p overlays
mkdir -p overlays/${chart##*/}
