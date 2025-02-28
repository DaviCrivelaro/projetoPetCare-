<?php
include 'conexao.php'; // Arquivo de conexão

// Verificar se os dados foram recebidos corretamente via POST
if (isset($_POST['nome_servico']) && isset($_POST['idclinica'])) {
    // Dados do serviço
    $nomeservico = $_POST['nome_servico'];
    $idclinica = $_POST['idclinica']; // Recebendo o ID da clínica

    // Usar prepared statements para evitar SQL injection
    $stmt = $conn->prepare("INSERT INTO servico (nome_servico, idclinica) VALUES (?, ?)");
    $stmt->bind_param("si", $nomeservico, $idclinica); // 's' para string, 'i' para inteiro

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Serviço cadastrado com sucesso!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Erro ao cadastrar serviço: " . $stmt->error]);
    }

    // Fechar o statement
    $stmt->close();
} else {
    // Dados não recebidos
    echo json_encode(["success" => false, "message" => "Nenhum dado recebido."]);
}

// Fechar a conexão
$conn->close();
?>
