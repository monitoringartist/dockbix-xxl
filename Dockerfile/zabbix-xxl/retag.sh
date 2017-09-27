#!/bin/bash
# use on master branch and retag also older tags

# delete all current tags
git fetch --tags --force
tags=()
for t in `git tag`
do
    if [[ "$t" != 3* ]]; then
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
tags=('3.0.0' '3.0.1' '3.0.2' '3.0.3' '3.0.4' '3.0.5' '3.0.6' '3.0.7' '3.0.8' '3.0.9' '3.0.10' '3.2.0' '3.2.1' '3.2.2' '3.2.3' '3.2.4' '3.2.5' '3.2.6' '3.2.7');
for t in "${tags[@]}"
do
    echo "Creating tag $t"
    git checkout master
    sed -i -e "s#^[[:space:]]*ZABBIX_VERSION=.*#  ZABBIX_VERSION=tags/$t \\\#" Dockerfile
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
sed -i -e "s#^[[:space:]]*ZABBIX_VERSION=.*#  ZABBIX_VERSION=tags/3.2.6 \\\#" Dockerfile
sleep 5
git add Dockerfile
sleep 5
git commit -m "Master = the latest stable tag"
git push origin master

