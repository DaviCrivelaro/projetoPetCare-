<?php

include 'conexao.php'; // Inclua a função de conexão com o banco de dados

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php';

// Função para enviar resposta JSON
function sendResponse($status, $message) {
    echo json_encode(['status' => $status, 'message' => $message]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    // Verifica se o e-mail foi enviado
    if (!isset($data['email'])) {
        sendResponse('error', 'E-mail não fornecido.');
    }
    
    $email = $data['email'];

    // Verifica se o e-mail está registrado
    $query = "SELECT id, nome FROM usuarios WHERE email = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();
    
    if ($stmt->num_rows > 0) {
        $stmt->bind_result($id, $nome);
        $stmt->fetch();

        // Gerar um token único para o reset de senha
        $token = bin2hex(random_bytes(50));
        $expiry = date("Y-m-d H:i:s", strtotime("+1 hour"));

        // Atualizar o banco com o token e a data de expiração
        $query = "UPDATE usuarios SET reset_token = ?, reset_token_expiry = ? WHERE email = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("sss", $token, $expiry, $email);

        if ($stmt->execute()) {
            // Enviar e-mail (por enquanto simula o envio)
           // $resetLink = "http://192.168.0.83/flutter_pim/redefinir_senha.php?token=" . $token;
            $resetLink = "http://192.168.19.191/flutter_pim/redefinir_senha.php?reset_token=" . urlencode($token);

            // Simular o envio de e-mail (aqui você pode integrar com SendGrid ou outro serviço de e-mail)
            // Por exemplo: 
             sendResetEmail($email, $nome, $resetLink);
             
            sendResponse('success', 'Instruções para redefinir a senha foram enviadas para o seu e-mail.');
        } else {
            sendResponse('error', 'Erro ao gerar o token de reset.');
        }
    } else {
        sendResponse('error', 'E-mail não registrado.');
    }
}

// Função para enviar o e-mail de reset de senha via SMTP
function sendResetEmail($email, $name, $resetLink) {
    $mail = new PHPMailer(true);

    try {
        // Configurações do servidor SMTP
        $mail->isSMTP();                                      // Ativa o envio via SMTP
        $mail->Host = 'smtpout.secureserver.net';                  // Servidor SMTP do GoDaddy
        $mail->SMTPAuth = true;                                 // Habilita autenticação SMTP
        $mail->Username = 'clever@clevermatos.com.br';          // Seu e-mail do GoDaddy
        $mail->Password = 'Lumathi1806';                 // Senha do e-mail
        //$mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;     // Habilita criptografia TLS
        //$mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $mail->Port = 587;                                     // Porta SMTP do GoDaddy (587 para TLS)

        // Remetente e destinatário
        $mail->setFrom('clever@clevermatos.com.br', 'Suporte');   // Seu e-mail
        $mail->addAddress($email, $name);                       // E-mail do destinatário

        // Assunto e corpo do e-mail
        $mail->isHTML(true);  // Define que o e-mail será enviado em HTML
        $mail->Subject = 'Redefinir sua Senha';
        $mail->Body = "Clique no link abaixo para resetar sua senha:<br><a href='$resetLink'>$resetLink</a>";
        

        // Enviar o e-mail
        if ($mail->send()){
            echo 'email enviado com sucesso!';
        }else{
            echo 'email não enviado!';
        }
    
        return true;
    } catch (Exception $e) {
        // Se ocorrer algum erro, loga a mensagem de erro
        error_log("Erro ao enviar o e-mail: " . $mail->ErrorInfo);
        return false;
    }
}
?>
