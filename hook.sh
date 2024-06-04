#!/bin/bash

update_and_deploy() {
  local dir=$1
  local compose_files=$2

  if [ -z "$compose_files" ]; then
    compose_files="-f compose.yaml"
  fi

  cd "$dir"
  git remote update > /dev/null
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse @{u})
  BASE=$(git merge-base @ @{u})

  if [ $LOCAL != $REMOTE ]; then
    git pull
    docker compose $compose_files up -d --build
  fi

  cd -
}

update_and_deploy "inbcm-backend" "-f docker-compose.yml -f docker-compose.prod.yml"
update_and_deploy "inbcm-public-frontend"
update_and_deploy "inbcm-admin-frontend"
