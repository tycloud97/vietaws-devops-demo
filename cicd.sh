#!/bin/sh

echo "************** Creating CI/CD pipeline ****************"
curdir=$(pwd)

sample_app_repository_url=$(terraform output -raw repository_url)
cd $curdir/sample-app
git init
git remote add origin $sample_app_repository_url
git add .
git commit -m "resource api"
git push -u origin master