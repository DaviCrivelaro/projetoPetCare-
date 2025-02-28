<?php
include 'conexao.php';
header('Content-Type: application/json');

try {
    $query = "SELECT idraca, raca FROM raca WHERE idespecie = ?";
    $stmt = $conn->prepare($query);
    
    // Verifique se o parâmetro idespecie foi passado corretamente
    $data = json_decode(file_get_contents('php://input'), true);
    if (isset($data['idespecie'])) {
        $idespecie = $data['idespecie'];
    } else {
        throw new Exception("idespecie não fornecido");
    }

    // Associa o valor de idespecie à consulta preparada
    $stmt->bind_param("i", $idespecie);
    $stmt->execute();

    $result = $stmt->get_result();
    $racas = array();

    while ($row = $result->fetch_assoc()) {
        $racas[] = $row;
    }

    echo json_encode($racas);

} catch (Exception $e) {
    echo json_encode(["erro" => $e->getMessage()]);
}
?>
