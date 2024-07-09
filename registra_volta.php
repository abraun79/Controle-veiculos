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
        <h1>Registro de Volta</h1>
        <form action="" method="post">
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

            <label for="quilometragem_volta">Quilometragem de Volta:</label>
            <input type="number" id="quilometragem_volta" name="quilometragem_volta" required min="0" max="1000000">

            <label for="data_hora_volta">Data e Hora de Volta:</label>
            <input type="datetime-local" id="data_hora_volta" name="data_hora_volta" required>

            <input type="submit" value="Registrar Volta">
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
            $quilometragem_volta = $_POST['quilometragem_volta'];
            $data_hora_volta = $_POST['data_hora_volta'];

            // Obter IDs do motorista e do veículo
            $motorista_id_query = "SELECT id FROM motoristas WHERE nome='$motorista'";
            $motorista_id_result = $conn->query($motorista_id_query);
            $motorista_id_row = $motorista_id_result->fetch_assoc();
            $motorista_id = $motorista_id_row['id'];

            $veiculo_id_query = "SELECT id FROM veiculos WHERE placa='$placa'";
            $veiculo_id_result = $conn->query($veiculo_id_query);
            $veiculo_id_row = $veiculo_id_result->fetch_assoc();
            $veiculo_id = $veiculo_id_row['id'];

            // Validação adicional para garantir que a quilometragem de volta seja um valor dentro do intervalo permitido
            if ($quilometragem_volta < 0 || $quilometragem_volta > 1000000) {
                echo "<p class='error'>Valor da quilometragem inválido. Por favor, insira um valor entre 0 e 1.000.000.</p>";
            } else {
                // Atualizar registro de saída com informações de volta
                $sql = "UPDATE entradas_saidas 
                        SET quilometragem_volta='$quilometragem_volta', data_hora_volta='$data_hora_volta'
                        WHERE veiculo_id='$veiculo_id' AND motorista_id='$motorista_id' AND quilometragem_volta IS NULL";

                if ($conn->query($sql) === TRUE) {
                    // Atualizar status do veículo para 'disponivel'
                    $update_status_sql = "UPDATE veiculos SET status='disponivel' WHERE id='$veiculo_id'";
                    $conn->query($update_status_sql);

                    echo "<p class='success'>Registrado com sucesso</p>";
                } else {
                    echo "<p class='error'>Falha de registro: " . $conn->error . "</p>";
                }
            }

            $conn->close();
        }
        ?>

        <form action="index.php" method="get" style="margin-top: 20px;">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
</body>
</html>

