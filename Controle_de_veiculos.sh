#!/bin/bash

# Cria o arquivo de configuração do MySQL
sudo tee /etc/mysql/my.cnf <<EOF
[mysqld]
skip-grant-tables
EOF

# Reinicia o serviço MySQL para aplicar a configuração
sudo service mysql restart

# Cria o banco de dados e as tabelas necessárias
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS controle_veiculos;
USE controle_veiculos;

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
EOF

# Insere dados de exemplo
mysql -u root <<EOF
USE controle_veiculos;

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

# Cria o arquivo PHP para registrar saída
sudo tee /var/www/html/registra_saida.php << 'EOF'
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
        <h1>Registrar Saída</h1>
        <form action="registra_saida.php" method="post">
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

            <label for="motorista">Nome do Motorista:</label>
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

            <label for="quilometragem_saida">Quilometragem de Saída:</label>
            <input type="number" id="quilometragem_saida" name="quilometragem_saida" required>

            <label for="data_hora_saida">Data e Hora de Saída:</label>
            <input type="datetime-local" id="data_hora_saida" name="data_hora_saida" required>

            <label for="destino">Destino:</label>
            <input type="text" id="destino" name="destino" required>

            <input type="submit" value="Registrar Saída">
        </form>
        <form action="index.php" method="get" style="position: absolute; top: 20px; right: 20px;">
            <input type="submit" value="Voltar ao início">
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

            $veiculo_id_query = "SELECT id FROM veiculos WHERE placa='$placa'";
            $veiculo_id_result = $conn->query($veiculo_id_query);
            $veiculo_id_row = $veiculo_id_result->fetch_assoc();
            $veiculo_id = $veiculo_id_row['id'];

            $motorista_id_query = "SELECT id FROM motoristas WHERE nome='$motorista'";
            $motorista_id_result = $conn->query($motorista_id_query);
            $motorista_id_row = $motorista_id_result->fetch_assoc();
            $motorista_id = $motorista_id_row['id'];

            $sql_check = "SELECT * FROM entradas_saidas WHERE veiculo_id='$veiculo_id' AND data_hora_volta IS NULL";
            $result_check = $conn->query($sql_check);

            if ($result_check->num_rows > 0) {
                echo "<script>alert('Este veículo já está em uso.');</script>";
            } else {
                $sql = "INSERT INTO entradas_saidas (veiculo_id, motorista_id, quilometragem_saida, data_hora_saida, destino) 
                        VALUES ('$veiculo_id', '$motorista_id', '$quilometragem_saida', '$data_hora_saida', '$destino')";

                if ($conn->query($sql) === TRUE) {
                    echo "<script>alert('Registro de saída bem-sucedido!');</script>";
                } else {
                    echo "<script>alert('Erro ao registrar saída: " . $conn->error . "');</script>";
                }
            }

            $conn->close();
        }
        ?>
    </div>
</body>
</html>
EOF

# Cria o arquivo PHP para registrar volta
sudo tee /var/www/html/registra_volta.php << 'EOF'
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
        <h1>Registrar Volta</h1>
        <form action="registra_volta.php" method="post">
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

            <label for="quilometragem_volta">Quilometragem de Volta:</label>
            <input type="number" id="quilometragem_volta" name="quilometragem_volta" required>

            <label for="data_hora_volta">Data e Hora de Volta:</label>
            <input type="datetime-local" id="data_hora_volta" name="data_hora_volta" required>

            <input type="submit" value="Registrar Volta">
        </form>
        <form action="index.php" method="get" style="position: absolute; top: 20px; right: 20px;">
            <input type="submit" value="Voltar ao início">
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
            $quilometragem_volta = $_POST['quilometragem_volta'];
            $data_hora_volta = $_POST['data_hora_volta'];

            $veiculo_id_query = "SELECT id FROM veiculos WHERE placa='$placa'";
            $veiculo_id_result = $conn->query($veiculo_id_query);
            $veiculo_id_row = $veiculo_id_result->fetch_assoc();
            $veiculo_id = $veiculo_id_row['id'];

            $sql_check = "SELECT * FROM entradas_saidas WHERE veiculo_id='$veiculo_id' AND data_hora_volta IS NULL";
            $result_check = $conn->query($sql_check);

            if ($result_check->num_rows == 0) {
                echo "<script>alert('Nenhum registro de saída encontrado para este veículo.');</script>";
            } else {
                $sql = "UPDATE entradas_saidas SET quilometragem_volta='$quilometragem_volta', data_hora_volta='$data_hora_volta'
                        WHERE veiculo_id='$veiculo_id' AND data_hora_volta IS NULL";

                if ($conn->query($sql) === TRUE) {
                    echo "<script>alert('Registro de volta bem-sucedido!');</script>";
                } else {
                    echo "<script>alert('Erro ao registrar volta: " . $conn->error . "');</script>";
                }
            }

            $conn->close();
        }
    </div>
