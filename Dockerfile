# Usar uma imagem base do Python
FROM python:3.10-slim

# Definir o diretório de trabalho dentro do container
WORKDIR /app

# Copiar o arquivo requirements.txt e instalar dependências
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copiar o código do app para o container
COPY . .

# Expor a porta que o Flask vai rodar
EXPOSE 8080

# Comando para rodar o app Flask
CMD ["python", "app.py"]
