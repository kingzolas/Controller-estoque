class MovimentacaoModel {
  // final String id;
  final String Produto;
  final int Quantidade;
  final String tipoMovimentacao;
  final String status;
  final String marca;
  final String categoria;
  final String dataMovimentacao;
  final String idMovimentacao;
  final String produtoId;
  final int quantidadeDevolvidaAcumulada;
  final String statusMovimentacao;
  // final String descricao;
  // final DateTime data;

  MovimentacaoModel(
      {
      // required this.id,
      // required this.descricao,
      // required this.data,
      required this.statusMovimentacao,
      required this.produtoId,
      required this.idMovimentacao,
      required this.dataMovimentacao,
      required this.categoria,
      required this.marca,
      required this.status,
      required this.tipoMovimentacao,
      required this.Produto,
      required this.Quantidade,
      required this.quantidadeDevolvidaAcumulada});

  factory MovimentacaoModel.fromJson(Map<String, dynamic> json) {
    return MovimentacaoModel(
      statusMovimentacao: json['statusMovimentacao'] ?? 'Em uso',
      quantidadeDevolvidaAcumulada: json['quantidadeDevolvidaAcumulada'] ?? 0,
      idMovimentacao: json['_id'] ?? 0,
      dataMovimentacao: json['dataMovimentacao'] ?? '',
      categoria: json['categoriaData']['name'],
      marca: json['marca'] ?? '',
      status: json['statusProduto'] ?? '',
      tipoMovimentacao: json['tipoMovimentacao'],
      Quantidade: json['quantidade'] ?? 0, // Se for null, retorna 0
      Produto: json['produtoData']['name'],
      produtoId: json['produtoData']['_id'] ?? '',
      // id: json['_id'],
      // descricao: json['descricao'],
      // data: DateTime.parse(json['data']),
    );
  }
}
