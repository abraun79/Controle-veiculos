#!/bin/bash

# Atualiza o sistema
sudo apt-get update
sudo apt-get upgrade -y

# Instala o Apache, MySQL e PHP
sudo apt-get install apache2 mysql-server php libapache2-mod-php php-mysql -y

# Configura o MySQL
sudo mysql -e "CREATE DATABASE controle_veiculos;"
sudo mysql -e "CREATE USER 'teste'@'localhost' IDENTIFIED BY 'test@12345';"
sudo mysql -e "GRANT ALL PRIVILEGES ON controle_veiculos.* TO 'teste'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

mysql -u teste -p'test@12345' controle_veiculos <<EOF
CREATE TABLE IF NOT EXISTS veiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS motoristas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS entradas_saidas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id INT NOT NULL,
    motorista_id INT NOT NULL,
    quilometragem_saida INT NOT NULL,
    data_hora_saida DATETIME NOT NULL,
    destino VARCHAR(100) NOT NULL,
    quilometragem_volta INT,
    data_hora_volta DATETIME,
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (motorista_id) REFERENCES motoristas(id)
);

INSERT IGNORE INTO veiculos (placa) VALUES
('APT-1010'),
('APT-1011'),
('ZTX-3245');

INSERT IGNORE INTO motoristas (nome) VALUES
('MOTORISTA01'),
('MOTORISTA02'),
('MOTORISTA03'),
('MOTORISTA04');
EOF

# Configura o Apache para o projeto
sudo mkdir -p /var/www/html/veiculos
sudo chown -R $USER:$USER /var/www/html/veiculos

# Cria o arquivo header.php
sudo tee /var/www/html/veiculos/header.php << 'EOF'
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
        <header>
            <h1>Controle de Veículos</h1>
            <nav>
                <ul>
                    <li><a href="index.php">Início</a></li>
                    <li><a href="registro_saida.php">Registrar Saída</a></li>
                    <li><a href="registro_volta.php">Registrar Volta</a></li>
                    <li><a href="relatorio.php">Relatório</a></li>
                    <li><a href="configuracao.php">Configuração</a></li>
                </ul>
            </nav>
        </header>
        <main>
EOF

# Cria o arquivo footer.php
sudo tee /var/www/html/veiculos/footer.php << 'EOF'
        </main>
    </div>
    <script src="scripts.js"></script>
</body>
</html>
EOF

# Cria o arquivo index.php
sudo tee /var/www/html/veiculos/index.php << 'EOF'
<?php include 'header.php'; ?>
<p>Bem-vindo ao sistema de controle de veículos. Use o menu acima para navegar.</p>
<?php include 'footer.php'; ?>
EOF

# Cria o arquivo registro_saida.php
sudo tee /var/www/html/veiculos/registro_saida.php << 'EOF'
<?php include 'header.php'; ?>
<h2>Registro de Saída</h2>
<form id="registro-saida-form" action="processa_saida.php" method="post">
    <label for="placa">Placa do Veículo:</label>
    <select id="placa" name="placa" required>
        <option value="">Selecione a Placa</option>
        <?php
        $conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
        $result = $conn->query("SELECT placa FROM veiculos");
        while ($row = $result->fetch_assoc()) {
            echo "<option value='{$row['placa']}'>{$row['placa']}</option>";
        }
        $conn->close();
        ?>
    </select>

    <label for="motorista">Motorista:</label>
    <select id="motorista" name="motorista" required>
        <option value="">Selecione o Motorista</option>
        <?php
        $conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
        $result = $conn->query("SELECT nome FROM motoristas");
        while ($row = $result->fetch_assoc()) {
            echo "<option value='{$row['nome']}'>{$row['nome']}</option>";
        }
        $conn->close();
        ?>
    </select>

    <label for="quilometragem-saida">Quilometragem de Saída:</label>
    <input type="number" id="quilometragem-saida" name="quilometragem_saida" required>

    <label for="data-hora-saida">Data e Hora de Saída:</label>
    <input type="datetime-local" id="data-hora-saida" name="data_hora_saida" required>

    <label for="destino">Destino:</label>
    <input type="text" id="destino" name="destino" required>

    <input type="submit" value="Registrar Saída">
</form>
<?php include 'footer.php'; ?>
EOF

# Cria o arquivo registro_volta.php
sudo tee /var/www/html/veiculos/registro_volta.php << 'EOF'
<?php include 'header.php'; ?>
<h2>Registro de Volta</h2>
<form id="registro-volta-form" action="processa_volta.php" method="post">
    <label for="placa">Placa do Veículo:</label>
    <select id="placa" name="placa" required>
        <option value="">Selecione a Placa</option>
        <?php
        $conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
        $result = $conn->query("SELECT v.placa FROM veiculos v JOIN entradas_saidas e ON v.id = e.veiculo_id WHERE e.data_hora_volta IS NULL");
        while ($row = $result->fetch_assoc()) {
            echo "<option value='{$row['placa']}'>{$row['placa']}</option>";
        }
        $conn->close();
        ?>
    </select>

    <label for="quilometragem-volta">Quilometragem de Volta:</label>
    <input type="number" id="quilometragem-volta" name="quilometragem_volta" required>

    <label for="data-hora-volta">Data e Hora de Volta:</label>
    <input type="datetime-local" id="data-hora-volta" name="data_hora_volta" required>

    <input type="submit" value="Registrar Volta">
</form>
<?php include 'footer.php'; ?>
EOF

