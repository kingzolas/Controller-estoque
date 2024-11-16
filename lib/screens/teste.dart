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

class ConfigMenber extends StatefulWidget {
  const ConfigMenber({super.key});

  @override
  State<ConfigMenber> createState() => _ConfigMenberState();
}

class _ConfigMenberState extends State<ConfigMenber> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  File? _profileImage;

  Future<void> _createMember() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('${Config.apiUrl}/api/members');

      var request = http.MultipartRequest('POST', url);
      request.fields['name'] = _nameController.text;
      request.fields['office'] = _officeController.text;

      // Adicionando a imagem se selecionada
      if (_profileImage != null) {
        final mimeType = lookupMimeType(_profileImage!.path);
        final multipartFile = await http.MultipartFile.fromPath(
          'profileImage',
          _profileImage!.path,
          contentType: MediaType.parse(mimeType!),
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Membro criado com sucesso!')),
        );
        _nameController.clear();
        _officeController.clear();
        setState(() {
          _profileImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao criar o membro')),
        );
      }
    }
  }

  Future<void> _selectImage() async {
    // Usando file_selector para selecionar a imagem
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
            content: Container(
              width: 1030.sp,
              height: 470.sp,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [],
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nome do Membro'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do membro.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _officeController,
                      decoration: InputDecoration(labelText: 'Cargo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o cargo do membro.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _profileImage != null
                            ? Image.file(_profileImage!, fit: BoxFit.cover)
                            : Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _createMember,
                      child: Text('Criar Membro'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
