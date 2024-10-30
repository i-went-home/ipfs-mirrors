#!/bin/bash

IPFS_KEY="portage-distfiles"
IPFS_DIR="/${IPFS_KEY}"
DIR=~/${IPFS_KEY}/


echo "files: find new"
found=$(ipfs files ls ${IPFS_DIR})
files=$(find ${DIR} -maxdepth 1 -type f \
 -not \( -path '*/[@.]*' -o -iname '*.__download__*' -o -iname '*fail*' \) \
 $(printf " -not -name %s " ${found}))

if [[ -z "${files}" ]]
then
    echo "files: no new"
else
    # TODO: progress
    for f in ${files}
    do
        ipfs add ${f} --progress=true --pin=false --nocopy=true --to-files ${IPFS_DIR}/
    done

    # publish ipns
    key=$(ipfs key list | grep ${IPFS_KEY})
    if [[ -z "${key}" ]]
    then
        #ipfs key gen ${IPFS_KEY}
        echo "ipfs: no key"
    else
        hash=$(ipfs files stat --hash ${IPFS_DIR})
        if [[ ! -z "${hash}" ]]
        then
            echo "ipfs: publish"
            ipfs name publish --key=${IPFS_KEY} /ipfs/${hash}
        fi
    fi
fi
