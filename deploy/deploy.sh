#!/usr/bin/env bash


# Verificar se o nome da função Lambda foi fornecido como argumento
if [ -z "$1" ]; then
  echo "Erro: Você deve fornecer o nome da função Lambda como argumento!"
  echo "Uso: ./deploy.sh <NomeDaFuncaoLambda>"
  exit 1
fi

# Nome da função Lambda
LAMBDA_FUNCTION_NAME="$1"

echo "📦  Gerando arquivo .jar do projeto ..."
cd ../
mvn clean package &> /dev/null
cd deploy

# Caminho para o arquivo .jar gerado
JAR_FILE_PATH=$(find "../target" -name "*.jar" ! -name "original-*.jar")

# Verificar se o arquivo .jar foi criado
if [ ! -f "$JAR_FILE_PATH" ]; then
  echo "❌ Erro: Arquivo .jar não encontrado!"
  exit 1
fi

echo "🔄  Atualizando código da função Lambda ..."
aws lambda update-function-code \
  --function-name $LAMBDA_FUNCTION_NAME \
  --zip-file fileb://$JAR_FILE_PATH &> /dev/null

# Verificar se a atualização foi bem-sucedida
if [ $? -eq 0 ]; then

  echo -e "✅  Upload do código da função Lambda realizado com sucesso.\n"

  # Obter informações da função Lambda
  FUNCTION_INFO=$(aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME)

  # Extrair a data e hora da última modificação usando o comando jq
  LAST_MODIFIED=$(echo "$FUNCTION_INFO" | grep -o '"LastModified": "[^"]*' | grep -o '[^"]*$')

  # Exibir o nome da função e a data/hora da última modificação
  echo "Função Lambda atualizada: $LAMBDA_FUNCTION_NAME"
  echo "Última modificação: $LAST_MODIFIED"
else
  echo "❌ Erro: Falha ao atualizar a função Lambda!"
  exit 1
fi
