#!/bin/bash

# Atualizar e instalar dependências
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php php-mysql mysql-server unzip curl php-cli php-mbstring

# Criar estrutura de diretórios e arquivos
sudo mkdir -p /var/www/html/veiculos

#Instalar o FPDF
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo tee /var/www/html/veiculos/composer.json << 'EOF'
{
    "require": {
        "setasign/fpdf": "^1.8"
    }
}
EOF
cd /var/www/html/veiculos
composer install
cd ~/

# Configurar permissões
sudo chmod -R 755 /var/www/html/

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

INSERT INTO motoristas (nome) VALUES ('MOTORISTA01'), ('MOTORISTA02'), ('MOTORISTA03'), ('MOTORISTA04');
INSERT INTO veiculos (placa, status) VALUES ('APT-1010', 'disponivel'), ('APT-1011', 'disponivel'), ('ZTX-3245', 'disponivel');
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
sudo systemctl restart apache2

# Criar página index.php
sudo tee /var/www/html/veiculos/index.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Controle de Veículos</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Controle de Veículos</h1>

        <form action="registra_saida.php" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <?php
                // Conectar ao banco de dados
                $host = 'localhost';
                $db = 'controle_veiculos';
                $user = 'teste';
                $pass = 'test@12345';

                $conn = new mysqli($host, $user, $pass, $db);
                if ($conn->connect_error) {
                    die("Connection failed: " . $conn->connect_error);
                }

                // Carregar placas dinamicamente
                $placas_query = "SELECT placa FROM veiculos";
                $placas_result = $conn->query($placas_query);
                while ($placa_row = $placas_result->fetch_assoc()) {
                    echo '<option value="' . $placa_row['placa'] . '">' . $placa_row['placa'] . '</option>';
                }
                ?>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <?php
                // Carregar motoristas dinamicamente
                $motoristas_query = "SELECT nome FROM motoristas";
                $motoristas_result = $conn->query($motoristas_query);
                while ($motorista_row = $motoristas_result->fetch_assoc()) {
                    echo '<option value="' . $motorista_row['nome'] . '">' . $motorista_row['nome'] . '</option>';
                }
                ?>
            </select>

            <label for="quilometragem_saida">Quilometragem de Saída:</label>
            <input type="number" id="quilometragem_saida" name="quilometragem_saida" required>

            <label for="data_hora_saida">Data e Hora de Saída:</label>
            <input type="datetime-local" id="data_hora_saida" name="data_hora_saida" required>

            <label for="destino">Destino:</label>
            <input type="text" id="destino" name="destino" required>
            <input type="submit" value="Registrar Saída">
        </form>

        <form action="registra_volta.php" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <?php
                // Carregar placas dinamicamente
                $placas_query = "SELECT placa FROM veiculos";
                $placas_result = $conn->query($placas_query);
                while ($placa_row = $placas_result->fetch_assoc()) {
                    echo '<option value="' . $placa_row['placa'] . '">' . $placa_row['placa'] . '</option>';
                }
                ?>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <?php
                // Carregar motoristas dinamicamente
                $motoristas_query = "SELECT nome FROM motoristas";
                $motoristas_result = $conn->query($motoristas_query);
                while ($motorista_row = $motoristas_result->fetch_assoc()) {
                    echo '<option value="' . $motorista_row['nome'] . '">' . $motorista_row['nome'] . '</option>';
                }
                ?>
            </select>

            <label for="quilometragem_volta">Quilometragem de Volta:</label>
            <input type="number" id="quilometragem_volta" name="quilometragem_volta" required>

            <label for="data_hora_volta">Data e Hora de Volta:</label>
            <input type="datetime-local" id="data_hora_volta" name="data_hora_volta" required>

            <input type="submit" value="Registrar Volta">
        </form>

        <form action="relatorio.php" method="get" style="position: absolute; top: 10px; right: 10px;">
            <input type="submit" value="Relatório">
        </form>

        <form action="configuracao.php" method="get" style="position: absolute; top: 10px; left: 10px;">
            <input type="submit" value="Configurações">
        </form>
    </div>
</body>
</html>
EOF

