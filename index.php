<?php
$servername = "localhost";
$username = "teste";
$password = "test@12345";
$dbname = "controle_veiculos";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}

// Consulta para obter todas as placas
$placas_query = "SELECT id, placa FROM veiculos";
$placas_result = $conn->query($placas_query);

// Consulta para obter todos os motoristas
$motoristas_query = "SELECT id, nome FROM motoristas";
$motoristas_result = $conn->query($motoristas_query);
?>

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
                <?php while ($placa_row = $placas_result->fetch_assoc()) {
                    $placa_id = $placa_row['id'];
                    $placa = $placa_row['placa'];
                    
                    // Buscar quilometragem de volta mais recente para essa placa
                    $quilometragem_query = "SELECT quilometragem_volta FROM entradas_saidas WHERE veiculo_id = '$placa_id' ORDER BY data_hora_volta DESC LIMIT 1";
                    $quilometragem_result = $conn->query($quilometragem_query);
                    $quilometragem_row = $quilometragem_result->fetch_assoc();
                    $quilometragem_saida = $quilometragem_row ? $quilometragem_row['quilometragem_volta'] : 0;
                    
                    echo '<option value="' . $placa_id . '" data-quilometragem="' . $quilometragem_saida . '">' . $placa . '</option>';
                } ?>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <?php while ($motorista_row = $motoristas_result->fetch_assoc()) {
                    echo '<option value="' . $motorista_row['id'] . '">' . $motorista_row['nome'] . '</option>';
                } ?>
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
            <label for="placa_volta">Placa do Veículo:</label>
            <select id="placa_volta" name="placa_volta" required>
                <?php
                // Reutilizar o resultado das placas
                $placas_result->data_seek(0); // Resetar o ponteiro do resultado
                while ($placa_row = $placas_result->fetch_assoc()) {
                    echo '<option value="' . $placa_row['id'] . '">' . $placa_row['placa'] . '</option>';
                }
                ?>
            </select>

            <label for="motorista_volta">Motorista:</label>
            <select id="motorista_volta" name="motorista_volta" required>
                <?php
                // Reutilizar o resultado dos motoristas
                $motoristas_result->data_seek(0); // Resetar o ponteiro do resultado
                while ($motorista_row = $motoristas_result->fetch_assoc()) {
                    echo '<option value="' . $motorista_row['id'] . '">' . $motorista_row['nome'] . '</option>';
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

    <script>
        document.getElementById('placa').addEventListener('change', function () {
            var quilometragem = this.options[this.selectedIndex].getAttribute('data-quilometragem');
            document.getElementById('quilometragem_saida').value = quilometragem;
        });
    </script>
</body>
</html>

<?php
$conn->close();
?>

