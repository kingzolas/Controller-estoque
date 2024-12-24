import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/models/historicos_model.dart';
import 'package:velocityestoque/models/marcas_model.dart';
import 'package:velocityestoque/models/member_model.dart';
import 'package:velocityestoque/models/user_model.dart';
import 'package:velocityestoque/models/users_model.dart';
import 'package:velocityestoque/widgets/historic_table.dart';

import '../services/products_services.dart';

class HistoricProducts extends StatefulWidget {
  const HistoricProducts({super.key});

  @override
  State<HistoricProducts> createState() => _HistoricProductsState();
}

class _HistoricProductsState extends State<HistoricProducts> {
  final ProductServices _productServices =
      ProductServices('ws://${Socket.apiUrl}');

  List<HistoricosModel> _historico = [];
  List<HistoricosModel> filteredItens = [];
  List<HistoricProducts> filteredHistoricos = [];
  List<MarcasModel> _marcas = [];
  List<MemberModel> _members = [];
  List<UsersModel> _users = [];
  String? selectedMarca = null;
  String? selectedUser = null;
  String? selectedMember = null;
  bool hasActiveFilters = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Carregar usuários
      final users = await _productServices.fetchUsers();
      setState(() {
        _users = users;
      });

      // Carregar membros
      final members = await _productServices.fetchMembers();
      setState(() {
        _members = members;
      });

      // Carregar marcas
      final marcas = await _productServices.fetchMarcas();
      setState(() {
        _marcas = marcas;
      });

      // Carregar histórico
      final historico = await _productServices.fetchHitoricosMovimentacao();
      setState(() {
        _historico = historico;
      });

      // Aplicar filtros
      filterItens();
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterItens() {
    setState(() {
      hasActiveFilters = selectedUser != null ||
          selectedMember != null ||
          selectedMarca != null;

      if (!hasActiveFilters) {
        filteredItens = List.from(_historico);
      } else {
        filteredItens = _historico.where((product) {
          final matchesMembers =
              selectedMember == null || product.Membro == selectedMember;
          final matchesUsuarios =
              selectedUser == null || product.Usuario == selectedUser;
          final matchesMarcas =
              selectedMarca == null || product.Marca == selectedMarca;
          return matchesMembers && matchesUsuarios && matchesMarcas;
        }).toList();
      }
    });
  }

