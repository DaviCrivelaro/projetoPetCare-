<?php
// Conexão com o banco de dados
include 'conexao.php';

// Receber os dados do Flutter (JSON)
$inputData = json_decode(file_get_contents("php://input"), true);

// Verificar se os dados foram recebidos corretamente
if (!empty($inputData)) {
    // Dados do endereço
    $rua = $inputData['logradouro'];
    $numero = $inputData['numero'];
    $complemento = $inputData['complemento'];
    $bairro = $inputData['bairro'];
    $cidade = $inputData['cidade'];
    $estado = $inputData['estado'];
    $cep = $inputData['cep'];
    $latitude = $inputData['latitude'];
    $longitude = $inputData['longitude'];

    // Dados do tutor
    $nome = $inputData['nome'];
    $email = $inputData['email'];
    $telefone = $inputData['telefone'];

    // Inserir dados na tabela endereco
    $queryEndereco = "INSERT INTO endereco (logradouro, numero, complemento, bairro, cidade, estado, cep, latitude, longitude) 
                      VALUES ('$rua', '$numero', '$complemento', '$bairro', '$cidade', '$estado', '$cep', $latitude, $longitude)";

    if (mysqli_query($conn, $queryEndereco)) {
        // Pegar o último ID inserido na tabela endereco
        $idEndereco = mysqli_insert_id($conn);

        // Inserir dados na tabela tutor com o idEndereco
        $queryTutor = "INSERT INTO tutor (nome, email, telefone, idendereco) 
                       VALUES ('$nome', '$email', '$telefone', '$idEndereco')";

        if (mysqli_query($conn, $queryTutor)) {
            // Retornar uma mensagem de sucesso
            echo json_encode(["status" => "sucesso", "mensagem" => "Tutor cadastrado com sucesso!"]);
        } else {
            // Erro ao inserir tutor
            echo json_encode(["status" => "erro", "mensagem" => "Erro ao cadastrar tutor: " . mysqli_error($conn)]);
        }
    } else {
        // Erro ao inserir endereço
        echo json_encode(["status" => "erro", "mensagem" => "Erro ao cadastrar endereço: " . mysqli_error($conn)]);
    }
} else {
    // Dados não recebidos
    echo json_encode(["status" => "erro", "mensagem" => "Nenhum dado recebido."]);
}

// Fechar a conexão
mysqli_close($conn);
?>
