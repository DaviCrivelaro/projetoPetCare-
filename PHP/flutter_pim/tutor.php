<?php
header('Content-Type: application/json');
include 'conexao.php'; // Inclui o arquivo de conexão

$tutorId = $_GET['tutor_id']; // Ou obter de outra forma

$sql = "SELECT * FROM tutor WHERE idtutor = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $tutorId);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $tutor = $result->fetch_assoc();
    echo json_encode($tutor);
} else {
    echo json_encode(['error' => 'Tutor não encontrado.']);
}

$stmt->close();
$conn->close();
?>
