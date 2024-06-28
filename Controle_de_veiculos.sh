#!/bin/bash

# Atualizar sistema e instalar dependências
sudo apt update
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql

# Iniciar e habilitar Apache e MySQL
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl start mysql
sudo systemctl enable mysql

# Configurar MySQL
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test@12345';
FLUSH PRIVILEGES;
CREATE DATABASE controle_veiculos;
CREATE USER 'teste'@'localhost' IDENTIFIED BY 'test@12345';
GRANT ALL PRIVILEGES ON controle_veiculos.* TO 'teste'@'localhost';
FLUSH PRIVILEGES;
USE controle_veiculos;
CREATE TABLE veiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL
);
CREATE TABLE motoristas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);
CREATE TABLE entradas_saidas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id INT NOT NULL,
    motorista_id INT NOT NULL,
    quilometragem_saida INT,
    data_hora_saida DATETIME,
    destino VARCHAR(255),
    quilometragem_volta INT,
    data_hora_volta DATETIME,
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (motorista_id) REFERENCES motoristas(id)
);
INSERT INTO veiculos (placa) VALUES ('APT-1010'), ('APT-1011');
INSERT INTO motoristas (nome) VALUES ('MOTORISTA01'), ('MOTORISTA02');
EOF

# Configurar Apache
sudo tee /etc/apache2/sites-available/veiculos.conf > /dev/null <<EOT
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/veiculos
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOT

sudo a2ensite veiculos
sudo a2dissite 000-default
sudo systemctl reload apache2

# Criar diretório do projeto
sudo mkdir -p /var/www/html/veiculos

# Criar arquivo index.php
cat <<EOT | sudo tee /var/www/html/veiculos/index.php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Controle de Saída de Veículos</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Controle de Saída de Veículos</h1>
        <form id="registro-saida-form" action="registra_saida.php" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <option value="APT-1010">Placa: APT-1010</option>
                <option value="APT-1011">Placa: APT-1011</option>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <option value="MOTORISTA01">MOTORISTA01</option>
                <option value="MOTORISTA02">MOTORISTA02</option>
            </select>

            <label for="quilometragem-saida">Quilometragem de Saída:</label>
            <input type="number" id="quilometragem-saida" name="quilometragem_saida" required>

            <label for="destino">Destino:</label>
            <input type="text" id="destino" name="destino" required>

            <label for="data-hora-saida">Data e Hora de Saída:</label>
            <input type="datetime-local" id="data-hora-saida" name="data_hora_saida" required>

            <input type="submit" value="Registrar Saída">
        </form>
        <form action="registra_volta.html" method="get">
            <input type="submit" value="Registrar Retorno">
        </form>
        <form action="relatorio.php" method="get">
            <input type="submit" value="Gerar Relatório">
        </form>
    </div>
    <script src="scripts.js"></script>
</body>
</html>
EOT

# Criar arquivo registra_saida.php
cat <<EOT | sudo tee /var/www/html/veiculos/registra_saida.php
<?php
\$host = 'localhost';
\$db = 'controle_veiculos';
\$user = 'teste';
\$pass = 'test@12345';

\$conn = new mysqli(\$host, \$user, \$pass, \$db);

if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

\$placa = \$_POST['placa'];
\$motorista = \$_POST['motorista'];
\$quilometragem_saida = \$_POST['quilometragem_saida'];
\$destino = \$_POST['destino'];
\$data_hora_saida = \$_POST['data_hora_saida'];

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
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => \$conn->error]);
}

\$conn->close();
?>
EOT

# Criar arquivo registra_volta.html
cat <<EOT | sudo tee /var/www/html/veiculos/registra_volta.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Volta de Veículo</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Registrar Volta de Veículo</h1>
        <form id="registro-volta-form" action="registra_volta.php" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <option value="APT-1010">Placa: APT-1010</option>
                <option value="APT-1011">Placa: APT-1011</option>
            </select>

            <label for="quilometragem-volta">Quilometragem de Volta:</label>
            <input type="number" id="quilometragem-volta" name="quilometragem_volta" required>

            <label for="data-hora-volta">Data e Hora de Volta:</label>
            <input type="datetime-local" id="data-hora-volta" name="data_hora_volta" required>

            <input type="submit" value="Registrar Volta">
        </form>
        <form action="index.html" method="get">
            <input type="submit" value="Voltar ao inicio">
        </form>
    </div>
</body>
</html>
EOT

# Criar arquivo registra_volta.php
cat <<EOT | sudo tee /var/www/html/veiculos/registra_volta.php
<?php
\$host = 'localhost';
\$db = 'controle_veiculos';
\$user = 'teste';
\$pass = 'test@12345';

\$conn = new mysqli(\$host, \$user, \$pass, \$db);

if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

\$placa = \$_POST['placa'];
\$quilometragem_volta = \$_POST['quilometragem_volta'];
\$data_hora_volta = \$_POST['data_hora_volta'];

\$veiculo_id_query = "SELECT id FROM veiculos WHERE placa='\$placa'";
\$veiculo_id_result = \$conn->query(\$veiculo_id_query);
\$veiculo_id_row = \$veiculo_id_result->fetch_assoc();
\$veiculo_id = \$veiculo_id_row['id'];

\$sql = "UPDATE entradas_saidas SET quilometragem_volta='\$quilometragem_volta', data_hora_volta='\$data_hora_volta' 
        WHERE veiculo_id='\$veiculo_id' AND quilometragem_volta IS NULL";

if (\$conn->query(\$sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => \$conn->error]);
}

