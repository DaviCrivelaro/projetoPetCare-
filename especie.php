<?php
include 'conexao.php';
header('Content-Type: application/json');

try {
    $query = "SELECT idespecie, descricao FROM especie";
    $stmt = $conn->prepare($query);
    $stmt->execute();

    $result = $stmt->get_result();
    $especies = array();

    while ($row = $result->fetch_assoc()) {
        $especies[] = $row;
    }

    echo json_encode($especies);

} catch (Exception $e) {
    echo json_encode(["erro" => $e->getMessage()]);
}
?>