# Criar página registra_saida.php
sudo tee /var/www/html/veiculos/registra_saida.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Saída</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Registro de Saída</h1>
        <form action="" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <option value="APT-1010">APT-1010</option>
                <option value="APT-1011">APT-1011</option>
                <option value="ZTX-3245">ZTX-3245</option>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <option value="MOTORISTA01">MOTORISTA01</option>
                <option value="MOTORISTA02">MOTORISTA02</option>
                <option value="MOTORISTA03">MOTORISTA03</option>
                <option value="MOTORISTA04">MOTORISTA04</option>
            </select>

            <label for="quilometragem_saida">Quilometragem de Saída:</label>
            <input type="number" id="quilometragem_saida" name="quilometragem_saida" required>

            <label for="data_hora_saida">Data e Hora de Saída:</label>
            <input type="datetime-local" id="data_hora_saida" name="data_hora_saida" required>

            <label for="destino">Destino:</label>
            <input type="text" id="destino" name="destino" required>

            <input type="submit" value="Registrar Saída">
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $host = 'localhost';
            $db = 'controle_veiculos';
            $user = 'teste';
            $pass = 'test@12345';

            $conn = new mysqli($host, $user, $pass, $db);

            if ($conn->connect_error) {
                die("Connection failed: " . $conn->connect_error);
            }

            $placa = $_POST['placa'];
            $motorista = $_POST['motorista'];
            $quilometragem_saida = $_POST['quilometragem_saida'];
            $data_hora_saida = $_POST['data_hora_saida'];
            $destino = $_POST['destino'];

            // Verificar se o veículo já está em uso
            $veiculo_status_query = "SELECT status FROM veiculos WHERE placa='$placa'";
            $veiculo_status_result = $conn->query($veiculo_status_query);
            $veiculo_status_row = $veiculo_status_result->fetch_assoc();

            if ($veiculo_status_row['status'] === 'em uso') {
                echo "<p class='error'>Falha de registro: Veículo já está em uso.</p>";
            } else {
                // Obter IDs do motorista e do veículo
                $motorista_id_query = "SELECT id FROM motoristas WHERE nome='$motorista'";
                $motorista_id_result = $conn->query($motorista_id_query);
                $motorista_id_row = $motorista_id_result->fetch_assoc();
                $motorista_id = $motorista_id_row['id'];

                $veiculo_id_query = "SELECT id FROM veiculos WHERE placa='$placa'";
                $veiculo_id_result = $conn->query($veiculo_id_query);
                $veiculo_id_row = $veiculo_id_result->fetch_assoc();
                $veiculo_id = $veiculo_id_row['id'];

                // Registrar saída
                $sql = "INSERT INTO entradas_saidas (veiculo_id, motorista_id, quilometragem_saida, data_hora_saida, destino) 
                        VALUES ('$veiculo_id', '$motorista_id', '$quilometragem_saida', '$data_hora_saida', '$destino')";

                if ($conn->query($sql) === TRUE) {
                    // Atualizar status do veículo para 'em uso'
                    $update_status_sql = "UPDATE veiculos SET status='em uso' WHERE id='$veiculo_id'";
                    $conn->query($update_status_sql);

                    echo "<p class='success'>Registrado com sucesso</p>";
                } else {
                    echo "<p class='error'>Falha de registro: " . $conn->error . "</p>";
                }
            }

            $conn->close();
        }
        ?>
        <form action="index.php" method="get" style="position: absolute; top: 10px; right: 10px;">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
</body>
</html>
EOF

# Criar página registra_volta.php
sudo tee /var/www/html/veiculos/registra_volta.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Volta</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Registro de Volta</h1>
        <form action="" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <option value="APT-1010">APT-1010</option>
                <option value="APT-1011">APT-1011</option>
                <option value="ZTX-3245">ZTX-3245</option>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <option value="MOTORISTA01">MOTORISTA01</option>
                <option value="MOTORISTA02">MOTORISTA02</option>
                <option value="MOTORISTA03">MOTORISTA03</option>
                <option value="MOTORISTA04">MOTORISTA04</option>
            </select>

            <label for="quilometragem_volta">Quilometragem de Volta:</label>
            <input type="number" id="quilometragem_volta" name="quilometragem_volta" required>

            <label for="data_hora_volta">Data e Hora de Volta:</label>
            <input type="datetime-local" id="data_hora_volta" name="data_hora_volta" required>

            <input type="submit" value="Registrar Volta">
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $host = 'localhost';
            $db = 'controle_veiculos';
            $user = 'teste';
            $pass = 'test@12345';

            $conn = new mysqli($host, $user, $pass, $db);

            if ($conn->connect_error) {
                die("Connection failed: " . $conn->connect_error);
            }

            $placa = $_POST['placa'];
            $motorista = $_POST['motorista'];
            $quilometragem_volta = $_POST['quilometragem_volta'];
            $data_hora_volta = $_POST['data_hora_volta'];

            // Obter IDs do motorista e do veículo
            $motorista_id_query = "SELECT id FROM motoristas WHERE nome='$motorista'";
            $motorista_id_result = $conn->query($motorista_id_query);
            $motorista_id_row = $motorista_id_result->fetch_assoc();
            $motorista_id = $motorista_id_row['id'];

            $veiculo_id_query = "SELECT id FROM veiculos WHERE placa='$placa'";
            $veiculo_id_result = $conn->query($veiculo_id_query);
            $veiculo_id_row = $veiculo_id_result->fetch_assoc();
            $veiculo_id = $veiculo_id_row['id'];

            // Atualizar registro de saída com informações de volta
            $sql = "UPDATE entradas_saidas 
                    SET quilometragem_volta='$quilometragem_volta', data_hora_volta='$data_hora_volta'
                    WHERE veiculo_id='$veiculo_id' AND motorista_id='$motorista_id' AND quilometragem_volta IS NULL";

            if ($conn->query($sql) === TRUE) {
                // Atualizar status do veículo para 'disponivel'
                $update_status_sql = "UPDATE veiculos SET status='disponivel' WHERE id='$veiculo_id'";
                $conn->query($update_status_sql);

                echo "<p class='success'>Registrado com sucesso</p>";
            } else {
                echo "<p class='error'>Falha de registro: " . $conn->error . "</p>";
            }

            $conn->close();
        }
        ?>
        <form action="index.php" method="get" style="position: absolute; top: 10px; right: 10px;">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
</body>
</html>
EOF

# Cria página relatorio.php
sudo tee /var/www/html/veiculos/relatorio.php << 'EOF'
<?php
require 'vendor/autoload.php';
require_once 'vendor/setasign/fpdf/fpdf.php';

class PDF extends FPDF
{
    // Definindo cabeçalho e rodapé do PDF
    function Header()
    {
        $this->SetFont('Arial', 'B', 12);
        $this->Cell(0, 10, utf8_decode('Relatorio de Veiculos'), 0, 1, 'C');
        $this->Ln(10);
    }

