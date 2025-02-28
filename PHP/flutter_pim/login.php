<?php
header('Content-Type: application/json');

include 'conexao.php'; // Arquivo de conexão

// Recebe dados do POST
$data = json_decode(file_get_contents("php://input"));

if ($data && isset($data->email) && isset($data->senha)) {
    $email = $data->email;
    $senha = $data->senha;

    // Prepara a consulta SQL
    $stmt = $conn->prepare("SELECT * FROM usuarios WHERE email = ? AND senha = ?");
    $stmt->bind_param("ss", $email, $senha);

    // Executa a consulta
    $stmt->execute();
    $result = $stmt->get_result();

    // Verifica se encontrou um usuário
    if ($result->num_rows > 0) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => "Email ou senha incorretos"]);
    }

    // Fecha a conexão
    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Dados de login inválidos"]);
}
?>
