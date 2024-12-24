class HistoricosModel {
  final String StatusItem;
  final String id;
  final String Item;
  final String Movimentacao;
  final int Quantidade;
  final String DataMovimentacao;
  String? Membro;
  final String Usuario;
  final String Marca;
  final String data;
  final String hora;

  HistoricosModel(
      {required this.StatusItem,
      required this.Marca,
      required this.Item,
      required this.Movimentacao,
      required this.Quantidade,
      required this.DataMovimentacao,
      required this.Usuario,
      required this.data,
      required this.hora,
      this.Membro,
      required this.id});

  factory HistoricosModel.fromJson(Map<String, dynamic> json) {
    return HistoricosModel(
      data: json['data'] ?? '', // Garantindo que o valor não seja null
      hora: json['hora'] ?? '', // Garantindo que o valor não seja null
      Marca: json['marcaData']?['name'] ?? 'Sem Marca',
      StatusItem: json['statusProduto'] ?? '***',
      id: json['_id'] ?? '', // Garantindo que o ID não seja null
      Item: json['produtoData']['name'] ??
          '', // Se 'name' for null, coloque uma string vazia
      Movimentacao: json['tipoMovimentacao'] ?? '', // Garantir valor não nulo
      Quantidade: json['quantidade'] ?? 0, // Garantindo valor numérico
      DataMovimentacao:
          json['dataMovimentacao'] as String? ?? '', // Caso a data seja nula
      Usuario: json['usuarioData']['name'] ??
          '', // Garantir que o nome do usuário não seja null
      Membro: json['membroData']?['name'] ??
          '***', // Se 'name' for null, coloca valor padrão
    );
  }
}
