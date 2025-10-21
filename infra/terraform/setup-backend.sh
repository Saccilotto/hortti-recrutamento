#!/bin/bash
# ============================================
# Setup Terraform S3 Backend
# ============================================
# Este script cria o bucket S3 e tabela DynamoDB
# para armazenar o state do Terraform
# ============================================

set -e

# Configurações
BUCKET_NAME="hortti-terraform-state"
DYNAMODB_TABLE="hortti-terraform-locks"
AWS_REGION="us-east-2"

echo "🚀 Configurando backend do Terraform..."
echo ""

# Verificar se AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI não encontrado. Instale com:"
    echo "   curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'"
    echo "   unzip awscliv2.zip"
    echo "   sudo ./aws/install"
    exit 1
fi

# Verificar credenciais AWS
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Credenciais AWS não configuradas."
    echo "   Execute: aws configure"
    exit 1
fi

echo "✅ AWS CLI configurado"
echo ""

# Criar bucket S3
echo "📦 Criando bucket S3: $BUCKET_NAME"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "⚠️  Bucket já existe"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION"

    # Habilitar versionamento
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled

    # Habilitar criptografia
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'

    # Bloquear acesso público
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    echo "✅ Bucket criado com sucesso"
fi

echo ""

# Criar tabela DynamoDB
echo "🔐 Criando tabela DynamoDB: $DYNAMODB_TABLE"
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" &>/dev/null; then
    echo "⚠️  Tabela já existe"
else
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$AWS_REGION"

    echo "✅ Tabela criada com sucesso"
fi

echo ""
echo "✅ Backend do Terraform configurado com sucesso!"
echo ""
echo "📋 Próximos passos:"
echo "   1. Configure terraform.tfvars com suas variáveis"
echo "   2. Execute: terraform init"
echo "   3. Execute: terraform plan"
echo "   4. Execute: terraform apply"
