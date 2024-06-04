#!/bin/bash

# Verifica se o Docker está instalado e em execução
check_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker before running this script."
    exit 1
  fi

  if ! systemctl is-active --quiet docker; then
    echo "Docker is not running. Please start Docker before running this script."
    exit 1
  fi
}

# Verifica a configuração do SSH
check_ssh() {
  if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "SSH authentication failed. Please ensure your SSH keys are correctly set up."
    exit 1
  fi
}

# Lê o arquivo .env e exporta as variáveis de ambiente
read_env() {
  if [ ! -f ".env" ]; then
    return 0
  fi

  while read -r LINE; do
    CLEANED_LINE=$(echo "$LINE" | awk '{$1=$1};1' | tr -d '\r')

    if [[ $CLEANED_LINE != '#'* ]] && [[ $CLEANED_LINE == *'='* ]]; then
      export "$CLEANED_LINE"
    fi
  done < ".env"
}

# Verifica se as variáveis de ambiente EMAIL e DOMAIN estão definidas
check_env() {
  if [ -z "$EMAIL" ] || [ -z "$DOMAIN" ]; then
    echo "Por favor, defina as variáveis de ambiente EMAIL e DOMAIN."
    exit 1
  fi
}

check_docker

check_ssh

read_env && check_env

# Inicia o serviço do Traefik (proxy reverso)
docker network create traefik
docker-compose up -d

git clone git@github.com:Nocs-lab/inbcm-backend.git
git clone git@github.com:Nocs-lab/inbcm-public-frontend.git
git clone git@github.com:Nocs-lab/inbcm-admin-frontend.git

cd inbcm-backend
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

cd ../inbcm-public-frontend
docker compose up -d

cd ../inbcm-admin-frontend
docker compose up -d

echo "Setup concluído com sucesso!"
echo "Acesse em https://$DOMAIN e https://admin.$DOMAIN"
