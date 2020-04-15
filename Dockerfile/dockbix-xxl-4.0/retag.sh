#!/bin/bash
# use on master branch and retag also older tags

# delete all current tags
git fetch --tags --force
tags=()
for t in `git tag`
do
    if [[ "$t" != 4.0* ]]; then
         continue
    fi
    echo "Deleting tag $t"
    git tag -d $t
    git push origin :refs/tags/$t
    tags=("${tags[@]}" "$t")
done
git push origin master
git push origin --tags

# create tags from the list
tags=('4.0.0' '4.0.1' '4.0.2' '4.0.3' '4.0.4' '4.0.5' '4.0.6' '4.0.7' '4.0.8' '4.0.9' '4.0.10' '4.0.11' '4.0.12' '4.0.13' '4.0.14' '4.0.15' '4.0.16' '4.0.17' '4.0.18' '4.0.18' '4.0.19');
for t in "${tags[@]}"
do
    echo "Creating tag $t"
    git checkout master
    sed -i -e "s#^[[:space:]]*ZABBIX_VERSION=.*#  ZABBIX_VERSION=$t \\\#" Dockerfile
    sleep 5    
    git add Dockerfile
    sleep 5
    git commit -m "Tag $t"
    sleep 5
    git tag -a $t -m "Tag $t"
    sleep 5
    last=$t        
done
git push origin master
git push origin --tags

# master is the latest stable tag
git checkout master
sed -i -e "s#^[[:space:]]*ZABBIX_VERSION=.*#  ZABBIX_VERSION=4.0.19 \\\#" Dockerfile
sleep 5
git add Dockerfile
sleep 5
git commit -m "Master = the latest stable tag"
git push origin master
