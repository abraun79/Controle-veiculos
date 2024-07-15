<?php
include 'db_config.php';

$query = "SELECT placa FROM veiculos";
$result = $conn->query($query);

$options = [];
while ($row = $result->fetch_assoc()) {
    $options[] = ['value' => $row['placa'], 'text' => $row['placa']];
}

header('Content-Type: application/json');
echo json_encode($options);

$conn->close();
?>
