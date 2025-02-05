# Terraform GCP Pipeline - Infraestrutura Automatizada

Este repositório contém uma pipeline configurada no GitHub Actions que utiliza Terraform para provisionar recursos na Google Cloud Platform (GCP). O projeto é projetado para criar uma infraestrutura básica com quatro instâncias, regras de firewall, rede e sub-rede. Além disso, ele instala softwares necessários como Containerd, Kubernetes e Docker. 

## Recursos Criados

- **Quatro Instâncias de máquinas virtuais na GCP**
- **Regras de firewall**
- **Rede e sub-rede personalizadas**
- **Configuração de um cluster Kubernetes com Rancher**

## Configuração Inicial

### Ajustando as Secrets no Repositório do GitHub
1. **Adicionar a chave JSON da Service Account da GCP**
   - Crie uma secret no repositório com o nome `GOOGLE_APPLICATION_CREDENTIALS`, contendo o arquivo JSON da sua Service Account.
2. **Adicionar o código do projeto da GCP**
   - Crie uma secret no repositório com o nome `PROJECT_ID`, contendo o ID do projeto na GCP.

![image](https://github.com/user-attachments/assets/c48bb2dd-6ed6-4921-975f-3c9489896305)

### Criando um Bucket Manualmente na GCP (Privado)
1. Crie um bucket privado na GCP.
2. Adicione a Service Account usada neste projeto como usuário do bucket com permissões adequadas.
3. Atualize o arquivo `main.tf`, configurando o nome do bucket no bloco `backend "gcs"` para armazenar o estado remoto do Terraform.

![image](https://github.com/user-attachments/assets/6984d1e4-4fd7-4ac3-a6ec-1dc77e1ee9b7)

## Executando a Pipeline

### Rodando a Criação das Máquinas pela Pipeline
1. Clone o repositório, ajuste as secrets e crie o bucket conforme os passos anteriores.
2. Acesse a aba **Actions** no repositório.
3. Selecione o workflow `terraform plan-apply` para iniciar a criação da infraestrutura.
4. Aguarde a conclusão do processo.

![image](https://github.com/user-attachments/assets/34fb150a-bdaa-4092-8142-300253cbe32d)

## Configuração do Rancher

### Acessando o Rancher
1. Conecte-se à máquina do Rancher via SSH na GCP.
2. Execute:
   ```bash
   docker ps -a
   ```
   Pegue o ID do container.
3. Extraia a senha default:
   ```bash
   docker logs <container-id> 2>&1 | grep "Bootstrap Password:"
   ```
4. Acesse o IP externo da máquina do Rancher no navegador e insira a senha.
5. Configure uma nova senha e aceite os termos.

![image](https://github.com/user-attachments/assets/a78e6698-8cd9-45de-a4ec-453d8a7402f7)

### Adicionando o Node Master e os Dois Workers
1. Acesse a máquina master via SSH na GCP.
2. Verifique se está tudo em pé
   ```bash
   kubeadm get pods -A
   ```
   Caso ele ficar travado no coredns (pending), basta rodar o comando abaixo manualmente que vai funcionar
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
   ```
3. Gere o comando de join:
   ```bash
   kubeadm token create --print-join-command
   ```
4. Conecte-se às máquinas workers via SSH na GCP.
5. Cole e execute o comando gerado anteriormente.
6. Teste a configuração:
   ```bash
   kubectl get nodes
   ```
   O resultado deve listar o control plane e os dois workers.

![image](https://github.com/user-attachments/assets/f1c07f91-58e0-4c6a-92cf-cd2ef306f0e1)

## Configuração no Rancher

### Adicionando o Cluster no Rancher
1. No painel do Rancher, clique em **Importar Existente**.
2. Escolha **Generic**.
3. Dê um nome para o cluster e clique em **Continue**.
4. Copie o comando exibido (contendo `curl --insecure`) e execute na máquina master.
5. Aguarde a conclusão do registro do cluster.

![image](https://github.com/user-attachments/assets/29e7be2f-4e61-4470-8aa0-a77ff94798a7)

## Opcional - Destruir Toda a Infraestrutura

1. Execute o workflow `terraform destroy` na aba **Actions**.
2. Exclua o bucket criado manualmente.
3. Delete a Service Account utilizada.

---

## Prontinho, agora você já deve ter sua infraestrutura Kubernetes configurada e adicionada no Rancher para um melhor gerenciamento
