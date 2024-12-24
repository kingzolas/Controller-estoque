import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/dashboard.dart';
import 'package:velocityestoque/models/marcas_model.dart';
import 'package:velocityestoque/models/member_model.dart';
import 'package:velocityestoque/models/product_model.dart';
import 'package:velocityestoque/popups/popup_UpdateInfoProduct.dart';
import 'package:velocityestoque/services/products_services.dart';

class EditProduct extends StatefulWidget {
  final Product produto;
  const EditProduct({super.key, required this.produto});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final ProductServices _productServices =
      ProductServices('ws://${Socket.apiUrl}');
  List<Map<String, dynamic>> _categories = []; // Mapeia categorias
  String? selectedCategory = null;
  List<MarcasModel> _marcas = [];
  String? selectedMarca = null;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late String isStatus = "";
  @override
  void initState() {
    super.initState();
    _loadData();
    isStatus = widget.produto.isActive ?? true ? 'Ativo' : 'Inativo';

    print(" $isStatus");
  }

  Future<void> _loadData() async {
    final fetchedMarcas = await _productServices.fetchMarcas();
    final fetchedCategories = await _productServices.fetchCategories();

    setState(() {
      _marcas = fetchedMarcas;
      _categories = fetchedCategories;
    });
  }

  Widget _containerEdit(
      {required String text,
      required Widget child,
      required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Color(0xFF889BB2),
            fontSize: 20.sp,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 0,
          ),
        ),
        SizedBox(
          height: 10.sp,
        ),
        child
      ],
    );
  }

  final Map<String, List<OverlayEntry>> activePopupsMap =
      {}; // Associa popups a cada membro

  void showCustomPopup(
    BuildContext context,
    String memberId,
  ) {
    OverlayState overlayState = Overlay.of(context)!;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        // Obtém a lista de popups para o membro específico
        List<OverlayEntry> memberPopups = activePopupsMap[memberId] ?? [];
        int index = memberPopups.indexOf(overlayEntry);
        return Positioned(
          right: 20,
          bottom: 20 + (index * 80), // Empilha verticalmente
          child: Material(
            color: Colors.transparent,
            child: PopupUpdateinfoproduct(
              nome: memberId,
              onConfirm: () {
                overlayEntry.remove();
                memberPopups.remove(overlayEntry);
                _updatePopupPositions(memberId);
              },
              onCancel: () {
                overlayEntry.remove();
                memberPopups.remove(overlayEntry);
                _updatePopupPositions(memberId);
              },
            ),
          ),
        );
      },
    );

    // Adiciona o popup ao mapa do membro correspondente
    activePopupsMap.putIfAbsent(memberId, () => []).add(overlayEntry);
    overlayState.insert(overlayEntry);

    // Fecha automaticamente após 10 segundos
    Future.delayed(Duration(seconds: 7), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        activePopupsMap[memberId]?.remove(overlayEntry);
        _updatePopupPositions(memberId);
      }
    });
  }

