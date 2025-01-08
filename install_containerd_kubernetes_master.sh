#!/bin/bash

# Atualiza os pacotes do sistema
apt-get update -y && apt-get upgrade -y

# Instalar net-tools
apt-get install -y net-tools

# Desativar swap (necessário para o Kubernetes)
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Ajusta kernel
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf 
overlay 
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1 
net.bridge.bridge-nf-call-ip6tables = 1 
EOF

# Ajuste necessário
echo '1' > /proc/sys/net/ipv4/ip_forward

# Atualiza os pacotes do sistema
apt-get update -y

# Instalar o containerd
apt-get install -y containerd

# Configurar o containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

# Ajuste em config.toml
sed -i '/\[plugins\."io\.containerd\.grpc\.v1\.cri"\.containerd\.runtimes\.runc\.options\]/,/^\[/{s/^\s*SystemdCgroup\s*=\s*false/    SystemdCgroup = true/}' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Atualiza os pacotes do sistema
apt-get update -y

# Instala dependências para o Kubernetes
apt-get install -y apt-transport-https ca-certificates curl gpg

# Adiciona o repositório do Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Adiciona o repositório do Kubernetes
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# Instala o Kubernetes (kubectl, kubeadm e kubelet)
apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Habilita o kubelet
systemctl restart kubelet
systemctl enable kubelet

#Novo
# Inicializa o cluster Kubernetes
kubeadm init --pod-network-cidr="192.168.0.0/16" --control-plane-endpoint=$(hostname) --upload-certs && \
echo "kubeadm init completed successfully. Sleeping for 90 seconds..." && \
sleep 90

# Configura kubectl para o usuário atual
#mkdir -p $HOME/.kube
#cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#chown $(id -u):$(id -g) $HOME/.kube/config
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config  && \
echo "Sleeping for 90 seconds..." && \
sleep 90

# Aplica o provedor de rede
echo "Verificando conectividade com a API do Kubernetes..."
if kubectl cluster-info >/dev/null 2>&1; then
    echo "Conexão com a API do Kubernetes estabelecida. Aplicando o provedor de rede..."
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
else
    echo "Erro: Não foi possível se comunicar com a API do Kubernetes. Verifique se o kubeconfig está configurado corretamente."
    exit 1
fi

# Caso ele não seja aplicado e ficar travado no coredns (pending), basta rodar o comando abaixo manualmente que vai funcionar
# kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml