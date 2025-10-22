# GitHub Secrets Configuration

Este arquivo documenta todos os secrets necessários para o GitHub Actions funcionar corretamente.

## Como Configurar

1. Vá em **Settings** → **Secrets and variables** → **Actions**
2. Clique em **New repository secret**
3. Adicione cada secret abaixo com seu respectivo valor

## Secrets Necessários

### AWS Credentials

```text
Name: AWS_ACCESS_KEY_ID
Description: AWS Access Key ID com permissões para EC2, VPC, S3, DynamoDB
Value: AKIA...
```

```text
Name: AWS_SECRET_ACCESS_KEY
Description: AWS Secret Access Key
Value: <secret>
```

### SSH Configuration

```text
Name: SSH_PUBLIC_KEY
Description: Chave pública SSH (conteúdo de ~/.ssh/hortti-prod-key.pub)
Value: ssh-rsa AAAAB3NzaC1yc2E...
```

```text
Name: SSH_PRIVATE_KEY
Description: Chave privada SSH (conteúdo de ~/.ssh/hortti-prod-key.pem)
Value: -----BEGIN RSA PRIVATE KEY-----
       MIIEpAIBAAKCAQEA...
       -----END RSA PRIVATE KEY-----
```

```text
Name: ALLOWED_SSH_CIDR
Description: CIDR do IP permitido para SSH (ex: 203.0.113.0/32)
Value: SEU.IP.AQUI/32
```

**Como obter seu IP:**

```bash
curl ifconfig.me
# Adicione /32 no final
```

```text
Name: SSH_PRIVATE_KEY
Description: Chave privada SSH (conteúdo de ~/.ssh/hortti-prod-key.pem)
Value: -----BEGIN RSA PRIVATE KEY-----
       MIIEpAIBAAKCAQEA...
       -----END RSA PRIVATE KEY-----
```

```text
Name: ALLOWED_SSH_CIDR
Description: CIDR do IP permitido para SSH (ex: 203.0.113.0/32)
Value: SEU.IP.AQUI/32
```

### Cloudflare

```text
Name: CLOUDFLARE_API_TOKEN
Description: Token da Cloudflare com permissões Edit DNS
Value: <token>
```

**Como gerar:**

1. Acesse <https://dash.cloudflare.com/profile/api-tokens>
2. Create Token → Edit zone DNS
3. Zone Resources: Include → Specific zone → cantinhoverde.app.br
4. Continue to summary → Create Token

```text
Name: CLOUDFLARE_ZONE_ID
Description: Zone ID do domínio cantinhoverde.app.br
Value: <zone_id>
```

**Como encontrar:**

1. Dashboard Cloudflare → cantinhoverde.app.br
2. Sidebar direita → API → Zone ID

```text
Name: CLOUDFLARE_DNS_TOKEN
Description: Token para DNS Challenge (pode ser o mesmo do CLOUDFLARE_API_TOKEN)
Value: <token>
```

```text
Name: CLOUDFLARE_ZONE_TOKEN
Description: Token para Zone API (pode ser o mesmo do CLOUDFLARE_API_TOKEN)
Value: <token>
```

### Database

```text
Name: POSTGRES_USER
Description: Usuário do PostgreSQL em produção
Value: hortti_admin
```

```text
Name: POSTGRES_PASSWORD
Description: Senha do PostgreSQL (gerada com: openssl rand -base64 32)
Value: <senha_segura>
```

```text
Name: POSTGRES_DB
Description: Nome do banco de dados
Value: hortti_inventory
```

### JWT Authentication

```text
Name: JWT_SECRET
Description: Secret para JWT tokens (gerar com: openssl rand -base64 32)
Value: <secret_aleatorio_32_chars>
```

```text
Name: JWT_REFRESH_SECRET
Description: Secret para refresh tokens (gerar com: openssl rand -base64 32)
Value: <outro_secret_aleatorio_32_chars>
```

### Email Configuration

```text
Name: ACME_EMAIL
Description: Email para notificações do Let's Encrypt
Value: seu-email@exemplo.com
```

### Traefik Dashboard

```text
Name: TRAEFIK_DASHBOARD_AUTH
Description: Usuário:senha hash para Traefik dashboard (htpasswd format)
Value: admin:$apr1$xyz...
```

**Como gerar:**

```bash
# Instalar htpasswd (Apache utils)
sudo apt-get install apache2-utils  # Ubuntu/Debian
brew install httpd                   # macOS

# Gerar hash
htpasswd -nb admin SuaSenhaForte
# Output: admin:$apr1$xyz...
```

### API URL (Build Time)

```text
Name: NEXT_PUBLIC_API_URL
Description: URL da API para o frontend (build time)
Value: https://api.cantinhoverde.app.br/api
```

## Validação dos Secrets

### Checklist

Após adicionar todos os secrets, verifique:

- [ ] Total de 16 secrets configurados
- [ ] SSH_PRIVATE_KEY contém BEGIN/END RSA PRIVATE KEY
- [ ] SSH_PUBLIC_KEY começa com ssh-rsa
- [ ] ALLOWED_SSH_CIDR termina com /32
- [ ] CLOUDFLARE_ZONE_ID tem 32 caracteres hexadecimais
- [ ] JWT_SECRET e JWT_REFRESH_SECRET são diferentes
- [ ] POSTGRES_PASSWORD tem pelo menos 32 caracteres
- [ ] TRAEFIK_DASHBOARD_AUTH contém : e começa com admin:$

### Teste de Secrets

Você pode testar se os secrets estão corretos rodando o workflow:

1. Actions → Deploy to Production
2. Run workflow
3. Terraform action: `plan`
4. Deploy app: `false`

Se o Terraform plan funcionar, seus secrets de AWS e Cloudflare estão corretos.

## Segurança

### Boas Práticas

- ✅ Nunca commite secrets no código
- ✅ Use secrets diferentes para dev/prod
- ✅ Rotacione secrets regularmente (a cada 90 dias)
- ✅ Use princípio do menor privilégio (permissões mínimas)
- ✅ Monitore uso de secrets (CloudTrail, GitHub audit log)
- ✅ Revogue secrets comprometidos imediatamente

### Rotação de Secrets

**AWS:**

```bash
# Criar novo Access Key
aws iam create-access-key --user-name seu-usuario

# Atualizar secrets no GitHub
# Deletar chave antiga
aws iam delete-access-key --access-key-id VELHA_KEY --user-name seu-usuario
```

**Cloudflare:**

```bash
# Revogar token antigo no dashboard
# Gerar novo token
# Atualizar secrets no GitHub
```

**PostgreSQL:**

```bash
# SSH na EC2
ssh -i ~/.ssh/hortti-prod-key.pem ubuntu@IP_DA_EC2

# Alterar senha
docker compose exec db psql -U hortti_admin
ALTER USER hortti_admin WITH PASSWORD 'nova_senha_segura';

# Atualizar secret no GitHub
# Redeployar aplicação
```

### Auditoria

```bash
# Ver quando secrets foram atualizados
# GitHub → Settings → Secrets → Histórico de cada secret

# Verificar uso em workflows
# GitHub → Actions → Select workflow run → View logs
```

## Troubleshooting

### Secret não está sendo reconhecido

**Sintoma:** Workflow falha com "secret not found"

**Soluções:**

1. Verifique o nome exato (case-sensitive)
2. Verifique se está em Actions secrets (não Environment)
3. Aguarde alguns segundos após adicionar

### Secret com formato incorreto

**SSH_PRIVATE_KEY:**

- Deve começar com `-----BEGIN RSA PRIVATE KEY-----`
- Deve terminar com `-----END RSA PRIVATE KEY-----`
- Incluir as linhas BEGIN/END
- Sem espaços ou tabs extras

**TRAEFIK_DASHBOARD_AUTH:**

- Formato: `usuario:$apr1$hash...`
- Não usar aspas

**ALLOWED_SSH_CIDR:**

- Formato: `IP/32`
- Exemplo: `203.0.113.42/32`
- Não usar apenas o IP sem /32

### Terraform falha com credenciais AWS

```bash
# Verificar localmente se credenciais funcionam
aws sts get-caller-identity

# Verificar permissões
aws iam get-user
```

## Secrets Opcionais

Estes secrets são opcionais mas recomendados para produção:

```text
Name: SLACK_WEBHOOK_URL
Description: Webhook do Slack para notificações
Value: https://hooks.slack.com/services/...
```

```text
Name: SENTRY_DSN
Description: DSN do Sentry para error tracking
Value: https://...@sentry.io/...
```

```text
Name: DATADOG_API_KEY
Description: API key do Datadog para monitoring
Value: <api_key>
```

## Template de Checklist

Use este template ao configurar um novo repositório:

```text
Secrets Configuration Checklist

AWS:
[ ] AWS_ACCESS_KEY_ID
[ ] AWS_SECRET_ACCESS_KEY

SSH:
[ ] SSH_PUBLIC_KEY
[ ] SSH_PRIVATE_KEY
[ ] ALLOWED_SSH_CIDR

Cloudflare:
[ ] CLOUDFLARE_API_TOKEN
[ ] CLOUDFLARE_ZONE_ID
[ ] CLOUDFLARE_DNS_TOKEN
[ ] CLOUDFLARE_ZONE_TOKEN

Database:
[ ] POSTGRES_USER
[ ] POSTGRES_PASSWORD
[ ] POSTGRES_DB

JWT:
[ ] JWT_SECRET
[ ] JWT_REFRESH_SECRET

Outros:
[ ] ACME_EMAIL
[ ] TRAEFIK_DASHBOARD_AUTH
[ ] NEXT_PUBLIC_API_URL

Total: 16 secrets obrigatórios
```

---

**Última atualização:** 2025-10-21
