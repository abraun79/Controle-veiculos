<?php
include 'db_config.php';

$query = "SELECT nome FROM motoristas";
$result = $conn->query($query);

$options = [];
while ($row = $result->fetch_assoc()) {
    $options[] = ['value' => $row['nome'], 'text' => $row['nome']];
}

header('Content-Type: application/json');
echo json_encode($options);

$conn->close();
?>