  void clearFilters() {
    setState(() {
      selectedMarca = null;
      selectedUser = null;
      selectedMember = null;
      hasActiveFilters = false;
      filteredItens = List.from(_historico);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Histórico de Movimentações',
                    style: TextStyle(
                      color: Color(0xFF01244E),
                      fontSize: 47.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    SizedBox(
                                      width: 5.sp,
                                    ),
                                    Icon(
                                      PhosphorIcons.faders_horizontal_bold,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    Text(
                                      'Filtrar Marca',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23.sp,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                items: _marcas
                                    .map((marca) => DropdownMenuItem<String>(
                                          value: marca.name,
                                          child: Text(
                                            marca.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 23.sp,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
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
                                    filterItens(); // Chama a função de filtro após a mudança
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50.sp,
                                  width: 260.sp,
                                  decoration: BoxDecoration(
                                    color: Color(0xff01244E),
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
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Color(0xff01244E),
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
                            SizedBox(
                              width: 20.sp,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    SizedBox(
                                      width: 5.sp,
                                    ),
                                    Icon(
                                      PhosphorIcons.users_three_fill,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    Text(
                                      'Filtrar Membro',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23.sp,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                items: _members
                                    .map((member) => DropdownMenuItem<String>(
                                          value: member.name,
                                          child: Text(
                                            member.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 23.sp,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                value: selectedMember,
                                onChanged: (value) {
                                  if (value != selectedMember) {
                                    // Verifica se o valor foi alterado
                                    print("categoria selecionada $value");
                                    setState(() {
                                      selectedMember = value as String?;
                                    });
                                    filterItens(); // Chama a função de filtro após a mudança
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50.sp,
                                  width: 260.sp,
                                  decoration: BoxDecoration(
                                    color: Color(0xff01244E),
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
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Color(0xff01244E),
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
                            SizedBox(
                              width: 20.sp,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    SizedBox(
                                      width: 5.sp,
                                    ),
                                    Icon(
                                      PhosphorIcons.users_three_fill,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    Text(
                                      'Filtrar Usuário',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23.sp,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                items: _users
                                    .map((user) => DropdownMenuItem<String>(
                                          value: user.name,
                                          child: Text(
                                            user.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 23.sp,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                value: selectedUser,
                                onChanged: (value) {
                                  if (value != selectedUser) {
                                    // Verifica se o valor foi alterado
                                    print("categoria selecionada $value");
                                    setState(() {
                                      selectedUser = value as String?;
                                    });
                                    filterItens(); // Chama a função de filtro após a mudança
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50.sp,
                                  width: 260.sp,
                                  decoration: BoxDecoration(
                                    color: Color(0xff01244E),
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
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Color(0xff01244E),
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
                            SizedBox(
                              width: 20.sp,
                            ),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                height: 50.sp,
                                width: 200.sp,
                                decoration: BoxDecoration(
                                  color: Color(0xff01244E),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 15.sp,
                                    ),
                                    Icon(
                                      PhosphorIcons.calendar_fill,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    Text(
                                      "Filtrar data",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23.sp,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasActiveFilters)
                        InkWell(
                          onTap: clearFilters, // Limpa os filtros ao clicar
                          child: Container(
                            height: 50,
                            width: 220,
                            decoration: BoxDecoration(
                              color: Color(0xffFEB100),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                Text(
                                  'Remover filtros',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  color: Color(0xffF0F4F8),
                  width: double.infinity,
                  height: 750.sp,
                  child: Column(
                    children: [
                      Container(
                        height: 70.sp,
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Container(
                              height: 70.sp,
                              width: 60.sp,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: Colors.white, strokeAlign: 0.1.sp),
                                ),
                                color: Color(0xff768AA1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '#',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.sp,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.only(left: 30.sp),
                                // height: 70.sp,
                                // width: 375.74.sp,
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.01),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Nome do Item',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.only(left: 30.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.1),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Marca',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.all(5.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.1),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                // padding: EdgeInsets.only(left: 30.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.1),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Movimentação',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(5.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.1),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Quantidade',
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.only(left: 30.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.1),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Data',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(5.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.1),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Horário',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.only(left: 30.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(0.1),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Usúario',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.only(left: 30.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.white,
                                          strokeAlign: 0.1.sp)),
                                  color: Color(0xff768AA1),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Membro',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isLoading
                            ? Center(
                                child: Lottie.asset(
                                  'lib/assets/loading_animation.json', // Adicione uma animação de carregamento
                                  height: 300.sp,
                                  width: 300.sp,
                                ),
                              )
                            : filteredItens.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Lottie.asset('lib/assets/animacao.json',
                                            height: 300.sp, width: 300.sp),
                                        Text(
                                          'Nenhuma movimentação registrada',
                                          style: TextStyle(
                                              color: Color(0xff768AA1),
                                              fontSize: 30.sp,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredItens.length,
                                    itemBuilder: (context, index) {
                                      final historico = filteredItens[
                                          index]; // Ordem original dos itens

                                      return HistoricTable(
                                        index: filteredItens.length - index,
                                        data: historico.data,
                                        hora: historico.hora,
                                        Marca: historico.Marca,
                                        StatusItem: historico.StatusItem,
                                        Item: historico.Item,
                                        Movimentacao: historico.Movimentacao,
                                        Quantidade: historico.Quantidade,
                                        DataMovimentacao:
                                            historico.DataMovimentacao,
                                        Usuario: historico.Usuario,
                                        id: historico.id,
                                        Membro: historico.Membro,
                                      );
                                    },
                                  ),
                      ),
                      // HistoricTable()
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _containerFilter(
    {required IconData icon,
    required String text,
    required double width,
    required GestureTapCallback ontap}) {
  return InkWell(
    onTap: ontap,
    child: Container(
      width: width,
      height: 50.sp,
      decoration: ShapeDecoration(
        color: Color(0xFF01244E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 20.sp),
          Icon(
            icon,
            color: Colors.white,
          ),
          SizedBox(width: 10.sp),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23.sp,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          )
        ],
      ),
    ),
  );
}
