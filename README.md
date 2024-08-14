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
- install.sh: Script principal que realiza a instalação e configuração.
- /var/www/html/veiculos: Diretório onde a aplicação web será instalada.
- composer.json: Arquivo que define as dependências PHP, como o FPDF.

## Configurações do Banco de Dados

O script de instalação cria o banco de dados e as tabelas necessárias automaticamente. As credenciais padrão são:

- Banco de Dados: controle_veiculos
- Usuário: teste (Usuário de sua preferência)
- Senha: test@12345 (Senha de sua Preferência)

 O banco de dados contém as seguintes tabelas:

- veiculos: Armazena informações dos veículos.
- motoristas: Armazena informações dos motoristas.
- entradas_saidas: Registra entradas e saídas de veículos.

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo LICENSE para mais detalhes.

```
Este README fornece uma documentação completa e detalhada sobre o projeto, garantindo que qualquer pessoa que deseje usar ou contribuir com o projeto tenha todas as informações necessárias. Certifique-se de personalizar o link do repositório GitHub e outros detalhes conforme necessário.
```
