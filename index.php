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

                $conn->set_charset("utf8");

                // Carregar placas dinamicamente
                $placas_query = "SELECT placa FROM veiculos";
                if ($placas_result = $conn->query($placas_query)) {
                    while ($placa_row = $placas_result->fetch_assoc()) {
                        echo '<option value="' . htmlspecialchars($placa_row['placa']) . '">' . htmlspecialchars($placa_row['placa']) . '</option>';
                    }
                    $placas_result->free();
                }

                ?>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <?php
                // Carregar motoristas dinamicamente
                $motoristas_query = "SELECT nome FROM motoristas";
                if ($motoristas_result = $conn->query($motoristas_query)) {
                    while ($motorista_row = $motoristas_result->fetch_assoc()) {
                        echo '<option value="' . htmlspecialchars($motorista_row['nome']) . '">' . htmlspecialchars($motorista_row['nome']) . '</option>';
                    }
                    $motoristas_result->free();
                }
                ?>
            </select>

            <label for="data_hora_saida">Data e Hora de Saída:</label>
            <input type="datetime-local" id="data_hora_saida" name="data_hora_saida" required>

            <label for="destino">Destino:</label>
            <input type="text" id="destino" name="destino" required>
            
            <label for="quilometragem_saida">Quilometragem de Saída:</label>
            <input type="number" id="quilometragem_saida" name="quilometragem_saida" required>

            <input type="submit" value="Registrar Saída">
        </form>

        <!-- Formulário para redirecionar para registra_volta.php -->
        <form action="registra_volta.php" method="get" style="margin-top: 20px;">
            <input type="submit" value="Registrar Volta">
        </form>
        
        <form action="relatorio.php" method="get" style="margin-top: 20px;">
            <input type="submit" value="Relatório">
        </form>

        <form action="configuracao.php" method="get" style="margin-top: 20px;">
            <input type="submit" value="Configurações">
        </form>
    </div>
</body>
</html>

