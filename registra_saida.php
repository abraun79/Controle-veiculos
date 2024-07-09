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

// Verifica se o formulário foi submetido
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $placa = $_POST['placa'];
    $motorista = $_POST['motorista'];
    $data_hora_saida = $_POST['data_hora_saida'];
    $destino = $_POST['destino'];

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

    // Consulta a última quilometragem de volta
    $stmt = $conn->prepare("SELECT quilometragem_volta FROM entradas_saidas WHERE veiculo_id = ? ORDER BY id DESC LIMIT 1");
    $stmt->bind_param("i", $veiculo_id);
    $stmt->execute();
    $stmt->bind_result($quilometragem_volta);
    $stmt->fetch();
    $stmt->close();

    // Se não houver registro anterior, define a quilometragem de saída como 0
    $quilometragem_saida = $quilometragem_volta ?? 0;

    // Insere a nova saída
    $stmt = $conn->prepare("INSERT INTO entradas_saidas (veiculo_id, motorista_id, quilometragem_saida, data_hora_saida, destino) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("iiiss", $veiculo_id, $motorista_id, $quilometragem_saida, $data_hora_saida, $destino);

    if ($stmt->execute()) {
        echo "Saída registrada com sucesso!";
    } else {
        echo "Erro ao registrar saída: " . $stmt->error;
    }

    $stmt->close();
    $conn->close();
}
?>

