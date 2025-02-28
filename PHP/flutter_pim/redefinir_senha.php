<?php
include 'conexao.php'; // Conexão com o banco de dados

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Verifique se o token está presente na URL
    if (isset($_GET['reset_token']) && !empty($_GET['reset_token'])) {
        $token = $_GET['reset_token'];

        // Verificar token e sua validade no banco de dados
        $query = "SELECT id FROM usuarios WHERE reset_token = ? AND reset_token_expiry > NOW()";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("s", $token);
        $stmt->execute();
        $stmt->store_result();

        if ($stmt->num_rows > 0) {
            // Token válido, exibe o formulário de redefinição de senha
            echo '
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Redefinir Senha</title>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        margin: 0;
                        padding: 0;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        min-height: 100vh;
                        background-color: #f4f4f4;
                    }
                    .container {
                        width: 100%;
                        max-width: 400px;
                        background: #fff;
                        padding: 20px;
                        border-radius: 8px;
                        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                    }
                    h1 {
                        font-size: 1.5em;
                        margin-bottom: 20px;
                        text-align: center;
                    }
                    input[type="password"], input[type="submit"] {
                        width: 100%;
                        padding: 10px;
                        margin: 10px 0;
                        border: 1px solid #ccc;
                        border-radius: 4px;
                    }
                    input[type="submit"] {
                        background-color: #1ebbd8;
                        color: white;
                        font-weight: bold;
                        cursor: pointer;
                    }
                    input[type="submit"]:hover {
                        background-color: #17a2b8;
                    }
                    .error {
                        color: red;
                        text-align: center;
                        margin-bottom: 10px;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Redefinir Senha</h1>
                    <form method="POST">
                        <input type="password" name="senha" placeholder="Nova Senha" required>
                        <input type="hidden" name="reset_token" value="' . htmlspecialchars($token) . '">
                        <input type="submit" value="Redefinir Senha">
                    </form>
                </div>
            </body>
            </html>';
        } else {
            echo "Token inválido ou expirado.";
        }
    } else {
        echo "Token não foi passado na URL.";
    }
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Verifique se o token e a senha foram recebidos
    if (isset($_POST['senha']) && isset($_POST['reset_token'])) {
        $senha = $_POST['senha'];
        $token = $_POST['reset_token'];

        if (empty($senha) || empty($token)) {
            echo "Dados inválidos.";
            exit;
        }

        // Atualizar a senha no banco de dados e limpar o token
        $query = "UPDATE usuarios SET senha = ?, reset_token = NULL, reset_token_expiry = NULL WHERE reset_token = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ss", $param_senha, $param_token);

        //$stmt->bind_param("ss", password_hash($senha, PASSWORD_DEFAULT), $token);

        if ($stmt->execute()) {
            echo '
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Senha Atualizada</title>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        text-align: center;
                        padding: 20px;
                        background-color: #f4f4f4;
                    }
                    .container {
                        max-width: 400px;
                        margin: auto;
                        background: #fff;
                        padding: 20px;
                        border-radius: 8px;
                        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                    }
                    h1 {
                        color: #1ebbd8;
                    }
                    p {
                        font-size: 16px;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Senha Atualizada</h1>
                    <p>Sua senha foi redefinida com sucesso.</p>
                </div>
            </body>
            </html>';
        } else {
            echo "Erro ao atualizar a senha.";
        }
    } else {
        echo "Token inválido ou dados incompletos.";
    }
}
?>
