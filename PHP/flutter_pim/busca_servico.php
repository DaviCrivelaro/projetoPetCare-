<?php
include 'conexao.php'; // Inclui o arquivo de conexão

// Recupera os parâmetros enviados
$tutor_id = $_POST['id_tutor'];
$nome_servico = $_POST['nome_servico'];

// Verifica se os parâmetros foram enviados
if (empty($tutor_id) || empty($nome_servico)) {
    echo json_encode([
        "success" => false,
        "message" => "Parâmetros insuficientes para realizar a busca."
    ]);
    exit;
}

// Consulta SQL para buscar os serviços e as 3 clínicas mais próximas
$sql = "
SELECT 
    s.nome_servico, 
    c.razao_social, 
    c.telefone, 
    e_clinica.latitude AS latitude_clinica, 
    e_clinica.longitude AS longitude_clinica,
    (6371 * ACOS(
        COS(RADIANS(e_tutor.latitude)) * COS(RADIANS(e_clinica.latitude)) *
        COS(RADIANS(e_clinica.longitude) - RADIANS(e_tutor.longitude)) +
        SIN(RADIANS(e_tutor.latitude)) * SIN(RADIANS(e_clinica.latitude))
    )) AS distancia
FROM 
    servico s
JOIN 
    clinica c ON s.idclinica = c.idclinica
JOIN 
    endereco e_clinica ON c.idEndereco = e_clinica.idEndereco
JOIN 
    tutor t ON t.idTutor = ?
JOIN 
    endereco e_tutor ON t.idEndereco = e_tutor.idEndereco
WHERE 
    s.nome_servico LIKE ?
ORDER BY 
    distancia ASC
LIMIT 3;
";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Erro na preparação da consulta SQL."
    ]);
    exit;
}

$nome_servico_param = '%' . $nome_servico . '%';
$stmt->bind_param("is", $tutor_id, $nome_servico_param);

if (!$stmt->execute()) {
    echo json_encode([
        "success" => false,
        "message" => "Erro ao executar a consulta SQL."
    ]);
    $stmt->close();
    $conn->close();
    exit;
}

$result = $stmt->get_result();
$data = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Arredonda a distância para 2 casas decimais
        $row['distancia'] = number_format((float)$row['distancia'], 2, ',', '') . ' Km';
        $data[] = $row;
    }
}

$stmt->close();
$conn->close();

echo json_encode([
    "success" => true,
    "data" => $data
]);
?>
