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

            <label for="data_hora_saida">Data e Hora de Saída:</label>
            <input type="datetime-local" id="data_hora_saida" name="data_hora_saida" required>

            <label for="destino">Destino:</label>
            <input type="text" id="destino" name="destino" required>
            
            <input type="hidden" id="quilometragem_saida" name="quilometragem_saida">

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

