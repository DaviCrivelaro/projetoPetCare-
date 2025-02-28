<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php';

$mail = new PHPMailer(true);

try {
    // Configurações do servidor SMTP
    $mail->isSMTP();
    $mail->Host = 'smtpout.secureserver.net';
    $mail->SMTPAuth = true;
    $mail->Username = 'clever@clevermatos.com.br';
    $mail->Password = 'Lumathi1806';
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    // Define o remetente
    $mail->setFrom('clever@clevermatos.com.br', 'Sua Empresa ou Nome');
    // Define o destinatário
    $mail->addAddress('cleversont@yahoo.com.br', 'Nome Destinatario');

    // Conteúdo da mensagem
    $mail->isHTML(true);
    $mail->Subject = 'Teste Envio de Email';
    $mail->Body    = 'Este é o corpo da mensagem <b>Olá!</b>';
    $mail->AltBody = 'Este é o corpo da mensagem para clientes de e-mail que não reconhecem HTML';

    // Enviar
    $mail->send();
    echo 'A mensagem foi enviada!';
} catch (Exception $e) {
    // Logar o erro ao enviar o e-mail
    error_log("Erro ao enviar e-mail: {$mail->ErrorInfo}");
    echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
}
?>
