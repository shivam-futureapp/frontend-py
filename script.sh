#!/bin/bash
set -xe
operation=$1
branch=$2
username=$3
PAT=$4
IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
DATABASE_URL=""

repo1=https://${username}:${PAT}@github.com/Calnetic/Scaffolding_BE.git
repo2=https://${username}:${PAT}@github.com/Calnetic/Scaffolding_FE.git

if [ -d "./test-dir" ]
 then
     cd ./test-dir
     if [ -d "./Scaffolding_BE" ]
     then
      echo "Directory backend exists" 
     else
         git clone $repo1
     fi
     if [ -d "./Scaffolding_FE" ]
     then
      echo "Directory frontend exists" 
     else
         git clone $repo2
     fi
     cd ..
else
     mkdir test-dir && cd ./test-dir
     git clone $repo1
     git clone $repo2
     cd ..
fi


branch_exist() {
local existed_in_repo=$(git ls-remote --heads origin ${branch})
    if [[ -z ${existed_in_repo} ]] || [[ $branch == '' ]]; then
        echo "Provided branch not found using default branch"
        git checkout main
    else
        echo "your branch is ${branch}"
        git checkout ${branch}
    fi
}


create () {
list_of_containers="scaffolding_be scaffolding_fe"
containers=$(docker ps -f "status=running" --format "{{.Names}}")
for container in $list_of_containers
do
  if echo $containers | grep -q $container
    then  echo "$container is up"
  else
    echo "$container is down"
    if [ "$container" == "scaffolding_be" ]; then
     if [ -d "./test-dir" ]
     then
         cd ./test-dir
     else
         mkdir test-dir && cd ./test-dir
     fi
     echo "Checking for cloned repositories"
     if [ -d "./Scaffolding_BE" ]
     then
         echo "Directory backend exists" 
         rm -rf ./Scaffolding_BE
         git clone $repo1
     else
         git clone $repo1
     fi
     cd ./Scaffolding_BE
     echo "Checking entered branch existence for Scaffolding_BE"
     branch_exist
    #  sed -i "s,DATABASE_URL=postgresql://postgres:localPass123@database:5432/newMail?schema=public,DATABASE_URL=postgresql://newmailadmin:Ne9eiw#9Ma#a9LiR@database:5432/newMail?schema=public,g" /home/ec2-user/project/projectenvschema/newmailinfra/test-dir/Scaffolding_BE/.env
    #  database_container
     if [ "$(sudo docker images -f "dangling=true" -q)" = "" ]; then
     sudo docker-compose build --no-cache backend && sudo docker-compose up -d backend
     else

       sudo docker rmi -f $(sudo docker images -f "dangling=true" -q) || true
     sudo docker-compose build --no-cache backend && sudo docker-compose up -d backend
     fi
    fi
    if [ "$container" == "scaffolding_fe" ]; then
     if [ -d "./test-dir" ]
     then
         cd ./test-dir
     else
         mkdir test-dir && cd ./test-dir
     fi
     echo "Checking for cloned repositories"
     if [ -d "./Scaffolding_FE" ]
     then
         echo "Directory frontend exists" 
         rm -rf ./Scaffolding_FE
         git clone $repo2
     else
         git clone $repo2
     fi
     cd ./Scaffolding_FE
     echo "Checking entered branch existence for Scaffolding_BE"
     branch_exist
    #  sed -i "s,#backend#,$IP:3000,g" /home/ec2-user/project/projectenvschema/newmailinfra/test-dir/Scaffolding_FE/default.conf.template
     cd ../..
     if [ "$(sudo docker images -f "dangling=true" -q)" = "" ]; then
     sudo docker-compose build --no-cache frontend && sudo docker-compose up -d frontend
     else
     sudo docker rmi -f $(sudo docker images -f "dangling=true" -q) || true
     sudo docker-compose build --no-cache frontend && sudo docker-compose up -d frontend
     fi
    fi
 fi
done
}

destroy () {
cd ./test-dir
cd ./Scaffolding_BE
git remote update
status=$(git status -uno | awk 'FNR == 2 {print $4}')
if [ "$status" == "up" ]; then
  echo "your backend repo is upto date"
  cd ../..
  else
  cd ../..
  echo "docker compose is destroying"
  sudo docker-compose rm -svf backend
  echo "Removing images from local system"
  if [ "$(sudo docker images | awk '{print $1}' | grep -i scaffolding_backend)" = "scaffolding_backend" ]; then
  IMAGE=$(echo "${PWD##*/}" | tr '[:upper:]' '[:lower:]')
  sudo docker rmi ${IMAGE}_backend
  else
  echo "Image not found locally skipping it"
  fi
fi
cd ./test-dir
cd ./Scaffolding_FE
git remote update
status=$(git status -uno | awk 'FNR == 2 {print $4}')
if [ "$status" == "up" ]; then
  echo "your frontend repo is upto date"
  cd ../..
  else
  cd ../..
  echo "docker compose is destroying"
  sudo docker-compose rm -svf frontend
  echo "Removing images from local system"
  if [ "$(sudo docker images | awk '{print $1}' | grep -i scaffolding_frontend)" = "scaffolding_frontend" ]; then
  IMAGE=$(echo "${PWD##*/}" | tr '[:upper:]' '[:lower:]')
  sudo docker rmi ${IMAGE}_frontend
  else
  echo "Image not found locally skipping it"
  fi
fi
}

case ${operation} in
  create) create ;;
    destroy) destroy ;;
       *) echo "Unknown action ${operation}" ;;
esac
    
