<?php
include 'db_config.php';

// Verifica se o formulário foi submetido
$message = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $placa = $_POST['placa'];
    $motorista = $_POST['motorista'];
    $data_hora_saida = $_POST['data_hora_saida'];
    $destino = $_POST['destino'];
    $quilometragem_saida = $_POST['quilometragem_saida']; // Recebe o valor do formulário

    // Busca o ID do veículo
    $stmt = $conn->prepare("SELECT id FROM veiculos WHERE placa = ?");
    $stmt->bind_param("s", $placa);
    $stmt->execute();
    $stmt->bind_result($veiculo_id);
    $stmt->fetch();
    $stmt->close();

    // Verifica se o ID do veículo foi encontrado
    if (!$veiculo_id) {
        die("Veículo não encontrado");
    }

    // Busca o ID do motorista
    $stmt = $conn->prepare("SELECT id FROM motoristas WHERE nome = ?");
    $stmt->bind_param("s", $motorista);
    $stmt->execute();
    $stmt->bind_result($motorista_id);
    $stmt->fetch();
    $stmt->close();

    // Verifica se o ID do motorista foi encontrado
    if (!$motorista_id) {
        die("Motorista não encontrado");
    }

    // Insere a nova saída
    $stmt = $conn->prepare("INSERT INTO entradas_saidas (veiculo_id, motorista_id, quilometragem_saida, data_hora_saida, destino) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("iiiss", $veiculo_id, $motorista_id, $quilometragem_saida, $data_hora_saida, $destino);

    if ($stmt->execute()) {
        $message = "Saída registrada com sucesso!";
    } else {
        $message = "Erro ao registrar saída: " . $stmt->error;
    }

    $stmt->close();
    $conn->close();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Saída</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .message-container {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
            text-align: center;
        }
        .message-container form {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="message-container">
        <p><?php echo htmlspecialchars($message); ?></p>
        <form action="index.php" method="get">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
</body>
</html>

