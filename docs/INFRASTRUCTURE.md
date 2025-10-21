# Infraestrutura - Visão Geral

Documentação técnica da infraestrutura de produção do Hortti Inventory.

## Arquitetura Completa

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Repository                       │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Backend    │  │   Frontend   │  │  Terraform   │    │
│  │   (NestJS)   │  │  (Next.js)   │  │   + Ansible  │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
└───────────────┬─────────────────────────────┬──────────────┘
                │                             │
                ▼                             ▼
        ┌──────────────┐              ┌─────────────┐
        │GitHub Actions│              │AWS + CF API │
        │   (CI/CD)    │              │             │
        └──────┬───────┘              └──────┬──────┘
               │                             │
               ▼                             ▼
        ┌──────────────┐              ┌─────────────┐
        │     GHCR     │              │   AWS EC2   │
        │   (Images)   │              │  (t2.medium)│
        └──────┬───────┘              └──────┬──────┘
               │                             │
               │         ┌───────────────────┘
               │         │
               ▼         ▼
        ┌──────────────────────┐
        │  EC2 Instance        │
        │  (Ubuntu 22.04)      │
        │                      │
        │  ┌────────────────┐  │
        │  │    Traefik     │  │  ◄── Cloudflare DNS
        │  │  (SSL/Proxy)   │  │
        │  └────┬──────┬────┘  │
        │       │      │        │
        │  ┌────▼──┐ ┌▼─────┐  │
        │  │Frontend│ │Backend│ │
        │  │  :3000 │ │ :3001 │ │
        │  └────────┘ └───┬───┘ │
        │              ┌──▼───┐  │
        │              │ DB   │  │
        │              │:5432 │  │
        │              └──────┘  │
        └──────────────────────┘
```

## Componentes

### 1. Terraform (IaC)

**Responsabilidade:** Provisionar e gerenciar infraestrutura AWS e Cloudflare

**Recursos criados:**
- EC2 t2.medium (Ubuntu 22.04)
- Elastic IP fixo
- Security Group (portas 22, 80, 443)
- SSH Key Pair
- 3 DNS Records A (Cloudflare)
- Configurações SSL/TLS

**Estado:** Armazenado em S3 + lock no DynamoDB

**Arquivos principais:**
```
infra/terraform/
├── versions.tf          # Backend S3 + versões
├── providers.tf         # AWS + Cloudflare
├── variables.tf         # Inputs
├── outputs.tf           # IPs, URLs, comandos
├── ec2.tf              # EC2 + EIP
├── security_groups.tf  # Firewall
├── cloudflare.tf       # DNS + SSL
└── user-data.sh        # Inicialização da EC2
```

### 2. Ansible (Config Management)

**Responsabilidade:** Configurar servidor e fazer deploy da aplicação

**Tarefas executadas:**
1. Instalar Docker + Docker Compose
2. Configurar firewall (UFW)
3. Criar diretórios da aplicação
4. Copiar docker-compose.yml e .env
5. Login no GitHub Container Registry
6. Pull das imagens Docker
7. Iniciar aplicação com docker compose
8. Aguardar health checks

**Arquivos principais:**
```
infra/ansible/
├── ansible.cfg                      # Config do Ansible
├── playbook.yml                     # Playbook principal
├── inventory/hosts.ini              # Inventário de hosts
├── templates/
│   ├── docker-compose-prod.yml.j2  # Template do compose
│   └── env.prod.j2                 # Template do .env
└── vars/secrets.yml                # Secrets (criptografado)
```

### 3. GitHub Actions (CI/CD)

**Workflow 1: Build Images** (`build-images.yml`)
- **Trigger:** Push na main, PRs, tags
- **Ações:**
  1. Build das imagens Backend e Frontend
  2. Push para GitHub Container Registry (ghcr.io)
  3. Cache layers para builds rápidos

**Workflow 2: Deploy** (`deploy.yml`)
- **Trigger:** Manual (workflow_dispatch)
- **Opções:**
  - Terraform: plan/apply/destroy
  - Deploy app: true/false
  - Image tag: latest ou específica
- **Etapas:**
  1. Terraform (provisionar infraestrutura)
  2. Ansible (configurar + deploy)
  3. Verificação de health
  4. Notificação de status

### 4. Traefik (Reverse Proxy)

**Responsabilidades:**
- Reverse proxy para Backend e Frontend
- Terminação SSL/TLS
- Renovação automática de certificados
- Dashboard de monitoramento

**Características:**
- DNS Challenge (Cloudflare)
- Let's Encrypt (produção)
- HTTP → HTTPS redirect automático
- CORS headers configurados
- Security headers (HSTS)

**Rotas:**
```
https://cantinhoverde.app.br          → frontend:3000
https://api.cantinhoverde.app.br      → backend:3001
https://traefik.cantinhoverde.app.br  → traefik dashboard
```

### 5. Docker Compose (Produção)

**Serviços:**
1. **traefik** - Reverse proxy + SSL
2. **db** - PostgreSQL 15 Alpine
3. **backend** - NestJS (imagem do GHCR)
4. **frontend** - Next.js (imagem do GHCR)

**Volumes persistentes:**
- `postgres_data` - Dados do banco
- `backend_uploads` - Uploads de arquivos
- `traefik_letsencrypt` - Certificados SSL

**Networks:**
- `hortti-network` - Rede bridge interna

## Fluxo de Deploy

### Deploy Inicial (Setup)

```bash
# 1. Configurar AWS CLI
aws configure

