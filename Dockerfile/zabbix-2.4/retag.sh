#!/bin/bash

# use on master branche and retag also older tags

tags=()
for t in `git tag`
do
    if [[ "$t" != ^2* ]]; then
         continue
    fi
    echo "Deleting tags $t"
    git tag -d $t
    git push origin :refs/tags/$t
    tags=("${tags[@]}" "$t")
done
git push origin master
git push origin --tags

tags=('2.4.0' '2.4.1' '2.4.2' '2.4.3' '2.4.4' '2.4.5' '2.4.6' '2.4.7' '2.4.8');
for t in "${tags[@]}"
do
    echo "Creating tags $t"
    git checkout master
    sed -i -e "s#^  ZABBIX_VERSION=tags.*#  ZABBIX_VERSION=tags/$t \\\#" Dockerfile
    git add Dockerfile
    git commit -m "Tag $t"
    git tag -a $t -m "Tag $t"
    last=$t        
done
git push origin master
git push origin --tags

