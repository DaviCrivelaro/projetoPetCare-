<?php
include 'conexao.php'; // Arquivo de conexão

// Receber os dados do Flutter (JSON)
$inputData = json_decode(file_get_contents("php://input"), true);

// Verificar se os dados foram recebidos corretamente
if (!empty($inputData)) {
    // Dados do pet
    $nome = $inputData['nome'];
    $idade = $inputData['idade'];
    $sexo = $inputData['sexo'];
    $idespecie = $inputData['idespecie'];
    $idraca = $inputData['idraca'];

    // Inserir dados na tabela pet
    $queryPet = "INSERT INTO pet (nome, idade, sexo, idespecie, idraca) 
                 VALUES ('$nome', '$idade', '$sexo', $idespecie, $idraca)";

    if (mysqli_query($conn, $queryPet)) {
        echo json_encode(["status" => "sucesso", "mensagem" => "Pet cadastrado com sucesso!"]);
    } else {
        echo json_encode(["status" => "erro", "mensagem" => "Erro ao cadastrar pet: " . mysqli_error($conn)]);
    }
} else {
    // Dados não recebidos
    echo json_encode(["status" => "erro", "mensagem" => "Nenhum dado recebido."]);
}

// Fechar a conexão
mysqli_close($conn);
?>