</body>
</html>
EOF

# Cria o arquivo PHP para gerar relatórios
sudo tee /var/www/html/relatorio.php << 'EOF'
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
        <form action="index.php" method="get" style="position: absolute; top: 20px; right: 20px;">
            <input type="submit" value="Voltar ao início">
        </form>
        <?php
        if (isset($_GET['data_inicio']) && isset($_GET['data_fim'])) {
            $host = 'localhost';
            $db = 'controle_veiculos';
            $user = 'teste';
            $pass = 'test@12345';

            $conn = new mysqli($host, $user, $pass, $db);

            if ($conn->connect_error) {
                die("Connection failed: " . $conn->connect_error);
            }

            $data_inicio = $_GET['data_inicio'];
            $data_fim = $_GET['data_fim'];

            $sql = "SELECT v.placa, m.nome, e.quilometragem_saida, e.data_hora_saida, e.destino, e.quilometragem_volta, e.data_hora_volta
                    FROM entradas_saidas e
                    JOIN veiculos v ON e.veiculo_id = v.id
                    JOIN motoristas m ON e.motorista_id = m.id
                    WHERE e.data_hora_saida BETWEEN '$data_inicio' AND '$data_fim'";

            $result = $conn->query($sql);

            if ($result->num_rows > 0) {
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
                while ($row = $result->fetch_assoc()) {
                    echo "<tr>
                            <td>" . htmlspecialchars($row['placa']) . "</td>
                            <td>" . htmlspecialchars($row['nome']) . "</td>
                            <td>" . htmlspecialchars($row['quilometragem_saida']) . "</td>
                            <td>" . htmlspecialchars($row['data_hora_saida']) . "</td>
                            <td>" . htmlspecialchars($row['destino']) . "</td>
                            <td>" . htmlspecialchars($row['quilometragem_volta']) . "</td>
                            <td>" . htmlspecialchars($row['data_hora_volta']) . "</td>
                        </tr>";
                }
                echo "</table>";

                echo "<form action='download_relatorio.php' method='post'>
                        <input type='hidden' name='data_inicio' value='$data_inicio'>
                        <input type='hidden' name='data_fim' value='$data_fim'>
                        <input type='submit' value='Baixar Relatório'>
                      </form>";
            } else {
                echo "<p>Nenhum registro encontrado para o período selecionado.</p>";
            }

            $conn->close();
        }
        ?>
    </div>
</body>
</html>
EOF

