import 'package:get/get.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  // Produto selecionado inicializado com um produto vazio ou valores padrão
  var selectedProduct = Product(
    marca: 'Sem marca',
    id: '',
    name: 'Produto Desconhecido',
    description: 'Sem Descrição',
    category: 'Sem Categoria',
    quantity: 0,
    unit: 'Unidade Desconhecida',
    createdAt: DateTime.now(),
    status: 'Indisponível',
    newQuantity: 0,
    usedQuantity: 0,
    damagedQuantity: 0,
    totalQuantity: 0,
  ).obs;

  // Atualiza o produto selecionado usando o mapa de dados do JSON
  void setProduct(Map<String, dynamic> productData) {
    selectedProduct.value = Product.fromJson(productData);
  }
}
