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

O script configurará automaticamente o ambiente e iniciará o servidor Apache. Se tudo correr conforme o esperado, você verá a mensagem "Instalação e configuração concluídas com sucesso.".

##Estrutura do Projeto
