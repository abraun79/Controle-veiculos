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
                <option value="" disabled selected>Selecione uma placa</option>
                <?php
                function loadOptions($conn, $query, $valueField) {
                    if ($result = $conn->query($query)) {
                        if ($result->num_rows > 0) {
                            while ($row = $result->fetch_assoc()) {
                                echo '<option value="' . htmlspecialchars($row[$valueField]) . '">' . htmlspecialchars($row[$valueField]) . '</option>';
                            }
                        } else {
                            echo '<option value="">Nenhum resultado encontrado</option>';
                        }
                        $result->free();
                    } else {
                        echo '<option value="">Erro ao carregar opções</option>';
                    }
                }

                loadOptions($conn, "SELECT placa FROM veiculos", "placa");
                ?>
            </select>

            <label for="motorista">Motorista:</label>
            <select id="motorista" name="motorista" required>
                <option value="" disabled selected>Selecione um motorista</option>
                <?php
                loadOptions($conn, "SELECT nome FROM motoristas", "nome");
                ?>
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
