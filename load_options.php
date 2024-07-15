<?php
include 'db_config.php';

// Receber dados do fetch
$data = json_decode(file_get_contents('php://input'), true);
$query = $data['query'];
$valueField = $data['valueField'];

$result = $conn->query($query);

$options = [];
while ($row = $result->fetch_assoc()) {
    $options[] = ['value' => $row[$valueField], 'text' => $row[$valueField]];
}

header('Content-Type: application/json');
echo json_encode($options);

$conn->close();
?>

