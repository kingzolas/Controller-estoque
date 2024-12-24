import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:file_selector/file_selector.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:velocityestoque/dashboard.dart';

import '../baseConect.dart';
import '../popups/popup_createMember.dart';

class ConfigMember extends StatefulWidget {
  const ConfigMember({super.key});

  @override
  State<ConfigMember> createState() => _ConfigMemberState();
}

class _ConfigMemberState extends State<ConfigMember> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  File? _profileImage;

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
            child: PopupCreatemember(
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

  Future<void> _createMember() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha os campos obrigatórios.')),
      );
      return;
    }

    if (Config.apiUrl == null || Config.apiUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL da API não configurada.')),
      );
      return;
    }

    final url = Uri.tryParse('${Config.apiUrl}/api/members');
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL inválida.')),
      );
      return;
    }

    var request = http.MultipartRequest('POST', url);
    request.fields['name'] = _nameController.text;
    request.fields['office'] = _officeController.text;

    if (_profileImage != null) {
      final mimeType = lookupMimeType(_profileImage!.path);
      if (mimeType != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'profileImage',
          _profileImage!.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }
    }

    try {
      final response = await request.send();

      if (response.statusCode == 201) {
        print(_nameController.text);
        showCustomPopup(context, _nameController.text);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Membro criado com sucesso!')),
        // );
        Navigator.pop(context);

        _nameController.clear();
        _officeController.clear();
        setState(() {
          _profileImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao criar o membro.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar dados: $e')),
      );
    }
  }

  Future<void> _selectImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      setState(() {
        _profileImage = File(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AlertDialog(
          content: SizedBox(
            width: 1030.sp,
            height: 470.sp,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Form(
                key: _formKey, // Associando o formulário com a chave
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Criar perfil do colaborador',
                          style: TextStyle(
                            color: const Color(0xFF01244E),
                            fontSize: 40.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        _containerAction(
                          text: 'Finalizar',
                          color: const Color(0xff4CC67A),
                          ontap: _createMember,
                        )
                      ],
                    ),
                    SizedBox(height: 30.sp),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _selectImage,
                          child: Container(
                            width: 260.sp,
                            height: 330.sp,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF0F4F8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profileImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: const Color(0xff889BB2),
                                        size: 70.sp,
                                      ),
                                      SizedBox(height: 15.sp),
                                      Text(
                                        'Insira uma imagem\nde exibição para o perfil',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF889BB2),
                                          fontSize: 15.sp,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w700,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(width: 25.sp),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nome do Colaborador',
                                style: TextStyle(
                                  color: const Color(0xFF889BB2),
                                  fontSize: 20.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              _buildTextField(
                                  _nameController, 'Insira o nome do membro.'),
                              SizedBox(height: 20.sp),
                              Text(
                                'Cargo',
                                style: TextStyle(
                                  color: const Color(0xFF889BB2),
                                  fontSize: 20.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              _buildTextField(_officeController,
                                  'Insira o cargo do membro.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String errorMessage) {
    return Container(
      width: 625.sp,
      height: 59.sp,
      decoration: ShapeDecoration(
        color: const Color(0xFFF0F4F8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextFormField(
        controller: controller,
        decoration:
            const InputDecoration(labelText: '', border: InputBorder.none),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMessage;
          }
          return null;
        },
      ),
    );
  }
}

Widget _containerAction({
  required String text,
  required Color color,
  required VoidCallback ontap,
}) {
  return InkWell(
    onTap: ontap,
    child: Container(
      height: 50.sp,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 24.sp,
            ),
          ),
        ),
      ),
    ),
  );
}