    function Footer()
    {
        $this->SetY(-15);
        $this->SetFont('Arial', 'I', 8);
        $this->Cell(0, 10, 'Page ' . $this->PageNo(), 0, 0, 'C');
    }
}
?>

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

            <label for="placa">Placa:</label>
            <select id="placa" name="placa" required>
                <option value="todos">Todos</option>
                <?php
                $host = 'localhost';
                $db = 'controle_veiculos';
                $user = 'teste';
                $pass = 'test@12345';

                $conn = new mysqli($host, $user, $pass, $db);

                if ($conn->connect_error) {
                    die("Connection failed: " . $conn->connect_error);
                }

                $sql = "SELECT DISTINCT placa FROM veiculos";
                $result = $conn->query($sql);

                if ($result->num_rows > 0) {
                    while ($row = $result->fetch_assoc()) {
                        echo "<option value='" . htmlspecialchars($row['placa']) . "'>" . htmlspecialchars($row['placa']) . "</option>";
                    }
                }

                $conn->close();
                ?>
            </select>

            <input type="submit" value="Gerar Relatório">
        </form>
        <?php
        if (isset($_GET['data_inicio']) && isset($_GET['data_fim']) && isset($_GET['placa'])) {
            echo "Step 1: Conectando ao banco de dados...<br>";

            $conn = new mysqli($host, $user, $pass, $db);

            if ($conn->connect_error) {
                die("Connection failed: " . $conn->connect_error);
            }

            $data_inicio = $_GET['data_inicio'];
            $data_fim = $_GET['data_fim'];
            $placa = $_GET['placa'];

            $sql = "SELECT v.placa, m.nome, e.quilometragem_saida, e.data_hora_saida, e.destino, e.quilometragem_volta, e.data_hora_volta
                    FROM entradas_saidas e
                    JOIN veiculos v ON e.veiculo_id = v.id
                    JOIN motoristas m ON e.motorista_id = m.id
                    WHERE e.data_hora_saida BETWEEN '$data_inicio' AND '$data_fim'";

            if ($placa !== 'todos') {
                $sql .= " AND v.placa = '$placa'";
            }

            $sql .= " LIMIT 100";

            echo "Step 2: Executando a consulta...<br>";
            $result = $conn->query($sql);

            if ($result->num_rows > 0) {
                echo "Step 3: Inicializando PDF...<br>";

                try {
                    $pdf = new PDF('P', 'mm', 'A4');
                    echo "FPDF inicializado com sucesso.<br>";
                    $pdf->AddPage();
                    $pdf->SetFont('Arial', 'B', 10); // Reduzindo a fonte para 10
                } catch (Exception $e) {
                    echo 'Erro ao inicializar FPDF: ',  $e->getMessage(), "<br>";
                    exit();
                }

                // Cabeçalho da Tabela
                $pdf->Cell(20, 10, utf8_decode('Placa'), 1);
                $pdf->Cell(30, 10, utf8_decode('Motorista'), 1);
                $pdf->Cell(20, 10, utf8_decode('Km Saída'), 1);
                $pdf->Cell(35, 10, utf8_decode('Data/Hora Saída'), 1);
                $pdf->Cell(30, 10, utf8_decode('Destino'), 1);
                $pdf->Cell(20, 10, utf8_decode('Km Volta'), 1);
                $pdf->Cell(35, 10, utf8_decode('Data/Hora Volta'), 1);
                $pdf->Ln();

                // Dados da Tabela
                echo "Step 4: Processando registros...<br>";
                $pdf->SetFont('Arial', '', 10); // Fonte normal para os dados
                while ($row = $result->fetch_assoc()) {
                    $pdf->Cell(20, 10, utf8_decode($row['placa']), 1);
                    $pdf->Cell(30, 10, utf8_decode($row['nome']), 1);
                    $pdf->Cell(20, 10, utf8_decode($row['quilometragem_saida']), 1);
                    $pdf->Cell(35, 10, utf8_decode($row['data_hora_saida']), 1);
                    $pdf->Cell(30, 10, utf8_decode($row['destino']), 1);
                    $pdf->Cell(20, 10, utf8_decode($row['quilometragem_volta']), 1);
                    $pdf->Cell(35, 10, utf8_decode($row['data_hora_volta']), 1);
                    $pdf->Ln();
                }

                echo "Step 5: Salvando PDF...<br>";

                $filePath = '/var/www/html/veiculos/relatorio.pdf';
                $pdf->Output('F', $filePath);

                echo "<a href='relatorio.pdf'>Clique aqui para baixar o relatório</a>";
            } else {
                echo "<p>Nenhum registro encontrado para o período selecionado.</p>";
            }

            $conn->close();
        }
        ?>
        <form action="index.php" method="get" style="position: absolute; top: 10px; right: 10px;">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
</body>
</html>
EOF

# Estilos
sudo tee /var/www/html/veiculos/styles.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    background-color: #121212;
    color: #ffffff;
    margin: 0;
    padding: 0;
}
.container {
    width: 50%;
    margin: auto;
    padding: 20px;
    border: 1px solid #333;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
    background-color: #1e1e1e;
}
h1 {
    text-align: center;
    color: #4CAF50;
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
    background-color: #333;
    color: #fff;
    border: 1px solid #555;
    border-radius: 5px;
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
    background-color: #1e1e1e;
}
th, td {
    padding: 10px;
    border: 1px solid #333;
    text-align: left;
}
th {
    background-color: #333;
}
.success {
    color: #4CAF50;
}
.error {
    color: #FF0000;
}
EOF

#Dar permissões as pastas
sudo chown -R www-data:www-data /var/www/html/veiculos
sudo chmod -R 755 /var/www/html/veiculos
sudo chown -R www-data:www-data /var/www/html/veiculos/vendor
sudo chmod -R 755 /var/www/html/veiculos/vendor


echo "Instalação e configuração concluídas com sucesso."
