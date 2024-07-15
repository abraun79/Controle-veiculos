<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Volta</title>
    <link rel="stylesheet" href="styles.css">
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Função para carregar opções dinamicamente
            function loadOptions(query, selectId, valueField) {
                fetch('load_options.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ query: query, valueField: valueField })
                })
                .then(response => response.json())
                .then(data => {
                    const select = document.getElementById(selectId);
                    select.innerHTML = '<option value="" disabled selected>Selecione uma opção</option>';
                    data.forEach(option => {
                        const opt = document.createElement('option');
                        opt.value = option.value;
                        opt.textContent = option.text;
                        select.appendChild(opt);
                    });
                })
                .catch(error => console.error('Erro ao carregar opções:', error));
            }

            // Carregar opções de veículos e motoristas
            loadOptions('SELECT placa FROM veiculos', 'placa', 'placa');
            loadOptions('SELECT nome FROM motoristas', 'motorista', 'nome');

            // Validação de formulário
            const form = document.querySelector('form');
            form.addEventListener('submit', function(event) {
                const quilometragemVolta = document.getElementById('quilometragem_volta').value;
                if (quilometragemVolta < 0 || quilometragemVolta > 1000000) {
                    event.preventDefault();
                    alert('Por favor, insira um valor de quilometragem entre 0 e 1.000.000.');
                }
            });
        });
    </script>
</head>
<body>
    <div class="container">
        <h1>Registro de Volta</h1>
        <form action="" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <option value="" disabled selected>Carregando...</option>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <option value="" disabled selected>Carregando...</option>
            </select>

            <label for="quilometragem_volta">Quilometragem de Volta:</label>
            <input type="number" id="quilometragem_volta" name="quilometragem_volta" required min="0" max="1000000">

            <label for="data_hora_volta">Data e Hora de Volta:</label>
            <input type="datetime-local" id="data_hora_volta" name="data_hora_volta" required>

            <input type="submit" value="Registrar Volta">
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            include 'db_config.php';

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

