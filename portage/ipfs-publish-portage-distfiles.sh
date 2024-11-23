#!/bin/bash

# В GENTOO_MIRRORS указан путь до distfiles, а не distfiles.
IPFS_PUB_KEY="portage"
IPFS_PUB_DIR="/${IPFS_PUB_KEY}"

IPFS_DIR="${IPFS_PUB_DIR}/distfiles"
DIR=~/${IPFS_DIR}/


echo "files: find new"
found=$(ipfs files ls ${IPFS_DIR})
if [[ -z "${found}" ]]
then
    files=$(find ${DIR} -maxdepth 1 -type f \
        -not \( -path '*/[@.]*' -o -iname '*.__download__*' -o -iname '*fail*' \))
else
    files=$(find ${DIR} -maxdepth 1 -type f \
        -not \( -path '*/[@.]*' -o -iname '*.__download__*' -o -iname '*fail*' \) \
        $(printf " -not -name %s " ${found}))
fi


if [[ -z "${files}" ]]
then
    echo "files: no new"
else
    # TODO: progress
    for f in ${files}
    do
        ipfs add ${f} --progress=true --pin=false --to-files ${IPFS_DIR}/
    done
fi

    # publish ipns
    key=$(ipfs key list | grep ${IPFS_PUB_KEY})
    if [[ -z "${key}" ]]
    then
        #ipfs key gen ${IPFS_PUB_KEY}
        echo "ipfs: no key"
    else
        hash=$(ipfs files stat --hash ${IPFS_PUB_DIR})
        if [[ ! -z "${hash}" ]]
        then
            echo "ipfs: publish"
            ipfs name publish --key=${IPFS_PUB_KEY} /ipfs/${hash}
        fi
    fi
