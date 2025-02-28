<?php
include 'conexao.php'; // Arquivo de conexão

// Consultar as clínicas
$sql = "SELECT idclinica, razao_social FROM clinica"; // Altere conforme o nome da tabela
$result = $conn->query($sql);

$clinicas = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $clinicas[] = $row; // Adiciona cada clínica ao array
    }
}

echo json_encode($clinicas);

// Fechar a conexão
$conn->close();
?>
