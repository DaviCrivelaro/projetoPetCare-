<?php
header('Content-Type: application/json');
include 'conexao.php';

$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['logradouro']) && isset($data['numero']) && isset($data['bairro']) && isset($data['complemento']) && isset($data['cidade']) && isset($data['estado']) && isset($data['cep'])) {
    $rua = $data['logradouro'];
    $numero = $data['numero'];
    $bairro = $data['bairro'];
    $complemento = $data['complemento'];
    $cidade = $data['cidade'];
    $estado = $data['estado'];
    $cep = $data['cep'];

    $query = "INSERT INTO endereco (logradouro, numero, bairro, complemento, cidade, estado, cep) VALUES ('$rua', '$numero', '$bairro', '$complemento', '$cidade', '$estado', '$cep')";

    if (mysqli_query($conn, $query)) {
        $idEndereco = mysqli_insert_id($conn);
        echo json_encode(['idEndereco' => $idEndereco]);
    } else {
        echo json_encode(['erro' => 'Erro ao inserir o endereço: ' . mysqli_error($conn)]);
    }
} else {
    echo json_encode(['erro' => 'Dados de endereço incompletos.']);
}

mysqli_close($conn);
?>
