<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Controle de Veículos</title>
    <link rel="stylesheet" href="styles.css">
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Função para carregar opções dinamicamente
            function loadOptions(url, selectId) {
                fetch(url)
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
            loadOptions('load_veiculos.php', 'placa');
            loadOptions('load_motoristas.php', 'motorista');

            // Validação de formulário
            const form = document.querySelector('form');
            form.addEventListener('submit', function(event) {
                const placa = document.getElementById('placa').value;
                const motorista = document.getElementById('motorista').value;
                const dataHoraSaida = document.getElementById('data_hora_saida').value;
                const destino = document.getElementById('destino').value;
                const quilometragemSaida = document.getElementById('quilometragem_saida').value;

                if (!placa || !motorista || !dataHoraSaida || !destino || !quilometragemSaida) {
                    event.preventDefault();
                    alert('Por favor, preencha todos os campos obrigatórios.');
                }
            });
        });
    </script>
</head>
<body>
    <div class="container">
        <h1>Controle de Veículos</h1>

        <?php
        // Incluir o arquivo de configuração do banco de dados
        include 'db_config.php';

        // Verificar se a conexão foi bem-sucedida
        if ($conn->connect_error) {
            die("Falha na conexão com o banco de dados: " . $conn->connect_error);
        } else {
            echo "<p>Conexão com o banco de dados estabelecida com sucesso.</p>";
        }
        ?>

        <form action="registra_saida.php" method="post">
            <label for="placa">Placa do Veículo:</label>
            <select id="placa" name="placa" required>
                <option value="" disabled selected>Carregando...</option>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <option value="" disabled selected>Carregando...</option>
            </select>

            <label for="data_hora_saida">Data e Hora de Saída:</label>
            <input type="datetime-local" id="data_hora_saida" name="data_hora_saida" required placeholder="Selecione a data e hora">

            <label for="destino">Destino:</label>
            <input type="text" id="destino" name="destino" required placeholder="Digite o destino">
            
            <label for="quilometragem_saida">Quilometragem de Saída:</label>
            <input type="number" id="quilometragem_saida" name="quilometragem_saida" required placeholder="Digite a quilometragem de saída">

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

        <?php
        $conn->close(); // Fechar a conexão com o banco de dados
        ?>
    </div>
</body>
</html>

