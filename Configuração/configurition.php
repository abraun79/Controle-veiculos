<?php
$servername = "localhost";
$username = "teste";
$password = "test@12345";
$dbname = "controle_veiculos";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle form submission for adding vehicle
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['add_vehicle'])) {
    $placa = $_POST['placa'];
    $status = $_POST['status'];
    $sql = "INSERT INTO veiculos (placa, status) VALUES ('$placa', '$status')";
    if ($conn->query($sql) === TRUE) {
        echo "New vehicle added successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

// Handle form submission for deleting vehicle
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['delete_vehicle'])) {
    $vehicle_id = $_POST['vehicle_id'];
    $sql = "DELETE FROM veiculos WHERE id=$vehicle_id";
    if ($conn->query($sql) === TRUE) {
        echo "Vehicle deleted successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

// Handle form submission for adding driver
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['add_driver'])) {
    $nome = $_POST['nome'];
    $sql = "INSERT INTO motoristas (nome) VALUES ('$nome')";
    if ($conn->query($sql) === TRUE) {
        echo "New driver added successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

// Handle form submission for deleting driver
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['delete_driver'])) {
    $driver_id = $_POST['driver_id'];
    $sql = "DELETE FROM motoristas WHERE id=$driver_id";
    if ($conn->query($sql) === TRUE) {
        echo "Driver deleted successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

// Fetch vehicles and drivers
$vehicles = $conn->query("SELECT * FROM veiculos");
$drivers = $conn->query("SELECT * FROM motoristas");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configuração de Veículos e Motoristas</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="header">
        <a href="index.php">↑</a>
    </div>
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
</body>
</html>

<?php
$conn->close();
?>
