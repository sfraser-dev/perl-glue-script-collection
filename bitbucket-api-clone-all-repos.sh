#!/bin/bash
#Script to get all repositories under a user from bitbucket
#Usage: getAllRepos.sh [username]

curl -u ${1} https://api.bitbucket.org/1.0/users/${1} > repoinfo
for repo_name in `grep \"name\" repoinfo | cut -f4 -d\"`
do
	#git clone ssh://git@bitbucket.org/${1}/$repo_name
    echo $repo_name
done
