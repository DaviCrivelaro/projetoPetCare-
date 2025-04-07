class Usuario {
  String _idUsuario;
  String _nome;
  String _email;
  String _senha;

  // Construtor com parâmetros nomeados obrigatórios
  Usuario({
    required String idUsuario,
    required String nome,
    required String email,
    required String senha,
  })  : _idUsuario = idUsuario,
        _nome = nome,
        _email = email,
        _senha = senha;

  // Método para converter o objeto para Map
  Map<String, dynamic> toMap() {
    return {
      "nome": _nome,
      "email": _email,
    };
  }

  // Getters e Setters para manipular os atributos privados
  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;

  }
}