import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:velocityestoque/models/movimentacao_model.dart';
import 'package:http/http.dart' as http;
import '../models/auth_provider.dart';
import '../models/member_model.dart';
import '../models/product_model.dart';
import '../popups/popop_return.dart';
import '../services/products_services.dart';
import 'alert_dialog_erro_devolucao.dart';

class ReturnItensMember extends StatefulWidget {
  final MovimentacaoModel produto;
  final MemberModel membro;
  const ReturnItensMember(
      {super.key, required this.produto, required this.membro});

  @override
  State<ReturnItensMember> createState() => _ReturnItensMemberState();
}

class _ReturnItensMemberState extends State<ReturnItensMember> {
  List<Product> products = [];
  final TextEditingController _quantityController =
      TextEditingController(text: '0');
  final TextEditingController _descriptionController =
      TextEditingController(); // Controlador para o campo de descrição
  String _selectedStatus = 'Novo';
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');

  @override
  void initState() {
    super.initState();
    // _loadData();
  }

  final Map<String, List<OverlayEntry>> activePopupsMap =
      {}; // Associa popups a cada membro

  void showCustomPopup(BuildContext context, String memberId) {
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
            child: PopUpReturn(
              nome: widget.membro.name,
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
    Future.delayed(Duration(seconds: 5), () {
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

  // Future<void> _loadData() async {
  //   final int quantity = int.tryParse(_quantityController.text) ?? 0;
  //   final String descricao = _descriptionController.text ?? '';
  //   final authProvider = Provider.of<AuthProvider>(context);

  //   final devolution = _productServices.returnProduct(widget.produto.produtoId,
  //       quantity, authProvider.userId.toString(), descricao);
  // }

  void _incrementQuantity() {
    setState(() {
      int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
      currentQuantity++;
      _quantityController.text = currentQuantity.toString();
    });
  }

  void _decrementQuantity() {
    setState(() {
      int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
      if (currentQuantity > 0) {
        currentQuantity--;
      }
      _quantityController.text = currentQuantity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int quantidadeTotal =
        widget.produto.Quantidade - widget.produto.quantidadeDevolvidaAcumulada;
    final authProvider = Provider.of<AuthProvider>(context);
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AlertDialog(
          content: Container(
            width: 1030.sp,
            height: 550.sp,
            child: Padding(
              padding: EdgeInsets.only(left: 50, right: 50),
              child: Column(
                children: [
                  // Título e botão de devolução
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        // color: Colors.red,
                        height: 50.sp,
                        width: 700.sp,
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                            text: 'Devolver ${widget.produto.Produto}',
                            style: TextStyle(
                              color: Color(0xFF01244E),
                              fontSize: 40.sp,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                        ])),
                      ),
                      InkWell(
                        onTap: () async {
                          final descricao = _descriptionController.text.trim();

                          if (descricao.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Por favor, preencha o campo de descrição.'),
                              ),
                            );

                            return;
                          }

                          final quantity =
                              int.tryParse(_quantityController.text) ?? 0;

                          http.Response response =
                              await _productServices.returnProduct(
                                  quantity,
                                  authProvider.userId.toString(),
                                  descricao,
                                  widget.membro.id,
                                  widget.produto.idMovimentacao,
                                  _selectedStatus);
                          // print(response.body);
                          print(response.statusCode);

                          if (response.statusCode == 401 ||
                              response.statusCode == 400 ||
                              response.statusCode == 500) {
                            showDialog(
                                barrierColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialogErroDevolucao(
                                    ontapFalse: () {
                                      Navigator.pop(context);
                                      Navigator.pop(
                                          context); // Fecha a rota atual
                                    },
                                    ontapTrue: () {
                                      Navigator.pop(context);
                                    },
                                    quantidade: quantidadeTotal.toString(),
                                    name: widget.produto.Produto,
                                  );
                                });
                          }
                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            showCustomPopup(context, widget.membro.id);
                            Navigator.pop(context);
                          }

                          // print({
                          //   'quantity': quantity,
                          //   'userId': authProvider.userId.toString(),
                          //   'descricao': descricao,
                          //   'membroId': widget.membro.id,
                          //   'idMovimentacao': widget.produto.idMovimentacao,
                          //   'status': _selectedStatus
                          // });
                        },
                        child: Container(
                          width: 160.sp,
                          height: 50.sp,
                          decoration: ShapeDecoration(
                            color: Color(0xFFF25151),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Devolver',
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
                      ),
                    ],
                  ),
                  SizedBox(height: 30.sp),

                  // Quantidade
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Quantidade: ',
                            style: TextStyle(
                              color: Color(0xFF889BB2),
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Informe a quantidade de item que está sendo devolvido',
                            style: TextStyle(
                              color: Color(0xFFADBFD4),
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 60.sp,
                      width: 150.sp,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _quantityController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: Color(0xFF01244E),
                                fontSize: 25,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) {
                                setState(() {
                                  int currentQuantity =
                                      int.tryParse(value) ?? 0;
                                  _quantityController.text =
                                      currentQuantity.toString();
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 30.sp),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: _incrementQuantity,
                                child: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  decoration: BoxDecoration(
                                    color: Color(0xffDBE1E9),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Icon(Icons.keyboard_arrow_up,
                                      size: 20.sp),
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              GestureDetector(
                                onTap: _decrementQuantity,
                                child: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  decoration: BoxDecoration(
                                    color: Color(0xffDBE1E9),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Icon(Icons.keyboard_arrow_down_rounded,
                                      size: 20.sp),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.sp),

                  // Status
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Status: ',
                            style: TextStyle(
                              color: Color(0xFF889BB2),
                              fontSize: 20.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Informe o status do item que está sendo devolvido',
                            style: TextStyle(
                              color: Color(0xFFADBFD4),
                              fontSize: 20.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w300,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 60.sp,
                      width: 200.sp,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          items: <String>['Novo', 'Usado', 'Danificado']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.adjust,
                                    color: value == 'Novo'
                                        ? Color(0xff4CC67A)
                                        : value == 'Usado'
                                            ? Color(0xffFFA726)
                                            : Color(0xffF44336),
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.sp),
                                  Text(
                                    value,
                                    style: TextStyle(
                                      color: value == 'Novo'
                                          ? Color(0xFF4BC57A)
                                          : value == 'Usado'
                                              ? Color(0xFFFFA726)
                                              : Color(0xFFF44336),
                                      fontSize: 19.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStatus = newValue!;
                            });
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            size: 30.sp,
                            color: Color(0xff889BB2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.sp),

                  // Descrição
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Descrição: ',
                            style: TextStyle(
                              color: Color(0xFF889BB2),
                              fontSize: 20.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Informe as condições em que o item está sendo devolvido',
                            style: TextStyle(
                              color: Color(0xFFADBFD4),
                              fontSize: 20.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w300,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 160.sp,
                      // width: 800.sp,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.sp),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: TextStyle(
                          color: Color(0xFF01244E),
                          fontSize: 18.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Digite a descrição aqui...',
                          hintStyle: TextStyle(
                            color: Color(0xFFADBFD4),
                            fontSize: 18.sp,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
