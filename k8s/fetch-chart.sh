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

# Empty the existing chart directory
rm -r charts/"${chart##*/}"
# Get the current helm chart
helm fetch \
    --untar \
    --untardir charts \
    $chart

# Empty the existing base directory
rm -r base/"${chart##*/}"/*
# Create a values.yaml if ti doesn't exist
if [ ! -e "$file" ] ; then
    touch overlays/"${chart##*/}"/values.yaml
fi
# Genereate the templates from the helm chart
helm template \
    --output-dir base \
    --namespace "$namespace" \
    --values overlays/"${chart##*/}"/values.yaml \
    ${chart##*/} \
    charts/"${chart##*/}"

# Kustomization file content
kustomization="apiVersion: kustomize.config.k8s.io/v1beta1\nkind: Kustomization\nnamespace: ${namespace}\nresources:"
# Move all files out of the templates directory
mv base/${chart##*/}/templates/* base/${chart##*/}/
rm -r base/${chart##*/}/templates
# Iterate through /base directory
for filename in $(find base/${chart##*/} -name "*.yaml"); do
    kustomization+="\n- ${filename#base/${chart##*/}/}"
done
# Write all file names to the kustomization file
echo -e $kustomization > base/${chart##*/}/kustomization.yaml