# 2. Criar backend Terraform (S3)
make infra-setup-backend

# 3. Configurar variáveis
vim infra/terraform/terraform.tfvars
vim infra/ansible/vars/secrets.yml

# 4. Provisionar infraestrutura
make infra-plan
make infra-apply

# 5. Atualizar inventory Ansible
vim infra/ansible/inventory/hosts.ini  # Adicionar IP da EC2

# 6. Build e push imagens
export GITHUB_USER="seu-usuario"
export GITHUB_TOKEN="ghp_..."
make docker-build-push

# 7. Deploy da aplicação
make deploy
```

### Deploy de Atualizações

**Opção 1: Via Makefile (local)**
```bash
# Build + Push + Deploy
make prod-deploy

# OU apenas deploy (se já fez push)
make deploy
```

**Opção 2: Via GitHub Actions**
1. Push na branch `main` (build automático de imagens)
2. Actions → Deploy to Production → Run workflow
3. Terraform: `plan` (ou `apply` se mudar infra)
4. Deploy app: `true`
5. Image tag: `latest`

**Opção 3: SSH manual**
```bash
# SSH na EC2
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@IP_DA_EC2

cd /opt/hortti-inventory

# Pull novas imagens
docker compose pull

# Restart
docker compose up -d
```

## Segurança

### Camadas de Segurança

1. **Network (AWS Security Group)**
   - SSH: Apenas IPs permitidos
   - HTTP/HTTPS: Público
   - Stateful firewall

2. **OS (Ubuntu + UFW)**
   - Firewall ativo
   - Portas: 22, 80, 443
   - Updates automáticos

3. **Application (Docker)**
   - Containers isolados
   - Rede bridge privada
   - Volumes com permissões restritas

4. **SSL/TLS (Let's Encrypt)**
   - Certificados válidos
   - HTTPS obrigatório
   - HSTS headers

5. **Secrets Management**
   - Ansible Vault (local)
   - GitHub Secrets (CI/CD)
   - Environment variables (runtime)

### Secrets

**Nunca commitar:**
- `terraform.tfvars`
- `secrets.yml`
- Chaves SSH privadas
- Tokens de API
- Senhas

**Usar:**
- `.gitignore` configurado
- Ansible Vault para `secrets.yml`
- GitHub Secrets para CI/CD
- AWS Secrets Manager (opcional, para produção avançada)

## Monitoramento

### Health Checks

Todos os serviços têm health checks configurados:

```yaml
# Backend
healthcheck:
  test: wget --spider http://localhost:3001/api/health
  interval: 30s
  timeout: 10s
  retries: 3

# Frontend
healthcheck:
  test: wget --spider http://localhost:3000
  interval: 30s
  timeout: 10s
  retries: 3
```

### Logs

**Via Makefile:**
```bash
make prod-logs          # Logs em tempo real
make prod-status        # Status dos containers
```

**Via SSH:**
```bash
ssh ubuntu@IP_DA_EC2
cd /opt/hortti-inventory
docker compose logs -f --tail=100
```

**Traefik Dashboard:**
- URL: https://traefik.cantinhoverde.app.br
- Auth: Basic Auth (htpasswd)
- Mostra: rotas, backends, certificados, health

### Métricas

**Recursos da EC2:**
```bash
# SSH na EC2
htop                    # CPU/RAM
df -h                   # Disco
docker stats            # Por container
```

**CloudWatch (AWS):**
- CPU Utilization
- Network In/Out
- Disk Read/Write
- Status Check Failed

## Backup e Recuperação

### Backup Manual

```bash
# SSH na EC2
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@IP_DA_EC2

