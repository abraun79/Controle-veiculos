#!/bin/bash

# Atualizar o sistema
sudo apt update
sudo apt upgrade -y

# Instalar dependências básicas
sudo apt install -y apache2 php libapache2-mod-php php-mysql mysql-server unzip

# Iniciar e habilitar serviços
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl start mysql
sudo systemctl enable mysql

# Configurar MySQL
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test@12345';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Criar banco de dados e usuário
sudo mysql -u root -ptest@12345 -e "CREATE DATABASE controle_veiculos;"
sudo mysql -u root -ptest@12345 -e "CREATE USER 'teste'@'localhost' IDENTIFIED BY 'test@12345';"
sudo mysql -u root -ptest@12345 -e "GRANT ALL PRIVILEGES ON controle_veiculos.* TO 'teste'@'localhost';"
sudo mysql -u root -ptest@12345 -e "FLUSH PRIVILEGES;"

# Criar tabelas no banco de dados
sudo mysql -u root -ptest@12345 -D controle_veiculos -e "
CREATE TABLE motoristas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE veiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(255) NOT NULL
);

CREATE TABLE entradas_saidas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id INT NOT NULL,
    motorista_id INT NOT NULL,
    quilometragem_saida INT NOT NULL,
    data_hora_saida DATETIME NOT NULL,
    destino VARCHAR(255) NOT NULL,
    quilometragem_volta INT,
    data_hora_volta DATETIME,
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (motorista_id) REFERENCES motoristas(id)
);
"

# Definir permissões apropriadas
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Habilitar mod_rewrite
sudo a2enmod rewrite
sudo systemctl restart apache2

# Configurar diretório de veiculos
sudo mkdir -p /var/www/html/veiculos
sudo chown -R www-data:www-data /var/www/html/veiculos
sudo chmod -R 755 /var/www/html/veiculos

# Criar arquivo de configuração do Apache
cat <<EOT | sudo tee /etc/apache2/sites-available/veiculos.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/veiculos
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html/veiculos>
        AllowOverride All
    </Directory>
</VirtualHost>
EOT

# Ativar novo site e desativar o padrão
sudo a2dissite 000-default.conf
sudo a2ensite veiculos.conf
sudo systemctl reload apache2

# Criar arquivo index.php
cat <<EOT | sudo tee /var/www/html/veiculos/index.php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Controle de Saída e Retorno de Veículos</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Controle de Saída e Retorno de Veículos</h1>
        <?php
        if (\$_SERVER["REQUEST_METHOD"] == "POST") {
            \$host = 'localhost';
            \$db = 'controle_veiculos';
            \$user = 'teste';
            \$pass = 'test@12345';

            \$conn = new mysqli(\$host, \$user, \$pass, \$db);

            if (\$conn->connect_error) {
                die("Connection failed: " . \$conn->connect_error);
            }

            if (isset(\$_POST['registrar_saida'])) {
                \$placa = \$_POST['placa'];
                \$motorista = \$_POST['motorista'];
                \$quilometragem_saida = \$_POST['quilometragem_saida'];
                \$data_hora_saida = \$_POST['data_hora_saida'];
                \$destino = \$_POST['destino'];

                \$motorista_id_query = "SELECT id FROM motoristas WHERE nome='\$motorista'";
                \$motorista_id_result = \$conn->query(\$motorista_id_query);
                \$motorista_id_row = \$motorista_id_result->fetch_assoc();
                \$motorista_id = \$motorista_id_row['id'];

                \$veiculo_id_query = "SELECT id FROM veiculos WHERE placa='\$placa'";
                \$veiculo_id_result = \$conn->query(\$veiculo_id_query);
                \$veiculo_id_row = \$veiculo_id_result->fetch_assoc();
                \$veiculo_id = \$veiculo_id_row['id'];

                \$sql = "INSERT INTO entradas_saidas (veiculo_id, motorista_id, quilometragem_saida, data_hora_saida, destino) 
                        VALUES ('\$veiculo_id', '\$motorista_id', '\$quilometragem_saida', '\$data_hora_saida', '\$destino')";

                if (\$conn->query(\$sql) === TRUE) {
                    echo "<p class='success'>Registro de saída realizado com sucesso!</p>";
                } else {
                    echo "<p class='error'>Erro ao registrar saída: " . \$conn->error . "</p>";
                }
            } elseif (isset(\$_POST['registrar_volta'])) {
                \$placa = \$_POST['placa'];
                \$quilometragem_volta = \$_POST['quilometragem_volta'];
                \$data_hora_volta = \$_POST['data_hora_volta'];

                \$veiculo_id_query = "SELECT id FROM veiculos WHERE placa='\$placa'";
                \$veiculo_id_result = \$conn->query(\$veiculo_id_query);
                \$veiculo_id_row = \$veiculo_id_result->fetch_assoc();
                \$veiculo_id = \$veiculo_id_row['id'];

                \$sql = "UPDATE entradas_saidas 
                        SET quilometragem_volta='\$quilometragem_volta', data_hora_volta='\$data_hora_volta' 
                        WHERE veiculo_id='\$veiculo_id' AND quilometragem_volta IS NULL";

                if (\$conn->query(\$sql) === TRUE) {
                    echo "<p class='success'>Registro de volta realizado com sucesso!</p>";
                } else {
                    echo "<p class='error'>Erro ao registrar volta: " . \$conn->error . "</p>";
                }
            }

            \$conn->close();
        }
        ?>
        <h2>Registrar Saída</h2>
        <form id="registro-saida-form" action="" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <option value="APT-1021">Placa: APT-1021</option>
                <option value="APT-1022">Placa: APT-1022</option>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <option value="Motorista 01">Motorista 01</option>
                <option value="Motorista 02">Motorista 02</option>
        

            </select>

            <label for="quilometragem-saida">Quilometragem de Saída:</label>
            <input type="number" id="quilometragem-saida" name="quilometragem_saida" required>

            <label for="data-hora-saida">Data e Hora de Saída:</label>
            <input type="datetime-local" id="data-hora-saida" name="data_hora_saida" required>

            <label for="destino">Destino:</label>
            <input type="text" id="destino" name="destino" required>

            <input type="submit" name="registrar_saida" value="Registrar Saída">
        </form>

        <h2>Registrar Volta</h2>
        <form id="registro-volta-form" action="" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <option value="APT-1021">Placa: APT-1021</option>
                <option value="APT-1022">Placa: APT-1022</option>
            </select>

            <label for="quilometragem-volta">Quilometragem de Volta:</label>
            <input type="number" id="quilometragem-volta" name="quilometragem_volta" required>

            <label for="data-hora-volta">Data e Hora de Volta:</label>
            <input type="datetime-local" id="data-hora-volta" name="data_hora_volta" required>

            <input type="submit" name="registrar_volta" value="Registrar Volta">
        </form>
    </div>
    <script src="scripts.js"></script>
