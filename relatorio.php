<?php
require 'vendor/autoload.php';
require_once 'vendor/setasign/fpdf/fpdf.php';

class PDF extends FPDF
{
    // Definindo cabeçalho e rodapé do PDF
    function Header()
    {
        $this->SetFont('Arial', 'B', 12);
        $this->Cell(0, 10, utf8_decode('Relatorio de Veiculos'), 0, 1, 'C');
        $this->Ln(10);
    }

    function Footer()
    {
        $this->SetY(-15);
        $this->SetFont('Arial', 'I', 8);
        $this->Cell(0, 10, 'Page ' . $this->PageNo(), 0, 0, 'C');
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório de Veículos</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Relatório de Veículos</h1>
        <form action="relatorio.php" method="get">
            <label for="data_inicio">Data Início:</label>
            <input type="datetime-local" id="data_inicio" name="data_inicio" required>

            <label for="data_fim">Data Fim:</label>
            <input type="datetime-local" id="data_fim" name="data_fim" required>

            <label for="placa">Placa:</label>
            <select id="placa" name="placa" required>
                <option value="todos">Todos</option>
                <?php
                include 'db_config.php';
                
                $sql = "SELECT DISTINCT placa FROM veiculos";
                $result = $conn->query($sql);

                if ($result->num_rows > 0) {
                    while ($row = $result->fetch_assoc()) {
                        echo "<option value='" . htmlspecialchars($row['placa']) . "'>" . htmlspecialchars($row['placa']) . "</option>";
                    }
                }

                $conn->close();
                ?>
            </select>

            <input type="submit" value="Gerar Relatório">
        </form>
        <?php
        if (isset($_GET['data_inicio']) && isset($_GET['data_fim']) && isset($_GET['placa'])) {
            echo "Step 1: Conectando ao banco de dados...<br>";

            $conn = new mysqli($host, $user, $pass, $db);

            if ($conn->connect_error) {
                die("Connection failed: " . $conn->connect_error);
            }

            $data_inicio = $_GET['data_inicio'];
            $data_fim = $_GET['data_fim'];
            $placa = $_GET['placa'];

            $sql = "SELECT v.placa, m.nome, e.quilometragem_saida, e.data_hora_saida, e.destino, e.quilometragem_volta, e.data_hora_volta
                    FROM entradas_saidas e
                    JOIN veiculos v ON e.veiculo_id = v.id
                    JOIN motoristas m ON e.motorista_id = m.id
                    WHERE e.data_hora_saida BETWEEN '$data_inicio' AND '$data_fim'";

            if ($placa !== 'todos') {
                $sql .= " AND v.placa = '$placa'";
            }

            $sql .= " LIMIT 100";

            echo "Step 2: Executando a consulta...<br>";
            $result = $conn->query($sql);

            if ($result->num_rows > 0) {
                echo "Step 3: Inicializando PDF...<br>";

                try {
                    $pdf = new PDF('P', 'mm', 'A4');
                    echo "FPDF inicializado com sucesso.<br>";
                    $pdf->AddPage();
                    $pdf->SetFont('Arial', 'B', 10); // Reduzindo a fonte para 10
                } catch (Exception $e) {
                    echo 'Erro ao inicializar FPDF: ',  $e->getMessage(), "<br>";
                    exit();
                }

                // Cabeçalho da Tabela
                $pdf->Cell(20, 10, utf8_decode('Placa'), 1);
                $pdf->Cell(30, 10, utf8_decode('Motorista'), 1);
                $pdf->Cell(20, 10, utf8_decode('Km Saída'), 1);
                $pdf->Cell(35, 10, utf8_decode('Data/Hora Saída'), 1);
                $pdf->Cell(30, 10, utf8_decode('Destino'), 1);
                $pdf->Cell(20, 10, utf8_decode('Km Volta'), 1);
                $pdf->Cell(35, 10, utf8_decode('Data/Hora Volta'), 1);
                $pdf->Ln();

                // Dados da Tabela
                echo "Step 4: Processando registros...<br>";
                $pdf->SetFont('Arial', '', 10); // Fonte normal para os dados
                while ($row = $result->fetch_assoc()) {
                    $pdf->Cell(20, 10, utf8_decode($row['placa']), 1);
                    $pdf->Cell(30, 10, utf8_decode($row['nome']), 1);
                    $pdf->Cell(20, 10, utf8_decode($row['quilometragem_saida']), 1);
                    $pdf->Cell(35, 10, utf8_decode($row['data_hora_saida']), 1);
                    $pdf->Cell(30, 10, utf8_decode($row['destino']), 1);
                    $pdf->Cell(20, 10, utf8_decode($row['quilometragem_volta']), 1);
                    $pdf->Cell(35, 10, utf8_decode($row['data_hora_volta']), 1);
                    $pdf->Ln();
                }

                echo "Step 5: Salvando PDF...<br>";

                $filePath = '/var/www/html/veiculos/relatorio.pdf';
                $pdf->Output('F', $filePath);

                echo "<a href='relatorio.pdf'>Clique aqui para baixar o relatório</a>";
            } else {
                echo "<p>Nenhum registro encontrado para o período selecionado.</p>";
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

