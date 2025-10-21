# Guia de Deploy - Hortti Inventory

Este guia documenta o processo completo de deploy da aplicação Hortti Inventory em produção na AWS com Terraform, Ansible e GitHub Actions.

## Índice

- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Configuração Inicial](#configuração-inicial)
- [Deploy Manual](#deploy-manual)
- [Deploy com GitHub Actions](#deploy-com-github-actions)
- [Domínios e SSL](#domínios-e-ssl)
- [Troubleshooting](#troubleshooting)

## Arquitetura

### Infraestrutura

- **Cloud Provider:** AWS (us-east-2 - Ohio)
- **Compute:** EC2 t2.medium (Ubuntu 22.04 LTS)
- **DNS:** Cloudflare
- **SSL:** Let's Encrypt via Traefik (DNS Challenge)
- **Reverse Proxy:** Traefik v2.11
- **IaC:** Terraform
- **Config Management:** Ansible
- **CI/CD:** GitHub Actions
- **Container Registry:** GitHub Container Registry (ghcr.io)

### Serviços

```
┌─────────────────────────────────────────────────────┐
│                   cantinhoverde.app.br              │
│                      (Frontend)                      │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────┐
│                    Traefik                          │
│           (Reverse Proxy + SSL/TLS)                 │
└──────┬───────────────┬────────────────┬─────────────┘
       │               │                │
       │               │                │
   ┌───▼────┐     ┌───▼────┐      ┌───▼────┐
   │Frontend│     │Backend │      │Traefik │
   │Next.js │     │NestJS  │      │Dashboard│
   │:3000   │     │:3001   │      │        │
   └────────┘     └───┬────┘      └────────┘
                      │
                  ┌───▼────┐
                  │PostgreSQL│
                  │:5432   │
                  └────────┘
```

### Domínios

- **Frontend:** `cantinhoverde.app.br`
- **Backend API:** `api.cantinhoverde.app.br`
- **Traefik Dashboard:** `traefik.cantinhoverde.app.br`

## Pré-requisitos

### Ferramentas Locais

```bash
# Terraform >= 1.5.0
terraform -v

# Ansible >= 2.15
ansible --version

# AWS CLI v2
aws --version

# Docker
docker --version

# Make
make --version
```

### Credenciais Necessárias

1. **AWS:**
   - Access Key ID
   - Secret Access Key
   - Permissões: EC2, VPC, EIP, S3, DynamoDB

2. **Cloudflare:**
   - API Token com permissões de DNS Edit
   - Zone ID do domínio `cantinhoverde.app.br`

3. **GitHub:**
   - Personal Access Token (PAT) com permissões `write:packages`
   - Acesso ao repositório

4. **SSH:**
   - Par de chaves SSH (pública/privada)

## Configuração Inicial

### 1. Configurar AWS CLI

```bash
aws configure
# Insira:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-2
# - Default output format: json
```

### 2. Criar Backend do Terraform (S3)

```bash
# Cria bucket S3 e tabela DynamoDB para state do Terraform
make infra-setup-backend
```

### 3. Configurar Terraform

```bash
# Copiar exemplo
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars

# Editar com seus valores
vim infra/terraform/terraform.tfvars
```

**Conteúdo do `terraform.tfvars`:**

```hcl
# General
environment  = "prod"
project_name = "hortti-inventory"

# AWS
aws_region    = "us-east-2"
instance_type = "t2.medium"

# SSH Key
ssh_key_name   = "hortti-prod-key"
ssh_public_key = "ssh-rsa AAAAB3NzaC... seu-email@example.com"

# Security
allowed_ssh_cidr = ["SEU.IP.PUBLICO.AQUI/32"]  # Use seu IP específico!

# Cloudflare
cloudflare_api_token = "seu_token_cloudflare"
cloudflare_zone_id   = "seu_zone_id"

# Domain
domain_name        = "cantinhoverde.app.br"
frontend_subdomain = ""        # Vazio = domínio raiz
backend_subdomain  = "api"
traefik_subdomain  = "traefik"
```

### 4. Gerar Chave SSH (se não tiver)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/hortti-prod-key -C "hortti-prod"
# Cole o conteúdo de ~/.ssh/hortti-prod-key.pub em terraform.tfvars
```

### 5. Configurar Ansible

```bash
# Setup inicial
make deploy-setup

# Editar secrets
vim infra/ansible/vars/secrets.yml
```

**Gerar senhas seguras:**

```bash
# PostgreSQL password
openssl rand -base64 32

# JWT secrets
openssl rand -base64 32

# Traefik auth (htpasswd)
htpasswd -nb admin SuaSenhaForte
```

**Conteúdo do `secrets.yml`:**

```yaml
---
# GitHub
github_repo_owner: "seu-usuario"
github_token: "ghp_seu_token_aqui"

# Domains
frontend_domain: "cantinhoverde.app.br"
backend_domain: "api.cantinhoverde.app.br"
traefik_domain: "traefik.cantinhoverde.app.br"

# PostgreSQL
postgres_user: "hortti_admin"
postgres_password: "SENHA_SEGURA_GERADA"
postgres_db: "hortti_inventory"

# JWT
jwt_secret: "SECRET_JWT_GERADO"
jwt_refresh_secret: "SECRET_REFRESH_GERADO"

# Cloudflare
cloudflare_dns_token: "seu_token_dns"
cloudflare_zone_token: "seu_token_zone"

# ACME
acme_email: "seu-email@example.com"

# Traefik Auth
traefik_dashboard_auth: "admin:$apr1$..."
```

### 6. Criptografar Secrets (Recomendado)

```bash
# Criar vault password
echo "SuaSenhaDoVault" > ~/.ansible_vault_pass

# Criptografar
ansible-vault encrypt infra/ansible/vars/secrets.yml \
  --vault-password-file ~/.ansible_vault_pass

# Para editar depois
ansible-vault edit infra/ansible/vars/secrets.yml \
  --vault-password-file ~/.ansible_vault_pass
```

## Deploy Manual

### Passo 1: Provisionar Infraestrutura

```bash
# Inicializar Terraform
make infra-init

# Validar configuração
make infra-validate

# Planejar mudanças
make infra-plan

# Aplicar infraestrutura
make infra-apply
```

**Outputs esperados:**

```
ec2_public_ip = "3.XXX.XXX.XXX"
frontend_url = "https://cantinhoverde.app.br"
backend_url = "https://api.cantinhoverde.app.br"
traefik_dashboard_url = "https://traefik.cantinhoverde.app.br"
ssh_command = "ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@3.XXX.XXX.XXX"
```

### Passo 2: Aguardar DNS Propagar

```bash
# Verificar DNS (pode levar alguns minutos)
dig cantinhoverde.app.br
dig api.cantinhoverde.app.br
dig traefik.cantinhoverde.app.br

# Todos devem apontar para o IP da EC2
```

### Passo 3: Atualizar Inventário Ansible

```bash
# Editar inventory com o IP da EC2
vim infra/ansible/inventory/hosts.ini
```

```ini
[production]
hortti-prod ansible_host=3.XXX.XXX.XXX  # IP do output do Terraform

[production:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/hortti-prod-key.pem
ansible_python_interpreter=/usr/bin/python3
```

### Passo 4: Build e Push das Imagens Docker

```bash
# Configurar variáveis
export GITHUB_USER="seu-usuario"
export GITHUB_TOKEN="ghp_seu_token"

# Login no registry
make docker-login

# Build e push
make docker-build-push
```

### Passo 5: Deploy com Ansible

```bash
# Verificar conectividade
make deploy-check

# Deploy
make deploy

# OU usar vault se criptografou secrets
cd infra/ansible && ansible-playbook playbook.yml \
  --vault-password-file ~/.ansible_vault_pass
```

### Passo 6: Verificar Deploy

```bash
# Verificar status
make prod-status

# Ver logs
make prod-logs

# Acessar URLs
curl -I https://cantinhoverde.app.br
curl -I https://api.cantinhoverde.app.br/api/health
```

## Deploy com GitHub Actions

### 1. Configurar Secrets no GitHub

Vá em **Settings → Secrets and variables → Actions** e adicione:

```
# AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

# SSH
SSH_PUBLIC_KEY          # Conteúdo de ~/.ssh/hortti-prod-key.pub
SSH_PRIVATE_KEY         # Conteúdo de ~/.ssh/hortti-prod-key (PEM)
ALLOWED_SSH_CIDR        # Seu IP/32

# Cloudflare
CLOUDFLARE_API_TOKEN
CLOUDFLARE_ZONE_ID
CLOUDFLARE_DNS_TOKEN
CLOUDFLARE_ZONE_TOKEN

# Database
POSTGRES_USER
POSTGRES_PASSWORD
POSTGRES_DB

# JWT
JWT_SECRET
JWT_REFRESH_SECRET

# Email
ACME_EMAIL

# Traefik
TRAEFIK_DASHBOARD_AUTH

# API URL (build time)
NEXT_PUBLIC_API_URL     # https://api.cantinhoverde.app.br/api
```

### 2. Build de Imagens (Automático)

As imagens são automaticamente construídas e enviadas ao GHCR quando você faz push na branch `main`:

```bash
git add .
git commit -m "feat: update application"
git push origin main
```

### 3. Deploy via Actions

1. Acesse **Actions** no GitHub
2. Selecione **Deploy to Production**
3. Clique em **Run workflow**
4. Configure:
   - **Terraform action:** `apply` (primeira vez) ou `plan`
   - **Deploy app:** `true`
   - **Image tag:** `latest` ou tag específica

### 4. Workflow Completo

O workflow executa automaticamente:

1. ✅ Terraform plan/apply (provisiona infraestrutura)
2. ✅ Aguarda EC2 estar pronta
3. ✅ Ansible deploy (configura servidor + deploy app)
4. ✅ Verificação de health
5. ✅ Notificação de status

## Domínios e SSL

### Cloudflare DNS Records

Os seguintes registros DNS são criados automaticamente pelo Terraform:

| Nome | Tipo | Valor | Proxy |
|------|------|-------|-------|
| @ | A | IP_DA_EC2 | ❌ Off |
| api | A | IP_DA_EC2 | ❌ Off |
| traefik | A | IP_DA_EC2 | ❌ Off |

**Importante:** O proxy da Cloudflare deve estar **desabilitado** (DNS only) para que o Let's Encrypt DNS Challenge funcione.

### SSL/TLS (Let's Encrypt)

- **Método:** DNS Challenge (Cloudflare)
- **Renovação:** Automática
- **Certificados:** Armazenados em volume Docker persistente

**Verificar certificados:**

```bash
# Via Traefik dashboard
https://traefik.cantinhoverde.app.br

# Via OpenSSL
openssl s_client -connect cantinhoverde.app.br:443 -servername cantinhoverde.app.br
```

## Comandos Úteis

### Infraestrutura

```bash
# Ver outputs do Terraform
make infra-output

# Atualizar state
make infra-refresh

# Destruir tudo (CUIDADO!)
make infra-destroy
```

### Produção

```bash
# Deploy completo (build + push + deploy)
make prod-deploy

# Status dos serviços
make prod-status

# Logs em tempo real
make prod-logs

# Reiniciar aplicação
make prod-restart
```

### SSH na EC2

```bash
# Via Makefile output
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@$(terraform output -raw ec2_public_ip)

# Ou pegue o comando do output
make infra-output
```

### Docker na EC2

```bash
# Via SSH
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@IP_DA_EC2

# Dentro da EC2
cd /opt/hortti-inventory
docker compose ps
docker compose logs -f
docker compose restart
```

## Troubleshooting

### Problema: Terraform state locked

**Sintoma:** Erro "Error acquiring the state lock"

**Solução:**

```bash
# Verificar locks no DynamoDB
aws dynamodb scan --table-name hortti-terraform-locks --region us-east-2

# Forçar unlock (cuidado!)
cd infra/terraform && terraform force-unlock LOCK_ID
```

### Problema: SSL não funciona

**Sintomas:**
- Erro "ERR_SSL_VERSION_OR_CIPHER_MISMATCH"
- Let's Encrypt challenge falha

**Checklist:**

1. DNS propagado? `dig cantinhoverde.app.br`
2. Cloudflare proxy desabilitado? (deve estar cinza/DNS only)
3. Portas 80/443 abertas no security group?
4. Cloudflare API tokens corretos?

**Debug:**

```bash
# Ver logs do Traefik
ssh ubuntu@IP_DA_EC2
cd /opt/hortti-inventory
docker compose logs traefik | grep acme
```

### Problema: Ansible não conecta

**Sintomas:**
- "Permission denied (publickey)"
- "Timeout waiting for connection"

**Soluções:**

```bash
# Verificar chave SSH
ls -la ~/.ssh/hortti-prod-key.pem
chmod 600 ~/.ssh/hortti-prod-key.pem

# Testar SSH manualmente
ssh -vvv -i ~/.ssh/hortti-prod-key.pem ubuntu@IP_DA_EC2

# Verificar security group (porta 22)
aws ec2 describe-security-groups --region us-east-2
```

### Problema: Imagens não sobem para GHCR

**Sintomas:**
- "denied: permission_denied"

**Soluções:**

```bash
# Verificar token do GitHub
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin

# Token precisa de permissões write:packages
# Gere novo em: https://github.com/settings/tokens

# Verificar visibilidade do pacote
# Settings → Packages → Change visibility → Public
```

### Problema: Deploy falha com "unhealthy container"

**Sintomas:**
- Container restart loop
- Health check failing

**Debug:**

```bash
# SSH na EC2
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@IP_DA_EC2

cd /opt/hortti-inventory

# Ver status
docker compose ps

# Ver logs
docker compose logs backend
docker compose logs frontend

# Verificar .env
cat .env

# Restart manual
docker compose restart
```

### Problema: Custos inesperados na AWS

**Checklist mensal:**

```bash
# Ver recursos ativos
aws ec2 describe-instances --region us-east-2
aws ec2 describe-volumes --region us-east-2
aws ec2 describe-snapshots --owner-ids self --region us-east-2

# Ver EIPs não associados (são cobrados!)
aws ec2 describe-addresses --region us-east-2

# Destruir tudo quando não usar
make infra-destroy
```

## Custos Estimados (AWS us-east-2)

| Recurso | Especificação | Custo/mês (USD) |
|---------|---------------|-----------------|
| EC2 t2.medium | 24/7 | ~$33.87 |
| EBS gp3 30GB | Volume raiz | ~$2.40 |
| EIP | IP elástico | Grátis (se associado) |
| Data Transfer | Primeiros 100GB | Grátis |
| **TOTAL** | | **~$36.27/mês** |

**Nota:** Custos podem variar. Use AWS Cost Explorer para monitorar.

## Segurança

### Checklist de Produção

- [ ] Firewall configurado (UFW na EC2)
- [ ] Security Group restrito (SSH apenas do seu IP)
- [ ] Credenciais em secrets (Ansible Vault)
- [ ] SSL/TLS ativo (HTTPS)
- [ ] Volumes criptografados
- [ ] Senhas fortes e únicas
- [ ] Tokens com permissões mínimas
- [ ] Backups configurados
- [ ] Logs monitorados
- [ ] Updates automáticos do sistema

### Backups

```bash
# Backup manual do banco
ssh ubuntu@IP_DA_EC2
cd /opt/hortti-inventory
docker compose exec db pg_dump -U hortti_admin hortti_inventory > backup.sql

# Copiar para local
scp -i ~/.ssh/hortti-prod-key.pem ubuntu@IP_DA_EC2:/opt/hortti-inventory/backup.sql .
```

## Monitoramento

### Health Checks

```bash
# Frontend
curl https://cantinhoverde.app.br

# Backend
curl https://api.cantinhoverde.app.br/api/health

# Traefik
curl https://traefik.cantinhoverde.app.br
```

### Logs

```bash
# Ansible remote
make prod-logs

# SSH direto
ssh ubuntu@IP_DA_EC2
docker compose -f /opt/hortti-inventory/docker-compose.yml logs -f --tail=100
```

## Próximos Passos

- [ ] Configurar backups automáticos (AWS Backup)
- [ ] Implementar monitoring (Prometheus + Grafana)
- [ ] Configurar alertas (CloudWatch Alarms)
- [ ] Implementar CI/CD completo (testes automatizados)
- [ ] Configurar CDN para assets estáticos
- [ ] Implementar rate limiting (Traefik middleware)
- [ ] Configurar WAF (Cloudflare)

## Recursos

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Cloudflare Terraform Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Ansible Documentation](https://docs.ansible.com/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

**Suporte:** Em caso de problemas, verifique os logs, consulte este guia e os recursos acima.
