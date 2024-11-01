class MovimentacaoModel {
  // final String id;
  final String Produto;
  final int Quantidade;
  final String tipoMovimentacao;
  final String status;
  final String marca;
  final String categoria;
  final String dataMovimentacao;
  // final String descricao;
  // final DateTime data;

  MovimentacaoModel({
    // required this.id,
    // required this.descricao,
    // required this.data,
    required this.dataMovimentacao,
    required this.categoria,
    required this.marca,
    required this.status,
    required this.tipoMovimentacao,
    required this.Produto,
    required this.Quantidade,
  });

  factory MovimentacaoModel.fromJson(Map<String, dynamic> json) {
    return MovimentacaoModel(
      dataMovimentacao: json['dataMovimentacao'] ?? '',
      categoria: json['categoriaData']['name'],
      marca: json['marca'] ?? '',
      status: json['status'] ?? '',
      tipoMovimentacao: json['tipoMovimentacao'],
      Quantidade: json['quantidade'] ?? 0, // Se for null, retorna 0
      Produto: json['produtoData']['name'],
      // id: json['_id'],
      // descricao: json['descricao'],
      // data: DateTime.parse(json['data']),
    );
  }
}
