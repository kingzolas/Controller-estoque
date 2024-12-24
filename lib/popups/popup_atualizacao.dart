import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:path/path.dart' as p;
import 'package:velocityestoque/version/app_version.dart';

class PopupAtualizacao extends StatefulWidget {
  final String versao;
  const PopupAtualizacao({super.key, required this.versao});

  @override
  State<PopupAtualizacao> createState() => _PopupAtualizacaoState();
}

class _PopupAtualizacaoState extends State<PopupAtualizacao> {
  double _progress = 0;
  bool _isDownloading = false;
  bool _updateSuccess = false;

  // Função para fazer o download do arquivo
  Future<void> _atualizar() async {
    setState(() {
      _isDownloading = true;
      _updateSuccess = false; // Reseta o status de sucesso
    });

    final url = '${Config.apiUrl}/api/download/${widget.versao}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/V.${widget.versao}.zip';
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      for (int i = 0; i <= 100; i++) {
        await Future.delayed(Duration(milliseconds: 20));
        setState(() {
          _progress = i / 100;
        });
      }

      await _extrairArquivo(filePath);
    } else {
      print('Falha no download: ${response.statusCode}');
    }
  }

  Future<void> _extrairArquivo(String filePath) async {
    try {
      final bytes = File(filePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      final dir = await getApplicationSupportDirectory();
      final extractDir = Directory('${dir.path}/V.${widget.versao}');

      if (!await extractDir.exists()) {
        await extractDir.create();
      }

      for (var file in archive) {
        final filePath = '${extractDir.path}/${file.name}';

        if (file.name.endsWith('/')) {
          final outDir = Directory(filePath);
          if (!await outDir.exists()) {
            await outDir.create(recursive: true);
          }
        } else {
          final outFile = File(filePath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      // Criar e executar o arquivo .bat
      await _criarEExecutarBat(extractDir.path);

      setState(() {
        _isDownloading = false;
        _updateSuccess = true;
      });

      _reiniciarApp();
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _updateSuccess = false;
      });
      print('Erro ao extrair ou substituir arquivos: $e');
    }
  }

  Future<void> _criarEExecutarBat(String extractDir) async {
    final batFilePath = 'C:\\Program Files\\Velocity Estoque\\update.bat';

    final batContent = '''
::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4
:: Automatically check & get admin rights
::::::::::::::::::::::::::::::::::::::::::::
@echo off
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:init
setlocal DisableDelayedExpansion
set cmdInvoke=1
set winSysFolder=System32
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"

if '%cmdInvoke%'=='1' goto InvokeCmd 

ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
goto ExecElevation

:InvokeCmd
ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "%SystemRoot%\\%winSysFolder%\\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
"%SystemRoot%\\%winSysFolder%\\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
xcopy /E /Y "$extractDir\\data" "C:\\Program Files\\Velocity Estoque\\data"
start "" "C:\\Program Files\\Velocity Estoque\\velocityestoque.exe"
exit
  ''';

    final batFile = File(batFilePath);
    await batFile.writeAsString(batContent);

    // Criar script PowerShell para executar o .bat como administrador
    final psScriptPath = '${Directory.systemTemp.path}\\run_update.ps1';
    final psContent = '''
Start-Process cmd -ArgumentList '/c "$batFilePath"' -Verb RunAs
''';

    final psFile = File(psScriptPath);
    await psFile.writeAsString(psContent);

    // Executar o script PowerShell
    await Process.run(
      'powershell.exe',
      ['-ExecutionPolicy', 'Bypass', '-File', psScriptPath],
      runInShell: true,
    ).then((result) {
      if (result.exitCode != 0) {
        print('Erro ao executar PowerShell: ${result.stderr}');
      } else {
        print('PowerShell executado com sucesso: ${result.stdout}');
      }
    });
  }

  void _reiniciarApp() async {
    print("Reiniciando o aplicativo para aplicar a atualização...");

    // Esperar 5 segundos para garantir que o .bat seja iniciado corretamente
    await Future.delayed(Duration(seconds: 0));

    exit(0); // Fecha o aplicativo
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
            width: 1200.sp,
            height: 668.sp,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 530.sp,
                  height: 640.sp,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Image.asset(
                    "lib/assets/new_update.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 650.sp,
                  height: 640.sp,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30.sp,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Uma ',
                                style: TextStyle(
                                  color: Color(0xFF01244E),
                                  fontSize: 27.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  height: 0,
                                ),
                              ),
                              TextSpan(
                                text: 'nova',
                                style: TextStyle(
                                  color: Color(0xFF4BC57A),
                                  fontSize: 27.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  height: 0,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' versão do Velocity Estoque está disponível! Atualize agora para aproveitar as melhorias e novos recursos.',
                                style: TextStyle(
                                  color: Color(0xFF01244E),
                                  fontSize: 27.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  height: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.sp),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'O que há de novo?',
                            style: TextStyle(
                              color: Color(0xFF4BC57A),
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.sp),
                        Row(
                          children: [
                            Text(
                              "Versão Atual ${AppVersion.version}",
                              style: TextStyle(
                                color: Color(0xFFA0A6AD),
                                fontSize: 20.sp,
                              ),
                            ),
                            SizedBox(width: 10.sp),
                            Icon(
                              PhosphorIcons.clock_counter_clockwise,
                              color: Color(0xff4CC67A),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Versão Nova ${widget.versao}",
                              style: TextStyle(
                                color: Color(0xFFA0A6AD),
                                fontSize: 20.sp,
                              ),
                            ),
                            SizedBox(width: 10.sp),
                            Icon(
                              PhosphorIcons.checks_bold,
                              color: Color(0xff4CC67A),
                            ),
                          ],
                        ),
                        SizedBox(height: 180.sp),
                        Spacer(),
                        if (_isDownloading)
                          Column(
                            children: [
                              LinearProgressIndicator(value: _progress),
                              SizedBox(height: 20.sp),
                              Text('${(_progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        if (_updateSuccess)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Atualização realizada com sucesso!',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: _isDownloading ? null : _atualizar,
                              child: Container(
                                width: 217.sp,
                                height: 70.sp,
                                decoration: ShapeDecoration(
                                  color: Color(0xFF4BC57A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Atualizar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 23.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 285.sp,
                                height: 70.sp,
                                decoration: ShapeDecoration(
                                  color: Color(0xFF01244E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Lembrar mais tarde',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 23.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
