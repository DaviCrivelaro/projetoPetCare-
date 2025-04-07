<?php

include 'conexao.php'; // Arquivo de conexão

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Recebe os dados do Flutter
    $nome = $_POST['nome'];
    $email = $_POST['email'];
    $senha = $_POST['senha'];

    // Insere os dados na tabela 'usuarios'
    $sql = "INSERT INTO usuarios (nome, email, senha) VALUES ('$nome', '$email', '$senha')";
    
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => $conn->error]);
    }
}

$conn->close();
?>