</body>
</html>
EOT

# Criar arquivo styles.css
cat <<EOT | sudo tee /var/www/html/veiculos/styles.css
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f4;
    margin: 0;
    padding: 0;
}

.container {
    width: 50%;
    margin: 50px auto;
    background-color: #fff;
    padding: 20px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
}

h1, h2 {
    color: #333;
}

form {
    margin-bottom: 20px;
}

label {
    display: block;
    margin-bottom: 5px;
    color: #666;
}

input[type="text"], input[type="number"], input[type="datetime-local"], select {
    width: calc(100% - 22px);
    padding: 10px;
    margin-bottom: 10px;
    border: 1px solid #ddd;
    border-radius: 5px;
}

input[type="submit"] {
    background-color: #5cb85c;
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    cursor: pointer;
}

input[type="submit"]:hover {
    background-color: #4cae4c;
}

.success {
    color: green;
}

.error {
    color: red;
}

table {
    width: 100%;
    border-collapse: collapse;
}

table, th, td {
    border: 1px solid #ddd;
}

th, td {
    padding: 10px;
    text-align: left;
}

th {
    background-color: #f4f4f4;
}
EOT

# Criar arquivo relatorio.php
cat <<EOT | sudo tee /var/www/html/veiculos/relatorio.php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório de Veículos</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Relatório de Saída e Retorno de Veículos</h1>
        <form action="" method="get">
            <label for="data_inicio">Data Início:</label>
            <input type="date" id="data_inicio" name="data_inicio" required>
            
            <label for="data_fim">Data Fim:</label>
            <input type="date" id="data_fim" name="data_fim" required>
            
            <input type="submit" value="Gerar Relatório">
        </form>

        <?php
        if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['data_inicio']) && isset($_GET['data_fim'])) {
            \$data_inicio = \$_GET['data_inicio'];
            \$data_fim = \$_GET['data_fim'];

            \$host = 'localhost';
            \$db = 'controle_veiculos';
            \$user = 'teste';
            \$pass = 'test@12345';

            \$conn = new mysqli(\$host, \$user, \$pass, \$db);

            if (\$conn->connect_error) {
                die("Connection failed: " . \$conn->connect_error);
            }

            \$sql = "SELECT v.placa, m.nome AS motorista, e.quilometragem_saida, e.data_hora_saida, e.destino,
                           e.quilometragem_volta, e.data_hora_volta
                    FROM entradas_saidas e
                    JOIN veiculos v ON e.veiculo_id = v.id
                    JOIN motoristas m ON e.motorista_id = m.id
                    WHERE e.data_hora_saida BETWEEN '\$data_inicio' AND '\$data_fim'";

            \$result = \$conn->query(\$sql);

            if (\$result->num_rows > 0) {
                echo "<table>
                        <tr>
                            <th>Placa</th>
                            <th>Motorista</th>
                            <th>Quilometragem de Saída</th>
                            <th>Data e Hora de Saída</th>
                            <th>Destino</th>
                            <th>Quilometragem de Volta</th>
                            <th>Data e Hora de Volta</th>
                        </tr>";
                while (\$row = \$result->fetch_assoc()) {
                    echo "<tr>
                            <td>{\$row['placa']}</td>
                            <td>{\$row['motorista']}</td>
                            <td>{\$row['quilometragem_saida']}</td>
                            <td>{\$row['data_hora_saida']}</td>
                            <td>{\$row['destino']}</td>
                            <td>{\$row['quilometragem_volta']}</td>
                            <td>{\$row['data_hora_volta']}</td>
                          </tr>";
                }
                echo "</table>";
            } else {
                echo "<p class='error'>Nenhum registro encontrado para o intervalo selecionado.</p>";
            }

            \$conn->close();
        }
        ?>
    </div>
    <script src="scripts.js"></script>
</body>
</html>
EOT

# Instalar dependências do projeto
echo "flask" > /var/www/html/veiculos/requirements.txt

# Finalização
echo "Configuração concluída! Acesse http://localhost/veiculos para visualizar o sistema."