# Backup do banco
cd /opt/hortti-inventory
docker compose exec db pg_dump -U hortti_admin hortti_inventory \
  > backup-$(date +%Y%m%d-%H%M%S).sql

# Backup dos uploads
tar -czf uploads-$(date +%Y%m%d).tar.gz uploads/

# Download local
scp -i ~/.ssh/hortti-prod-key.pem \
  ubuntu@IP_DA_EC2:/opt/hortti-inventory/backup-*.sql \
  ./backups/
```

### Backup Automático (Recomendado)

**Opção 1: Cron na EC2**
```bash
# Adicionar ao crontab
0 2 * * * cd /opt/hortti-inventory && docker compose exec -T db \
  pg_dump -U hortti_admin hortti_inventory > backup-$(date +\%Y\%m\%d).sql
```

**Opção 2: AWS Backup**
- Configurar snapshots do EBS
- Retenção de 7 dias
- Custo: ~$0.05/GB/mês

### Recuperação

```bash
# Restaurar banco
docker compose exec -T db psql -U hortti_admin hortti_inventory < backup.sql

# Restaurar uploads
tar -xzf uploads-backup.tar.gz -C /opt/hortti-inventory/
```

## Custos

### AWS (us-east-2)

| Recurso | Especificação | Custo/mês |
|---------|---------------|-----------|
| EC2 t2.medium | 2 vCPU, 4GB RAM | $33.87 |
| EBS gp3 | 30GB SSD | $2.40 |
| EIP | IP elástico (associado) | $0.00 |
| Data Transfer | Primeiros 100GB | $0.00 |
| S3 | State do Terraform (~1MB) | $0.02 |
| DynamoDB | Locks (5 R/W) | $0.65 |
| **TOTAL** | | **~$36.94/mês** |

### Cloudflare

- DNS: **Grátis** (plano Free)
- SSL: **Grátis** (Universal SSL)
- CDN: **Grátis** (100GB/mês)

### Otimizações de Custo

**Reduzir custos:**
- Use t2.micro ($8.47/mês) para staging
- Pare a instância quando não usar (stop/start)
- Use Reserved Instances (-30% a -60%)
- Configure Auto Scaling (escala para zero)

**Aumentar custos (melhor performance):**
- Upgrade para t3.medium ($30.74/mês)
- Adicionar Application Load Balancer (+$16/mês)
- Adicionar RDS para banco (+$15/mês)
- Adicionar ElastiCache (+$13/mês)

## Troubleshooting Rápido

### Aplicação não responde

```bash
# 1. Verificar containers
make prod-status

# 2. Ver logs
make prod-logs

# 3. SSH e debug
ssh ubuntu@IP_DA_EC2
cd /opt/hortti-inventory
docker compose ps
docker compose logs backend
docker compose logs frontend

# 4. Restart
docker compose restart
```

### SSL não funciona

```bash
# Verificar DNS
dig cantinhoverde.app.br
dig api.cantinhoverde.app.br

# Ver logs do Traefik
docker compose logs traefik | grep acme

# Forçar renovação (se expirado)
docker compose restart traefik
```

### Terraform state locked

```bash
cd infra/terraform
terraform force-unlock LOCK_ID

# Ver locks ativos
aws dynamodb scan --table-name hortti-terraform-locks
```

### Ansible não conecta

```bash
# Testar SSH
ssh -vvv -i ~/.ssh/hortti-prod-key.pem ubuntu@IP_DA_EC2

# Verificar security group
aws ec2 describe-security-groups --region us-east-2

# Verificar permissões da chave
chmod 600 ~/.ssh/hortti-prod-key.pem
```

## Próximas Melhorias

### Curto Prazo

- [ ] Configurar backups automáticos
- [ ] Implementar rate limiting (Traefik)
- [ ] Adicionar logs centralizados (ELK/Loki)
- [ ] Configurar alertas (CloudWatch Alarms)

### Médio Prazo

- [ ] Migrar banco para RDS
- [ ] Adicionar Redis/ElastiCache
- [ ] Implementar Blue/Green deployment
- [ ] Configurar CDN para assets estáticos

### Longo Prazo

- [ ] Migrar para Kubernetes (EKS)
- [ ] Implementar service mesh (Istio)
- [ ] Adicionar observability (Prometheus + Grafana)
- [ ] Multi-region deployment

## Recursos Adicionais

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Cloudflare Terraform](https://registry.terraform.io/providers/cloudflare/cloudflare/latest)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

---

**Documentação relacionada:**
- [Guia de Deploy](DEPLOYMENT.md)
- [GitHub Secrets](SECRETS.md)
- [Endpoints API](ENDPOINTS.md)
