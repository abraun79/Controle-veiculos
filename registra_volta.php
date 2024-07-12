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
                <option value="" disabled selected>Selecione uma placa</option>
                <?php
                include 'db_config.php';

                function loadOptions($conn, $query, $valueField, $textField) {
                    $result = $conn->query($query);
                    while ($row = $result->fetch_assoc()) {
                        echo '<option value="' . htmlspecialchars($row[$valueField]) . '">' . htmlspecialchars($row[$textField]) . '</option>';
                    }
                }

                $placas_query = "SELECT placa FROM veiculos";
                loadOptions($conn, $placas_query, 'placa', 'placa');
                ?>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <option value="" disabled selected>Selecione um motorista</option>
                <?php
                $motoristas_query = "SELECT nome FROM motoristas";
                loadOptions($conn, $motoristas_query, 'nome', 'nome');
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
            $placa = $_POST['placa'];
            $motorista = $_POST['motorista'];
            $quilometragem_volta = $_POST['quilometragem_volta'];
            $data_hora_volta = $_POST['data_hora_volta'];

            $motorista_id_query = "SELECT id FROM motoristas WHERE nome=?";
            $stmt_motorista = $conn->prepare($motorista_id_query);
            $stmt_motorista->bind_param("s", $motorista);
            $stmt_motorista->execute();
            $motorista_id_result = $stmt_motorista->get_result();
            $motorista_id_row = $motorista_id_result->fetch_assoc();
            $motorista_id = $motorista_id_row['id'];

            $veiculo_id_query = "SELECT id FROM veiculos WHERE placa=?";
            $stmt_veiculo = $conn->prepare($veiculo_id_query);
            $stmt_veiculo->bind_param("s", $placa);
            $stmt_veiculo->execute();
            $veiculo_id_result = $stmt_veiculo->get_result();
            $veiculo_id_row = $veiculo_id_result->fetch_assoc();
            $veiculo_id = $veiculo_id_row['id'];

            if ($quilometragem_volta < 0 || $quilometragem_volta > 1000000) {
                echo "<p class='error'>Valor da quilometragem inválido. Por favor, insira um valor entre 0 e 1.000.000.</p>";
            } else {
                $sql = "UPDATE entradas_saidas 
                        SET quilometragem_volta=?, data_hora_volta=?
                        WHERE veiculo_id=? AND motorista_id=? AND quilometragem_volta IS NULL";

                $stmt_update = $conn->prepare($sql);
                $stmt_update->bind_param("isii", $quilometragem_volta, $data_hora_volta, $veiculo_id, $motorista_id);

                if ($stmt_update->execute()) {
                    $update_status_sql = "UPDATE veiculos SET status='disponivel' WHERE id=?";
                    $stmt_status = $conn->prepare($update_status_sql);
                    $stmt_status->bind_param("i", $veiculo_id);
                    $stmt_status->execute();

                    echo "<p class='success'>Registrado com sucesso</p>";
                } else {
                    echo "<p class='error'>Falha de registro: " . $conn->error . "</p>";
                }
            }

            $stmt_motorista->close();
            $stmt_veiculo->close();
            $stmt_update->close();
            $stmt_status->close();
            $conn->close();
        }
        ?>

        <form action="index.php" method="get" style="margin-top: 20px;">
            <input type="submit" value="Voltar ao início">
        </form>
    </div>
</body>
</html>
