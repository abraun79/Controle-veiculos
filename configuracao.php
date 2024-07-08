<?php
$servername = "localhost";
$username = "teste";
$password = "test@12345";
$dbname = "controle_veiculos";

// Cria a conexão
$conn = new mysqli($servername, $username, $password, $dbname);

// Verifica a conexão
if ($conn->connect_error) {
    die("Conexão falhou: " . $conn->connect_error);
}

// Trata a submissão do formulário para adicionar veículo
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['add_vehicle'])) {
    $placa = $_POST['placa'];
    $status = $_POST['status'];
    $sql = "INSERT INTO veiculos (placa, status) VALUES ('$placa', '$status')";
    if ($conn->query($sql) === TRUE) {
        echo "Novo veículo adicionado com sucesso";
    } else {
        echo "Erro: " . $sql . "<br>" . $conn->error;
    }
}

// Trata a submissão do formulário para excluir veículo
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['delete_vehicle'])) {
    $vehicle_id = $_POST['vehicle_id'];
    $sql = "DELETE FROM veiculos WHERE id=$vehicle_id";
    if ($conn->query($sql) === TRUE) {
        echo "Veículo excluído com sucesso";
    } else {
        echo "Erro: " . $sql . "<br>" . $conn->error;
    }
}

// Trata a submissão do formulário para adicionar motorista
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['add_driver'])) {
    $nome = $_POST['nome'];
    $sql = "INSERT INTO motoristas (nome) VALUES ('$nome')";
    if ($conn->query($sql) === TRUE) {
        echo "Novo motorista adicionado com sucesso";
    } else {
        echo "Erro: " . $sql . "<br>" . $conn->error;
    }
}

// Trata a submissão do formulário para excluir motorista
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['delete_driver'])) {
    $driver_id = $_POST['driver_id'];
    $sql = "DELETE FROM motoristas WHERE id=$driver_id";
    if ($conn->query($sql) === TRUE) {
        echo "Motorista excluído com sucesso";
    } else {
        echo "Erro: " . $sql . "<br>" . $conn->error;
    }
}

// Busca veículos e motoristas
$vehicles = $conn->query("SELECT * FROM veiculos");
$drivers = $conn->query("SELECT * FROM motoristas");
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configuração de Veículos e Motoristas</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="header">
        <form action="index.php" method="get" style="position: absolute; top: 10px; right: 10px;">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
    <div class="container">
        <h1>Configuração de Veículos e Motoristas</h1>
        
        <h2>Adicionar Veículo</h2>
        <form method="post">
            Placa: <input type="text" name="placa" required>
            Status: <input type="text" name="status" required>
            <input type="submit" name="add_vehicle" value="Adicionar Veículo">
        </form>
        
        <h2>Excluir Veículo</h2>
        <form method="post">
            Selecione Veículo: 
            <select name="vehicle_id">
                <?php while($row = $vehicles->fetch_assoc()) { ?>
                    <option value="<?= $row['id'] ?>"><?= $row['placa'] ?></option>
                <?php } ?>
            </select>
            <input type="submit" name="delete_vehicle" value="Excluir Veículo">
        </form>
        
        <h2>Adicionar Motorista</h2>
        <form method="post">
            Nome: <input type="text" name="nome" required>
            <input type="submit" name="add_driver" value="Adicionar Motorista">
        </form>
        
        <h2>Excluir Motorista</h2>
        <form method="post">
            Selecione Motorista: 
            <select name="driver_id">
                <?php while($row = $drivers->fetch_assoc()) { ?>
                    <option value="<?= $row['id'] ?>"><?= $row['nome'] ?></option>
                <?php } ?>
            </select>
            <input type="submit" name="delete_driver" value="Excluir Motorista">
        </form>
    </div>
</body>
</html>

<?php
$conn->close();
?>

