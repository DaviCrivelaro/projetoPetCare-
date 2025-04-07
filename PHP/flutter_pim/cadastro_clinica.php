<?php
//header('Content-Type: application/json');
include 'conexao.php';

// Receber os dados JSON da requisição
$inputData = json_decode(file_get_contents("php://input"), true);

// Verificar se os dados necessários estão presentes
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

    // Dados do clinica
    $RazaoSocial = $inputData['razao_social'];
    $cnpj = $inputData['cnpj'];
    $telefone = $inputData['telefone'];
    $idEndereco = $inputdata['idEndereco'];

    

    // Inserir dados na tabela endereço
    $queryEndereco = "INSERT INTO endereco (logradouro, numero, complemento, bairro, cidade, estado, cep, latitude, longitude) 
    VALUES ('$rua', '$numero', '$complemento', '$bairro', '$cidade', '$estado', '$cep', $latitude, $longitude)";

    if (mysqli_query($conn, $queryEndereco)) {
        // Pegar o último ID inserido na tabela endereco
        $idEndereco = mysqli_insert_id($conn);

        // Inserir dados na tabela clínica com o idEndereco
        $queryClinica = "INSERT INTO clinica (razao_social, cnpj, telefone, idEndereco) 
        VALUES ('$RazaoSocial', '$cnpj', '$telefone', '$idEndereco')";

        if (mysqli_query($conn, $queryClinica)) {
            // Resposta de sucesso para a clínica

            echo json_encode(["status" => "sucesso", "mensagem" => "Clínica cadastrada com sucesso!"]);
        } else {
            // Erro ao cadastrar a clínica
            echo json_encode(["status" => "erro", "mensagem" => "Erro ao cadastrar a clínica: " . mysqli_error($conn)]);
        }
    } else {
        // Erro ao cadastrar o endereço
        echo json.encode(["status" => "erro", "mensagem" => "Erro ao cadastrar endereço: " . mysqli_error($conn)]);
    }

} else {
    // Dados incompletos
    echo json.encode(["status" => "erro", "mensagem" => "Dados incompletos."]);
}

// Fechar a conexão
mysqli_close($conn);


?>