\$conn->close();
?>
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
        <h1>Relatório de Veículos</h1>
        <form action="relatorio.php" method="get">
            <label for="data_inicio">Data Início:</label>
            <input type="datetime-local" id="data_inicio" name="data_inicio" required>

            <label for="data_fim">Data Fim:</label>
            <input type="datetime-local" id="data_fim" name="data_fim" required>

            <input type="submit" value="Gerar Relatório">
        </form>
        <?php
        if (isset(\$_GET['data_inicio']) && isset(\$_GET['data_fim'])) {
            \$host = 'localhost';
            \$db = 'controle_veiculos';
            \$user = 'teste';
            \$pass = 'test@12345';

            \$conn = new mysqli(\$host, \$user, \$pass, \$db);

            if (\$conn->connect_error) {
                die("Connection failed: " . \$conn->connect_error);
            }

            \$data_inicio = \$_GET['data_inicio'];
            \$data_fim = \$_GET['data_fim'];

            \$sql = "SELECT v.placa, m.nome, e.quilometragem_saida, e.data_hora_saida, e.destino, e.quilometragem_volta, e.data_hora_volta
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
                            <th>Quilometragem Saída</th>
                            <th>Data Hora Saída</th>
                            <th>Destino</th>
                            <th>Quilometragem Volta</th>
                            <th>Data Hora Volta</th>
                        </tr>";
                while (\$row = \$result->fetch_assoc()) {
                    echo "<tr>
                            <td>" . \$row['placa'] . "</td>
                            <td>" . \$row['nome'] . "</td>
                            <td>" . \$row['quilometragem_saida'] . "</td>
                            <td>" . \$row['data_hora_saida'] . "</td>
                            <td>" . \$row['destino'] . "</td>
                            <td>" . \$row['quilometragem_volta'] . "</td>
                            <td>" . \$row['data_hora_volta'] . "</td>
                        </tr>";
                }
                echo "</table>";

                echo "<form action='download_relatorio.php' method='post'>
                        <input type='hidden' name='data_inicio' value='\$data_inicio'>
                        <input type='hidden' name='data_fim' value='\$data_fim'>
                        <input type='submit' value='Baixar Relatório'>
                      </form>
                      <form action="index.html" method="get">
                        <input type="submit" value="Voltar ao inicio">
                     </form>";

            } else {
                echo "<p>Nenhum registro encontrado para o período selecionado.</p>";
            }

            \$conn->close();
        }
        ?>
    </div>
</body>
</html>
EOT

# Criar arquivo download_relatorio.php
cat <<EOT | sudo tee /var/www/html/veiculos/download_relatorio.php
<?php
if (\$_SERVER["REQUEST_METHOD"] == "POST" && isset(\$_POST['data_inicio']) && isset(\$_POST['data_fim'])) {
    \$host = 'localhost';
    \$db = 'controle_veiculos';
    \$user = 'teste';
    \$pass = 'test@12345';

    \$conn = new mysqli(\$host, \$user, \$pass, \$db);

    if (\$conn->connect_error) {
        die("Connection failed: " . \$conn->connect_error);
    }

    \$data_inicio = \$_POST['data_inicio'];
    \$data_fim = \$_POST['data_fim'];

    \$sql = "SELECT v.placa, m.nome, e.quilometragem_saida, e.data_hora_saida, e.destino, e.quilometragem_volta, e.data_hora_volta
            FROM entradas_saidas e
            JOIN veiculos v ON e.veiculo_id = v.id
            JOIN motoristas m ON e.motorista_id = m.id
            WHERE e.data_hora_saida BETWEEN '\$data_inicio' AND '\$data_fim'";

    \$result = \$conn->query(\$sql);

    if (\$result->num_rows > 0) {
        \$file_content = "Placa\\tMotorista\\tQuilometragem Saída\\tData Hora Saída\\tDestino\\tQuilometragem Volta\\tData Hora Volta\\n";
        while (\$row = \$result->fetch_assoc()) {
            \$file_content .= \$row['placa'] . "\\t" . \$row['nome'] . "\\t" . \$row['quilometragem_saida'] . "\\t" . \$row['data_hora_saida'] . "\\t" . \$row['destino'] . "\\t" . \$row['quilometragem_volta'] . "\\t" . \$row['data_hora_volta'] . "\\n";
        }

        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="relatorio.txt"');
        header('Content-Length: ' . strlen(\$file_content));
        echo \$file_content;
    } else {
        echo "<p>Nenhum registro encontrado para o período selecionado.</p>";
    }

    \$conn->close();
}
?>
EOT

# Criar arquivo styles.css
cat <<EOT | sudo tee /var/www/html/veiculos/styles.css
body {
    font-family: Arial, sans-serif;
}
.container {
    width: 50%;
    margin: auto;
    padding: 20px;
    border: 1px solid #ccc;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
}
h1 {
    text-align: center;
}
form {
    display: flex;
    flex-direction: column;
}
label {
    margin-top: 10px;
}
input, select {
    margin-bottom: 10px;
    padding: 10px;
    font-size: 16px;
}
input[type="submit"] {
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}
input[type="submit"]:hover {
    background-color: #45a049;
}
table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
}
th, td {
    padding: 10px;
    border: 1px solid #ddd;
    text-align: left;
}
th {
    background-color: #f2f2f2;
}
EOT

# Configuração final
sudo chown -R www-data:www-data /var/www/html/veiculos
sudo chmod -R 755 /var/www/html/veiculos

echo "Instalação e configuração concluídas. Acesse http://localhost/veiculos para utilizar o sistema."


