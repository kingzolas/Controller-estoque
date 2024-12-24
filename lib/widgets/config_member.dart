import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocityestoque/popups/popup_updatemember.dart';

import '../models/member_model.dart';
import '../services/products_services.dart';

class ConfiguereMember extends StatefulWidget {
  final MemberModel membro;
  const ConfiguereMember({super.key, required this.membro});

  @override
  State<ConfiguereMember> createState() => _ConfigMemberState();
}

class _ConfigMemberState extends State<ConfiguereMember> {
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oficcerController = TextEditingController();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
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
            child: PopupUpdatemember(
              // nome: memberId,
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

  @override
  Widget build(BuildContext context) {
    bool? _selectedStatus = widget.membro.isActive;
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AlertDialog(
            content: Container(
              height: 470.sp,
              width: 1030.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Editar perfil do Colaborador',
                          style: TextStyle(
                            color: Color(0xFF01244E),
                            fontSize: 40.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            try {
                              await _productServices.updateInfoMember(
                                  _nameController.text,
                                  _oficcerController.text,
                                  _selectedStatus!,
                                  widget.membro.id
                                  // _profileImage.toString(),
                                  );
                              showCustomPopup(context, _nameController.text);
                              Navigator.pop(context);
                            } catch (error) {
                              // Trate o erro e informe ao usuário
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Erro ao atualizar as informações: $error')),
                              );
                            }
                          },

                          // onTap: () {
                          //   _productServices.updateInfoMember(
                          //       _nameController.text,
                          //       _oficcerController.text,
                          //       false,
                          //       widget.membro.id,
                          //       _profileImage.toString());
                          // },
                          child: Container(
                            width: 160.sp,
                            height: 54.sp,
                            decoration: ShapeDecoration(
                              color: Color(0xFF4BC57A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Finalizar',
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
                    SizedBox(
                      height: 25.sp,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 260.sp,
                          height: 330.sp,
                          decoration: ShapeDecoration(
                            color: Color(0xFFF0F4F8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: ClipRect(
                            child: widget.membro.profileImage != null &&
                                    widget.membro.profileImage!.isNotEmpty
                                ? Image.network(
                                    widget.membro.profileImage.toString(),
                                    fit: BoxFit.contain,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 50.sp, // Tamanho do ícone
                                          color: Color(0xFFADBFD4),
                                        ),
                                      ),
                                      Text(
                                        widget.membro.name,
                                        style: TextStyle(
                                            color: Color(0xff01244E),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        widget.membro.office,
                                        style: TextStyle(
                                            color: Color(0xff01244E),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nome do Colaborador',
                                style: TextStyle(
                                  color: Color(0xFF889BB2),
                                  fontSize: 20.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                              SizedBox(
                                height: 15.sp,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                width: 665.sp,
                                height: 60.sp,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFF0F4F8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: widget.membro.name),
                                ),
                                // child: Align(
                                //   alignment: Alignment.centerLeft,
                                //   child: Text(
                                //     widget.membro.name,
                                //     style: TextStyle(
                                //       color: Color(0xFFADBFD4),
                                //       fontSize: 20.sp,
                                //       fontFamily: 'Roboto',
                                //       fontWeight: FontWeight.w500,
                                //       height: 0,
                                //     ),
                                //   ),
                                // ),
                              ),
                              SizedBox(
                                height: 20.sp,
                              ),
                              Text(
                                'Cargo',
                                style: TextStyle(
                                  color: Color(0xFF889BB2),
                                  fontSize: 20.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                              SizedBox(
                                height: 15.sp,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                width: 665.sp,
                                height: 60.sp,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFF0F4F8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _oficcerController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: widget.membro.office),
                                ),
                                // child: Align(
                                //   alignment: Alignment.centerLeft,
                                //   child: Text(
                                //     widget.membro.office,
                                //     style: TextStyle(
                                //       color: Color(0xFFADBFD4),
                                //       fontSize: 20.sp,
                                //       fontFamily: 'Roboto',
                                //       fontWeight: FontWeight.w500,
                                //       height: 0,
                                //     ),
                                //   ),
                                // ),
                              ),
                              SizedBox(
                                height: 20.sp,
                              ),
                              Text(
                                'Status',
                                style: TextStyle(
                                  color: Color(0xFF889BB2),
                                  fontSize: 20.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                              SizedBox(
                                height: 15.sp,
                              ),
                              Container(
                                width: 150.sp,
                                height: 50.sp,
                                decoration: ShapeDecoration(
                                  color: (widget.membro.isActive ?? false)
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
                                      value: widget.membro.isActive,
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
                                            widget.membro.isActive = newValue;
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
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
