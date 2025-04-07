const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// Configuração de CORS
app.use(cors());
app.use(bodyParser.json());

// Configuração do banco de dados MySQL
const db = mysql.createConnection({
  host: 'seu-servidor-mysql.com',
  user: 'seu-usuario',
  password: 'sua-senha',
  database: 'nome-do-banco',
});

db.connect((err) => {
  if (err) {
    console.error('Erro ao conectar no MySQL:', err);
  } else {
    console.log('Conectado ao banco de dados MySQL');
  }
});

// Endpoint para login
app.post('/login', (req, res) => {
  const { email, senha } = req.body;

  const query = 'SELECT * FROM usuarios WHERE email = ? AND senha = ?';
  db.query(query, [email, senha], (err, results) => {
    if (err) {
      res.status(500).json({ success: false, message: 'Erro ao acessar o banco de dados' });
    } else {
      if (results.length > 0) {
        res.json({ success: true, message: 'Login bem-sucedido!' });
      } else {
        res.json({ success: false, message: 'Credenciais inválidas' });
      }
    }
  });
});

// Iniciar o servidor
app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
