#!/bin/bash

# use on master branche and retag also older tags

tags=()
for t in `git tag`
do
    echo "Deleting tags $t"
    git tag -d $t
    git push origin :refs/tags/$t
    tags=("${tags[@]}" "$t")
done
git push origin master
git push origin --tags

tags=('2.4.0rc1' '2.4.0rc2' '2.4.0rc3' '2.4.1' '2.4.1rc1' '2.4.1rc2' '2.4.2' '2.4.2rc1' '2.4.3' '2.4.3rc1' '2.4.4' '2.4.4rc1' '2.4.5' '2.4.5rc1' '2.4.6' '2.4.7');
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

