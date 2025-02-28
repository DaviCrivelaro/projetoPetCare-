<?php

$servername = "localhost"; // ou o IP do seu servidor
//$port = 3306; // A porta do MySQL, se estiver usando MySQL
$username = "root"; // substitua pelo seu usuário do MySQL
$password = ""; // substitua pela sua senha do MySQL
$dbname = "flutter_pim"; // substitua pelo nome do seu banco de dados

// Criando a conexão
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificando a conexão
if ($conn->connect_error) {
    die("Erro na conexão: " . $conn->connect_error);
}
?>
