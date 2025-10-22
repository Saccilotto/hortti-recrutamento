# 🚀 Acesso à Produção - Hortti Inventory

## URLs de Acesso

| Serviço | URL | Usuário | Senha |
|---------|-----|---------|-------|
| Frontend | [cantinhoverde.app.br](https://cantinhoverde.app.br) | - | - |
| Backend API | [api.cantinhoverde.app.br/api](https://api.cantinhoverde.app.br/api) | - | - |
| Traefik Dashboard | [traefik.cantinhoverde.app.br](https://traefik.cantinhoverde.app.br) | `admin` | `admin` |

---

## Funcionalidades por Serviço

### Frontend

- Página inicial de produtos
- Visualizar, criar, editar e deletar produtos
- Upload de imagens de produtos
- Login/Logout
- Dashboard de inventário

**Credenciais Padrão:**

- Admin: `admin@cantinhoverde.com` / `Admin@123`
- User: `user@cantinhoverde.com` / `User@123`

---

### Backend API

- REST API em `/api`
- Health check: `/api/health`
- Endpoints de autenticação, produtos e uploads

**Base URL:** `https://api.cantinhoverde.app.br/api`

---

### Traefik Dashboard

- Visualizar rotas configuradas
- Monitorar certificados SSL/TLS
- Ver status dos middlewares
- Gerenciar balanceamento de carga

**Credenciais:** `admin:admin`

---

## Segurança em Produção

### SSH na EC2

```bash
# Chave privada gerada pelo Terraform
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@18.189.34.219

# Ou via IP público (muda a cada deploy se usando Elastic IP)
terraform output -raw ec2_public_ip
```

### Variáveis de Ambiente

Todas armazenadas no arquivo `.env` em `/opt/hortti-inventory/` na EC2:

- Credenciais do banco de dados
- Secrets JWT
- Tokens Cloudflare
- Senhas do Traefik

### Certificados SSL

- Gerenciados pelo Let's Encrypt via Traefik
- Auto-renovação automática
- Armazenados em volume Docker

---

## Monitoramento

### Docker Compose

```bash
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@18.189.34.219

# Ver status dos containers
docker ps

# Ver logs
docker logs hortti-backend-prod
docker logs hortti-frontend-prod
docker logs hortti-traefik
docker logs hortti-db-prod

# Restart de um serviço
docker-compose -f /opt/hortti-inventory/docker-compose.yml restart hortti-backend-prod
```

### Healthchecks

- **Backend:** `curl https://api.cantinhoverde.app.br/api/health`
- **Frontend:** `curl https://cantinhoverde.app.br`
- **Database:** Verificado via healthcheck interno

---

## Deployment

### Fluxo CI/CD

1. Push para `main` branch
2. GitHub Actions: Build Docker images → Push para GHCR
3. Trigger automático do deploy workflow
4. Terraform: Provisiona/atualiza infraestrutura
5. Ansible: Deploy das aplicações

### Deploy Manual

```bash
# Via GitHub Actions:
# Settings > Actions > "Deploy to Production" > Run workflow
# Escolher: terraform_action (plan/apply/destroy) + deploy_app + image_tag
```

---

## Troubleshooting

### Backend container unhealthy

```bash
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@18.189.34.219
docker logs hortti-backend-prod --tail 100
```

### SSL Certificate issues

```bash
# Ver certificado
docker exec hortti-traefik cat /letsencrypt/acme.json

# Renovar manualmente (raro)
docker-compose restart traefik
```

### Database connection

```bash
# Testar conexão
docker exec hortti-db-prod psql -U hortti_admin -d hortti_inventory -c "SELECT 1"
```

---

## Notas

- Traefik dashboard usa autenticação HTTP Basic simples (`admin:admin`)
- Senhas geradas automaticamente pelo Terraform, armazenadas em SSM Parameter Store
- Backups do banco de dados: configure via AWS RDS ou scripts cron
- Logs centralizados: considerando CloudWatch ou ELK stack

---

**Última atualização:** 2025-10-22
**Mantido por:** GitHub Actions + Terraform + Ansible