# Cria o arquivo PHP para a página de configurações
sudo tee /var/www/html/configuracao.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configuração</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Configuração de Veículos e Motoristas</h1>
        <h2>Adicionar Motorista</h2>
        <form action="configuracao.php" method="post">
            <label for="novo_motorista">Novo Motorista:</label>
            <input type="text" id="novo_motorista" name="novo_motorista" required>
            <input type="submit" value="Adicionar Motorista">
        </form>
        <h2>Excluir Motorista</h2>
        <form action="configuracao.php" method="post">
            <label for="excluir_motorista">Excluir Motorista:</label>
            <select id="excluir_motorista" name="excluir_motorista" required>
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
            <input type="submit" value="Excluir Motorista">
        </form>
        <h2>Adicionar Veículo</h2>
        <form action="configuracao.php" method="post">
            <label for="novo_veiculo">Novo Veículo (Placa):</label>
            <input type="text" id="novo_veiculo" name="novo_veiculo" required>
            <input type="submit" value="Adicionar Veículo">
        </form>
        <h2>Excluir Veículo</h2>
        <form action="configuracao.php" method="post">
            <label for="excluir_veiculo">Excluir Veículo (Placa):</label>
            <select id="excluir_veiculo" name="excluir_veiculo" required>
                <option value="">Selecione o Veículo</option>
                <?php
                $conn = new mysqli('localhost', 'teste', 'test@12345', 'controle_veiculos');
                $result = $conn->query("SELECT placa FROM veiculos");
                while ($row = $result->fetch_assoc()) {
                    echo "<option value='{$row['placa']}'>{$row['placa']}</option>";
                }
                $conn->close();
                ?>
            </select>
            <input type="submit" value="Excluir Veículo">
        </form>
        <form action="index.php" method="get" style="position: absolute; top: 20px; right: 20px;">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
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

        if (isset($_POST['novo_motorista'])) {
            $novo_motorista = $_POST['novo_motorista'];
            $sql = "INSERT INTO motoristas (nome) VALUES ('$novo_motorista')";
            if ($conn->query($sql) === TRUE) {
                echo "<script>alert('Motorista adicionado com sucesso!');</script>";
            } else {
                echo "<script>alert('Erro ao adicionar motorista: " . $conn->error . "');</script>";
            }
        }

        if (isset($_POST['excluir_motorista'])) {
            $excluir_motorista = $_POST['excluir_motorista'];
            $sql = "DELETE FROM motoristas WHERE nome='$excluir_motorista'";
            if ($conn->query($sql) === TRUE) {
                echo "<script>alert('Motorista excluído com sucesso!');</script>";
            } else {
                echo "<script>alert('Erro ao excluir motorista: " . $conn->error . "');</script>";
            }
        }

        if (isset($_POST['novo_veiculo'])) {
            $novo_veiculo = $_POST['novo_veiculo'];
            $sql = "INSERT INTO veiculos (placa) VALUES ('$novo_veiculo')";
            if ($conn->query($sql) === TRUE) {
                echo "<script>alert('Veículo adicionado com sucesso!');</script>";
            } else {
                echo "<script>alert('Erro ao adicionar veículo: " . $conn->error . "');</script>";
            }
        }

        if (isset($_POST['excluir_veiculo'])) {
            $excluir_veiculo = $_POST['excluir_veiculo'];
            $sql = "DELETE FROM veiculos WHERE placa='$excluir_veiculo'";
            if ($conn->query($sql) === TRUE) {
                echo "<script>alert('Veículo excluído com sucesso!');</script>";
            } else {
                echo "<script>alert('Erro ao excluir veículo: " . $conn->error . "');</script>";
            }
        }

        $conn->close();
    }
    ?>
</body>
</html>
EOF

# Cria o arquivo PHP para download do relatório
sudo tee /var/www/html/download_relatorio.php << 'EOF'
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data_inicio = $_POST['data_inicio'];
    $data_fim = $_POST['data_fim'];

    $host = 'localhost';
    $db = 'controle_veiculos';
    $user = 'teste';
    $pass = 'test@12345';

    $conn = new mysqli($host, $user, $pass, $db);

    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $sql = "SELECT v.placa, m.nome, e.quilometragem_saida, e.data_hora_saida, e.destino, e.quilometragem_volta, e.data_hora_volta
            FROM entradas_saidas e
            JOIN veiculos v ON e.veiculo_id = v.id
            JOIN motoristas m ON e.motorista_id = m.id
            WHERE e.data_hora_saida BETWEEN '$data_inicio' AND '$data_fim'";

    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $filename = "relatorio_veiculos_" . date("Ymd_His") . ".csv";
        header("Content-Type: text/csv");
        header("Content-Disposition: attachment; filename=\"$filename\"");

        $output = fopen("php://output", "w");
        fputcsv($output, array('Placa', 'Motorista', 'Quilometragem Saída', 'Data Hora Saída', 'Destino', 'Quilometragem Volta', 'Data Hora Volta'));

        while ($row = $result->fetch_assoc()) {
            fputcsv($output, $row);
        }

        fclose($output);
    } else {
        echo "<script>alert('Nenhum registro encontrado para o período selecionado.'); window.location.href = 'relatorio.php';</script>";
    }

    $conn->close();
}
?>

EOF

# Cria o arquivo CSS para estilização
sudo tee styles.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    background-color: #333;
    color: #fff;
}
.container {
    width: 50%;
    margin: auto;
    padding: 20px;
    border: 1px solid #444;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
    background-color: #444;
}
h1, h2 {
    text-align: center;
}
form {
    display: flex;
    flex-direction: column;
}
label {
    margin-top: 10px;
    color: #ccc;
}
input, select {
    margin-bottom: 10px;
    padding: 10px;
    font-size: 16px;
    background-color: #555;
    color: #fff;
    border: 1px solid #666;
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
    background-color: #555;
    color: #fff;
}
th, td {
    padding: 10px;
    border: 1px solid #666;
    text-align: left;
}
th {
    background-color: #666;
}
EOF

# Reinicia o Apache para aplicar as mudanças
sudo systemctl restart apache2

echo "Configuração finalizada com sucesso!"
