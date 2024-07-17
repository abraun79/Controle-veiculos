<?php
include 'db_config.php';

function sanitize_input($data) {
    return htmlspecialchars(stripslashes(trim($data)));
}

$message = '';
$error = '';

// Trata a submissão do formulário para adicionar ou excluir veículo ou motorista
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_POST['add_vehicle'])) {
        $placa = sanitize_input($_POST['placa']);
        $status = sanitize_input($_POST['status']);
        $stmt = $conn->prepare("INSERT INTO veiculos (placa, status) VALUES (?, ?)");
        $stmt->bind_param("ss", $placa, $status);
        if ($stmt->execute()) {
            $message = "Novo veículo adicionado com sucesso.";
        } else {
            $error = "Erro ao adicionar veículo: " . $stmt->error;
        }
        $stmt->close();
    }

    if (isset($_POST['delete_vehicle'])) {
        $vehicle_id = sanitize_input($_POST['vehicle_id']);
        $stmt = $conn->prepare("DELETE FROM veiculos WHERE id=?");
        $stmt->bind_param("i", $vehicle_id);
        if ($stmt->execute()) {
            $message = "Veículo excluído com sucesso.";
        } else {
            $error = "Erro ao excluir veículo: " . $stmt->error;
        }
        $stmt->close();
    }

    if (isset($_POST['add_driver'])) {
        $nome = sanitize_input($_POST['nome']);
        $stmt = $conn->prepare("INSERT INTO motoristas (nome) VALUES (?)");
        $stmt->bind_param("s", $nome);
        if ($stmt->execute()) {
            $message = "Novo motorista adicionado com sucesso.";
        } else {
            $error = "Erro ao adicionar motorista: " . $stmt->error;
        }
        $stmt->close();
    }

    if (isset($_POST['delete_driver'])) {
        $driver_id = sanitize_input($_POST['driver_id']);
        $stmt = $conn->prepare("DELETE FROM motoristas WHERE id=?");
        $stmt->bind_param("i", $driver_id);
        if ($stmt->execute()) {
            $message = "Motorista excluído com sucesso.";
        } else {
            $error = "Erro ao excluir motorista: " . $stmt->error;
        }
        $stmt->close();
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
    <div class="container">
        <h1>Configuração de Veículos e Motoristas</h1>
        
        <?php if ($message): ?>
            <p class="success"><?= $message ?></p>
        <?php endif; ?>

        <?php if ($error): ?>
            <p class="error"><?= $error ?></p>
        <?php endif; ?>
        
        <h2>Adicionar Veículo</h2>
        <form method="post">
            Placa: <input type="text" name="placa" required>
            Status: <input type="text" name="status" required>
            <input type="submit" name="add_vehicle" value="Adicionar Veículo">
        </form>
        
        <h2>Excluir Veículo</h2>
        <form method="post">
            Selecione Veículo: 
            <select name="vehicle_id" required>
                <?php while ($row = $vehicles->fetch_assoc()): ?>
                    <option value="<?= $row['id'] ?>"><?= $row['placa'] ?></option>
                <?php endwhile; ?>
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
            <select name="driver_id" required>
                <?php while ($row = $drivers->fetch_assoc()): ?>
                    <option value="<?= $row['id'] ?>"><?= $row['nome'] ?></option>
                <?php endwhile; ?>
            </select>
            <input type="submit" name="delete_driver" value="Excluir Motorista">
        </form>

        <form action="index.php" method="get" style="margin-top: 20px;">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
</body>
</html>

<?php
$conn->close();
?>
