#!/bin/bash

# Atualiza os pacotes do sistema
apt-get update -y && apt-get upgrade -y

# Instalar net-tools
apt-get install -y net-tools

# Instala dependências para Docker
apt-get install -y apt-transport-https ca-certificates curl
install -m 0755 -d /etc/apt/keyrings

# Adiciona o repositório do Docker
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Adiciona o repositório do Docker para o APT
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instala o Docker
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Habilita e inicia o serviço do Docker
systemctl enable docker
systemctl start docker

# Atualiza os pacotes do sistema
apt-get update -y && apt-get upgrade -y

# Subir o Rancher no Docker
echo "Subindo o container do Rancher..."
container_id=$(docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged -v /srv/rancher_data:/var/lib/rancher rancher/rancher:head)

# Verificar se o container foi iniciado corretamente
if [ -z "$container_id" ]; then
    echo "Erro: O container do Rancher não foi iniciado."
    exit 1
fi

echo "Container Rancher iniciado com ID: $container_id"

# Verificar se o container está up antes de buscar os logs
echo "Verificando se o container está up..."
until docker ps -q --filter "id=$container_id" | grep -q .; do
    echo "Aguardando o container iniciar..."
    sleep 5  # Espera 5 segundos antes de verificar novamente
done

echo "Container Rancher está up."

# Obter a senha de bootstrap dos logs
bootstrap_password=$(docker logs "$container_id" 2>&1 | grep "Bootstrap Password:" | awk -F': ' '{print $2}' | tr -d '\r')

# Marca a conclusão da execução
echo "Instalação concluída com sucesso!"