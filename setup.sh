#!/bin/bash

# Cria a estrutura de diretórios
mkdir -p meu_projeto/uploads meu_projeto/templates

# Cria o arquivo app.py
cat > meu_projeto/app.py <<EOL
from flask import Flask, render_template, request, send_file
import os

app = Flask(__name__)

# Pasta temporária para armazenar arquivos enviados
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        # Verifica se um arquivo foi enviado
        if 'file' not in request.files:
            return "Nenhum arquivo enviado!", 400

        file = request.files['file']

        # Verifica se o arquivo tem um nome
        if file.filename == '':
            return "Nome do arquivo inválido!", 400

        # Salva o arquivo enviado
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        file.save(file_path)

        # Processa o arquivo: une as linhas dentro de cada grupo
        with open(file_path, 'r', encoding='utf-8') as arquivo:
            conteudo = arquivo.read()

        # Divide o conteúdo em grupos (separados por linhas em branco)
        grupos = conteudo.split('\n\n')

        # Unir as linhas dentro de cada grupo
        grupos_unidos = [' '.join(grupo.splitlines()) for grupo in grupos]

        # Juntar os grupos novamente (mantendo a separação por linhas em branco)
        texto_unido = '\n\n'.join(grupos_unidos)

        # Salva o arquivo unido
        output_filename = 'arquivo_unido.txt'
        output_path = os.path.join(app.config['UPLOAD_FOLDER'], output_filename)
        with open(output_path, 'w', encoding='utf-8') as arquivo_saida:
            arquivo_saida.write(texto_unido)

        # Disponibiliza o arquivo unido para download
        return send_file(output_path, as_attachment=True)

    # Se for uma requisição GET, exibe o formulário de upload
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
EOL

# Cria o arquivo index.html
cat > meu_projeto/templates/index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Unir Linhas de Arquivo</title>
</head>
<body>
    <h1>Unir Linhas de Arquivo</h1>
    <form method="POST" enctype="multipart/form-data">
        <input type="file" name="file" accept=".txt" required>
        <button type="submit">Enviar e Unir Linhas</button>
    </form>
</body>
</html>
EOL

# Dá permissão de execução ao script
chmod +x meu_projeto/app.py

echo "Estrutura de arquivos criada com sucesso em 'meu_projeto'!"