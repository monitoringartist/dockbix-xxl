#!/bin/bash
# use on master branch and retag also older tags

# delete all current tags
tags=()
for t in `git tag`
do
    if [[ "$t" != 3* ]]; then
         continue
    fi
    echo "Deleting tags $t"
    git tag -d $t
    git push origin :refs/tags/$t
    tags=("${tags[@]}" "$t")
done
git push origin master
git push origin --tags

# create tags from the list
tags=('3.0.0' '3.0.1' '3.0.2' '3.0.3' '3.0.4');
for t in "${tags[@]}"
do
    echo "Creating tags $t"
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

# master is dev image = trunk
git checkout master
sed -i -e "s#^[[:space:]]*ZABBIX_VERSION=.*#  ZABBIX_VERSION=trunk \\\#" Dockerfile
sleep 5
git add Dockerfile
sleep 5
git commit -m "Master = dev = trunk"
git push origin master

