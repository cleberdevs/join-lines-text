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
