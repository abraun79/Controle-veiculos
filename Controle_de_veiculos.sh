#!/bin/bash

# Atualizar e instalar dependências
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php php-mysql mysql-server unzip curl php-cli php-mbstring

# Criar estrutura de diretórios e arquivos
sudo mkdir -p /var/www/html/veiculos

#Instalar o FPDF
cd /var/www/html/veiculos
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo tee /var/www/html/veiculos/composer.json << 'EOF'
{
    "require": {
        "setasign/fpdf": "^1.8"
    }
}
EOF
sudo composer install -y
cd ~/

# Configurar permissões
sudo chmod -R 775 /var/www/html/

# Configurar MySQL
sudo mysql -e "CREATE DATABASE controle_veiculos;"
sudo mysql -e "CREATE USER 'teste'@'localhost' IDENTIFIED BY 'test@12345';"
sudo mysql -e "GRANT ALL PRIVILEGES ON controle_veiculos.* TO 'teste'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Criar tabelas no MySQL
sudo mysql -u teste -p'test@12345' controle_veiculos << EOF
CREATE TABLE veiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'disponivel'
);

CREATE TABLE motoristas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE entradas_saidas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id INT NOT NULL,
    motorista_id INT NOT NULL,
    quilometragem_saida INT NOT NULL,
    data_hora_saida DATETIME NOT NULL,
    destino VARCHAR(100) NOT NULL,
    quilometragem_volta INT DEFAULT NULL,
    data_hora_volta DATETIME DEFAULT NULL,
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (motorista_id) REFERENCES motoristas(id)
);

INSERT INTO motoristas (nome) VALUES ('Alessandro'), ('Tiago'), ('Rodrigo'), ('Pinheiro');
INSERT INTO veiculos (placa, status) VALUES ('ATT-0944', 'disponivel'), ('AXZ-2472', 'disponivel');
EOF

# Configurar Apache
sudo sh -c 'echo "<VirtualHost *:80>
    DocumentRoot /var/www/html/veiculos
    <Directory /var/www/html/veiculos>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/veiculos.conf'

sudo a2ensite veiculos.conf
sudo a2dissite 000-default.conf

#Copiar os arquivos para o /var/www/html/veiculos
cd /Projetos
sudo cp *.php *.css /var/www/html/veiculos
cd ~/
#Dar permissões as pastas
sudo chown -R www-data:www-data /var/www/html/veiculos
sudo chmod -R 775 /var/www/html/veiculos
sudo chown -R www-data:www-data /var/www/html/veiculos/vendor
sudo chmod -R 775 /var/www/html/veiculos/vendor

sudo systemctl start apache2

echo "Instalação e configuração concluídas com sucesso."