// Método para reposicionar os popups de um membro específico
  void _updatePopupPositions(String memberId) {
    List<OverlayEntry>? memberPopups = activePopupsMap[memberId];
    if (memberPopups != null) {
      for (var i = 0; i < memberPopups.length; i++) {
        memberPopups[i].markNeedsBuild();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool? _selectedStatus = widget.produto.isActive;
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AlertDialog(
            content: Container(
              width: 755.sp,
              height: 623.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.sp),
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Editar informações do item',
                      style: TextStyle(
                        color: Color(0xFF01244E),
                        fontSize: 40.sp,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Edite as informações do item:',
                      style: TextStyle(
                        color: Color(0xFFADBFD4),
                        fontSize: 25.sp,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // _containerEdit(height: 60.sp, text: "Nome do item"),
                          _containerEdit(
                              text: "Nome do Item",
                              child: Container(
                                width: 300.sp,
                                height: 60.sp,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFDBE1E9),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                child: Center(
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                        color: Color(0xFF889BB2),
                                        fontSize: 20.sp,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        height: 0,
                                      ),
                                      border: InputBorder.none,
                                      hintText: widget.produto.name,
                                    ),
                                  ),
                                ),
                              ),
                              context: context),
                          SizedBox(
                            height: 25.sp,
                          ),

                          _containerEdit(
                            context: context,
                            text: 'Categoria do Item',
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  widget.produto.category,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF889BB2),
                                  ),
                                ),
                                items: _categories
                                    .map((category) => DropdownMenuItem<String>(
                                          value: category['name'].toString(),
                                          child: Text(
                                            category['name'],
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              color: Color(0xFF889BB2),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                value: selectedCategory,
                                onChanged: (value) {
                                  if (value != selectedCategory) {
                                    // Verifica se o valor foi alterado
                                    print("categoria selecionada $value");
                                    setState(() {
                                      selectedCategory = value as String?;
                                    });
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 60.sp,
                                  width: 300.sp,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFDBE1E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.sp),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                  iconSize: 24.sp,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200.sp,
                                  width: 400,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: 48.sp,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.sp),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25.sp,
                          ),
                          _containerEdit(
                              text: "Marca do Item",
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    widget.produto.marca,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF889BB2),
                                    ),
                                  ),
                                  items: _marcas
                                      .map((marca) => DropdownMenuItem<String>(
                                            value: marca.name,
                                            child: Text(
                                              marca.name,
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                                color: Color(0xFF889BB2),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedMarca,
                                  onChanged: (value) {
                                    if (value != selectedMarca) {
                                      // Verifica se o valor foi alterado
                                      print("categoria selecionada $value");
                                      setState(() {
                                        selectedMarca = value as String?;
                                      });
                                    }
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 60.sp,
                                    width: 300.sp,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFDBE1E9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                    iconSize: 24.sp,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 400.sp,
                                    width: 300,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEEEEE),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 48.sp,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
                                  ),
                                ),
                              ),
                              context: context),
                          // SizedBox(
                          //   height: 25.sp,
                          // ),

                          // _containerEdit(height: 60.sp, text: "Marca do item"),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // _containerEdit(height: 180.sp, text: "Descrição"),
                          _containerEdit(
                            context: context,
                            text: "Descrição",
                            child: Container(
                              width: 300.sp,
                              height: 180.sp,
                              decoration: ShapeDecoration(
                                color: Color(0xFFDBE1E9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: TextFormField(
                                controller: _descriptionController,
                                maxLines:
                                    null, // Permite que o texto quebre em várias linhas automaticamente
                                minLines:
                                    1, // Garante pelo menos 1 linha visível
                                keyboardType: TextInputType
                                    .multiline, // Habilita texto multilinear
                                textInputAction: TextInputAction
                                    .newline, // Permite "Enter" para pular linha
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    color: Color(0xFF889BB2),
                                    fontSize: 20.sp,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  ),
                                  border: InputBorder.none,
                                  hintText: widget.produto.description,
                                  contentPadding: EdgeInsets.all(10
                                      .sp), // Para evitar que o texto toque as bordas
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 25.sp,
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status do Item',
                                  style: TextStyle(
                                    color: Color(0xFF889BB2),
                                    fontSize: 20.sp,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.sp,
                                ),
                                Container(
                                  width: 150.sp,
                                  height: 60.sp,
                                  decoration: ShapeDecoration(
                                    color: (widget.produto.isActive ?? false)
                                        ? Color(
                                            0xFF4BC57A) // Cor verde quando ativo
                                        : Color(
                                            0xFFF25252), // Cor vermelha quando inativo
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      // Ativa o dropdown ao clicar no container
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<bool>(
                                        hint: Text(
                                          isStatus,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        // value: widget.produto.isActive,
                                        isExpanded: true,
                                        items: [
                                          DropdownMenuItem(
                                            value: true,
                                            child: Text(
                                              'Ativo',
                                              style: TextStyle(
                                                color: Colors
                                                    .black, // Texto preto no dropdown
                                                fontSize: 18.sp,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: false,
                                            child: Text(
                                              'Inativo',
                                              style: TextStyle(
                                                color: Colors
                                                    .black, // Texto preto no dropdown
                                                fontSize: 18.sp,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (bool? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedStatus = newValue;
                                              widget.produto.isActive =
                                                  newValue;
                                              if (newValue) {
                                                isStatus = 'Ativo';
                                              } else {
                                                isStatus = "Inativo";
                                              }
                                            });
                                          }
                                        },
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight:
                                              200.sp, // Altura máxima do menu
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors
                                                .white, // Cor de fundo do dropdown
                                          ),
                                        ),
                                        buttonStyleData: ButtonStyleData(
                                          height: 50.sp, // Altura do botão
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16
                                                  .sp), // Ajuste de espaçamento interno
                                        ),
                                        iconStyleData: IconStyleData(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors
                                                .white, // Cor do ícone no botão
                                          ),
                                          iconSize: 24.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 60.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 20.sp,
                      ),
                      _buttonAction(
                        ontap: () async {
                          try {
                            // Exibir animação de carregamento
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        child: Lottie.asset(
                                            'lib/assets/edit_progress.json'),
                                      ),
                                      Text(
                                        'Atualizando informações...',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            // Realizar a atualização
                            await _productServices.UpdateInfoProduct(
                              _nameController.text,
                              _descriptionController.text,
                              selectedMarca.toString(),
                              selectedCategory.toString(),
                              _selectedStatus!,
                              productId: widget.produto.id,
                            );

                            // Esperar 2 segundos para exibir a animação
                            await Future.delayed(Duration(seconds: 2));

                            // Fechar o modal de carregamento
                            Navigator.of(context).pop();

                            // Fechar a tela atual
                            Navigator.pop(context);

                            // Exibir mensagem de sucesso
                            showCustomPopup(context, widget.produto.name);
                          } catch (error) {
                            // Fechar o modal de carregamento em caso de erro
                            Navigator.of(context).pop();

                            // Exibir mensagem de erro
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Erro ao atualizar as informações: $error'),
                              ),
                            );
                          }
                        },
                        text: "Salvar",
                        cor: Color(0xFF4BC57A),
                      ),
                      _buttonAction(
                        // dropdown: () {},
                        ontap: () {
                          Navigator.pop(context);
                        },
                        text: "Cancelar",
                        cor: Color(0xFFF25151),
                      ),
                      SizedBox(
                        width: 20.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

Widget _buttonAction({
  required GestureTapCallback ontap,
  required String text,
  required Color cor,
  // required GestureTapCallback dropdown
}) {
  return InkWell(
    child: Container(
      width: 160.sp,
      height: 55.sp,
      decoration: ShapeDecoration(
        color: cor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 0,
          ),
        ),
      ),
    ),
    onTap: ontap,
  );
}
