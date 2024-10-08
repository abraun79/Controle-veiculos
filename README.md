<img height="20px"  src="https://i.imgur.com/1ubgfmC.png"><a href="README.md">  Leia em português!</a><br/>
<img height="20px"  src="https://i.imgur.com/UrpOBOr.png"><a href="README-us.md">  Read in English!</a>

# Sistema de Controle de Veículos

Este projeto é um sistema de controle de veículos desenvolvido em PHP e MySQL, configurado e instalado automaticamente através de um Shell Script. O script cuida de toda a instalação necessária, incluindo Apache, PHP, MySQL, e bibliotecas adicionais como o FPDF.

## Sumário

- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Configurações do Banco de Dados](#configurações-do-banco-de-dados)
- [Licença](#licença)

## Pré-requisitos

Antes de executar o script de instalação, certifique-se de que você atendeu aos seguintes requisitos:

- **Sistema Operacional**: Linux (testado no Ubuntu 20.04 e superiores)
- **Usuário com privilégios de sudo**
- **Conexão com a internet** (para instalação de pacotes)
- **Bash shell** (pode verificar executando `bash --version`)

## Instalação

1. Clone este repositório em sua máquina local:

    ```bash
    git clone https://github.com/abraun79/Controle-veiculos.git
    ```

2. Navegue até o diretório do projeto:

    ```bash
    cd Controle-veiculos
    ```

3. Dê permissão de execução ao script de instalação:

    ```bash
    chmod +x install.sh
    ```

4. Execute o script de instalação:

    ```bash
    sudo ./install.sh
    ```

O script realizará as seguintes tarefas:

- Atualizar os pacotes do sistema
- Instalar o Apache, PHP, MySQL e outras dependências
- Configurar o MySQL, incluindo a criação do banco de dados e das tabelas necessárias
- Instalar a biblioteca FPDF usando o Composer
- Configurar permissões e o servidor Apache

## Uso

Após a instalação, o sistema estará disponível em `http://localhost/`ou IP do servidor que a aplicação esteja instalada. Você pode acessar a interface web para gerenciar os veículos, motoristas e registros de entrada/saída.

### Exemplo de Execução

```bash
sudo ./install.sh
```

O script configurará automaticamente o ambiente e iniciará o servidor Apache. Se tudo correr conforme o esperado, você verá a mensagem "Instalação e configuração concluídas com sucesso.".

## Estrutura do Projeto
```
├── install.sh            # Script principal de instalação
├── README.md             # Documentação do projeto
├── config/               # Arquivos de configuração adicionais
├── scripts/              # Scripts auxiliares
├── /var/www/html/veiculos # Diretório principal da aplicação
└── composer.json         # Arquivo de configuração do Composer
```
- `install.sh:` Script principal que realiza a instalação e configuração.
- `/var/www/html/veiculos:` Diretório onde a aplicação web será instalada.
- `composer.json:` Arquivo que define as dependências PHP, como o FPDF.

## Configurações do Banco de Dados

O script de instalação cria o banco de dados e as tabelas necessárias automaticamente. As credenciais padrão são:

- `Banco de Dados:` controle_veiculos
- `Usuário:` teste (Usuário de sua preferência)
- `Senha:` test@12345 (Senha de sua Preferência)

 O banco de dados contém as seguintes tabelas:

- `veiculos:` Armazena informações dos veículos.
- `motoristas:` Armazena informações dos motoristas.
- `entradas_saidas:` Registra entradas e saídas de veículos.

## Contribuindo
Pull requests são bem vindos. Para grandes mudanças, ou bugs, por favor abra uma issue para discução.  
Para contato direto, me envie um e-mail: albraun79@outlook.com

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo LICENSE para mais detalhes.

```
MIT License

Copyright (c) 2024 Alessandro Braun

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
