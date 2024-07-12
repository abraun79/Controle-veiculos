<?php
$host = 'localhost';
$db = 'controle_veiculos';
$user = 'teste';
$pass = 'test@12345';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Falha na conexão com o banco de dados: " . $conn->connect_error);
}

$conn->set_charset("utf8");
?>