# Cria o arquivo relatorio.php
sudo tee /var/www/html/veiculos/relatorio.php << 'EOF'
<?php include 'header.php'; ?>
<h2>Relatório</h2>
<table>
    <thead>
        <tr>
            <th>Veículo</th>
            <th>Motorista</th>
            <th>Quilometragem Saída</th>
            <th>Data e Hora Saída</th>
            <th>Destino</th>
            <th>Quilometragem Volta</th>
            <th>Data e Hora Volta</th>
        </tr>
    </thead>
    <tbody>
        <?php
        $conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
        $query = "
        SELECT v.placa, m.nome, e.quilometragem_saida, e.data_hora_saida, e.destino, e.quilometragem_volta, e.data_hora_volta
        FROM entradas_saidas e
        JOIN veiculos v ON e.veiculo_id = v.id
        JOIN motoristas m ON e.motorista_id = m.id";
        $result = $conn->query($query);
        while ($row = $result->fetch_assoc()) {
            echo "
            <tr>
                <td>{$row['placa']}</td>
                <td>{$row['nome']}</td>
                <td>{$row['quilometragem_saida']}</td>
                <td>{$row['data_hora_saida']}</td>
                <td>{$row['destino']}</td>
                <td>{$row['quilometragem_volta']}</td>
                <td>{$row['data_hora_volta']}</td>
            </tr>";
        }
        $conn->close();
        ?>
    </tbody>
</table>
<?php include 'footer.php'; ?>
EOF

# Cria o arquivo configuracao.php
sudo tee /var/www/html/veiculos/configuracao.php << 'EOF'
<?php include 'header.php'; ?>
<h2>Configuração</h2>
<form id="configuracao-form" action="adicionar.php" method="post">
    <label for="novo-veiculo">Adicionar Veículo (Placa):</label>
    <input type="text" id="novo-veiculo" name="novo_veiculo">
    <input type="submit" name="adicionar_veiculo" value="Adicionar Veículo">
</form>
<form id="configuracao-form" action="adicionar.php" method="post">
    <label for="novo-motorista">Adicionar Motorista (Nome):</label>
    <input type="text" id="novo-motorista" name="novo_motorista">
    <input type="submit" name="adicionar_motorista" value="Adicionar Motorista">
</form>
<?php include 'footer.php'; ?>
EOF

# Cria o arquivo processa_saida.php
sudo tee /var/www/html/veiculos/processa_saida.php << 'EOF'
<?php
$placa = $_POST['placa'];
$motorista = $_POST['motorista'];
$quilometragem_saida = $_POST['quilometragem_saida'];
$data_hora_saida = $_POST['data_hora_saida'];
$destino = $_POST['destino'];

$conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
$veiculo_id = $conn->query("SELECT id FROM veiculos WHERE placa='$placa'")->fetch_assoc()['id'];
$motorista_id = $conn->query("SELECT id FROM motoristas WHERE nome='$motorista'")->fetch_assoc()['id'];

$query = "INSERT INTO entradas_saidas (veiculo_id, motorista_id, quilometragem_saida, data_hora_saida, destino) VALUES ($veiculo_id, $motorista_id, $quilometragem_saida, '$data_hora_saida', '$destino')";
$conn->query($query);
$conn->close();

header('Location: index.php');
?>
EOF

# Cria o arquivo processa_volta.php
sudo tee /var/www/html/veiculos/processa_volta.php << 'EOF'
<?php
$placa = $_POST['placa'];
$quilometragem_volta = $_POST['quilometragem_volta'];
$data_hora_volta = $_POST['data_hora_volta'];

$conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
$veiculo_id = $conn->query("SELECT id FROM veiculos WHERE placa='$placa'")->fetch_assoc()['id'];

$query = "UPDATE entradas_saidas SET quilometragem_volta=$quilometragem_volta, data_hora_volta='$data_hora_volta' WHERE veiculo_id=$veiculo_id AND data_hora_volta IS NULL";
$conn->query($query);
$conn->close();

header('Location: index.php');
?>
EOF

# Cria o arquivo adicionar.php
sudo tee /var/www/html/veiculos/adicionar.php << 'EOF'
<?php
if (isset($_POST['adicionar_veiculo'])) {
    $novo_veiculo = $_POST['novo_veiculo'];
    $conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
    $conn->query("INSERT INTO veiculos (placa) VALUES ('$novo_veiculo')");
    $conn->close();
} elseif (isset($_POST['adicionar_motorista'])) {
    $novo_motorista = $_POST['novo_motorista'];
    $conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
    $conn->query("INSERT INTO motoristas (nome) VALUES ('$novo_motorista')");
    $conn->close();
}

header('Location: configuracao.php');
?>
EOF

# Cria o arquivo styles.css
sudo tee /var/www/html/veiculos/styles.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f4;
    color: #333;
}

.container {
    width: 80%;
    margin: 0 auto;
    padding: 20px;
    background-color: #fff;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}

header {
    text-align: center;
    margin-bottom: 20px;
}

header h1 {
    margin: 0;
}

nav ul {
    list-style: none;
    padding: 0;
}

nav ul li {
    display: inline;
    margin-right: 10px;
}

nav ul li a {
    text-decoration: none;
    color: #333;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
}

table, th, td {
    border: 1px solid #ddd;
}

th, td {
    padding: 8px;
    text-align: left;
}
EOF

# Cria o arquivo scripts.js
sudo tee /var/www/html/veiculos/scripts.js << 'EOF'
document.addEventListener('DOMContentLoaded', function() {
    // Scripts JavaScript futuros podem ser adicionados aqui
});
EOF

# Configura permissões
sudo chown -R www-data:www-data /var/www/html/veiculos
sudo chmod -R 755 /var/www/html/veiculos

echo "Instalação completa. Acesse o sistema através do endereço http://localhost/veiculos"
