import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:velocityestoque/widgets/alert_dialog_product.dart';
import 'package:velocityestoque/screens/config_menber.dart';
import 'package:velocityestoque/models/member_model.dart';
import 'package:velocityestoque/widgets/config_member.dart';
import '../baseConect.dart';
import '../models/movimentacao_model.dart';
import '../services/products_services.dart';
import '../widgets/cardMember.dart';

class CreateMemberPage extends StatefulWidget {
  @override
  _CreateMemberPageState createState() => _CreateMemberPageState();
}

class _CreateMemberPageState extends State<CreateMemberPage> {
  final ValueNotifier<bool> _showFrontSide = ValueNotifier(true);
  List<MemberModel> members = [];
  List<MemberModel> filteredmembers = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  final TextEditingController _profileImageController = TextEditingController();
  final TextEditingController _searchController =
      TextEditingController(); // Controlador para a busca

  String? selectedOffice; // Para rastrear a profissão selecionada
  final ProductServices _productServices =
      ProductServices('ws://${Socket.apiUrl}');
  bool isLoading = true;

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Apenas inicializa a conexão e busca os membros uma vez
      await _productServices.fetchMembers();

      // Carrega os membros iniciais com o WebSocket
      final memberList = await _productServices.fetchMembers();
      setState(() {
        members = memberList;
        filteredmembers =
            members; // Inicializa a lista filtrada com todos os membros
      });

      // Chama o método _startListeningForUpdates após sua declaração
      _startListeningForUpdates();
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Função para começar a escutar as atualizações via WebSocket
  void _startListeningForUpdates() {
    _productServices.listenForMemberUpdates((memberId, updatedData) {
      setState(() {
        // Encontre o índice do membro na lista `members` e atualize os campos necessários
        int index = members.indexWhere((member) => member.id == memberId);
        if (index != -1) {
          // Atualize os campos específicos do membro (não substitua o membro inteiro)
          members[index] = MemberModel(
            id: memberId,
            name: updatedData['name'] ?? members[index].name,
            office: updatedData['office'] ?? members[index].office,
            isActive: updatedData['isActive'] ?? members[index].isActive,
            profileImage:
                updatedData['profileImage'] ?? members[index].profileImage,
          );

          // Se a imagem foi atualizada, chamamos o _loadData para forçar o recarregamento
          if (updatedData['profileImage'] != null) {
            _loadData(); // Recarrega os dados quando a imagem for alterada
          }
        } else {
          // Se o membro não estiver na lista, adicione ele com as novas informações
          members.add(MemberModel(
            id: memberId,
            name: updatedData['name'] ?? '',
            office: updatedData['office'] ?? '',
            isActive: updatedData['isActive'],
            profileImage: updatedData['profileImage'] ?? '',
          ));

          // Recarrega os dados se a imagem foi alterada
          if (updatedData['profileImage'] != null) {
            _loadData();
          }
        }

        // Reaplica a filtragem depois de atualizar os membros
        filterMembers(office: selectedOffice, name: _searchController.text);
      });
    });
  }

  Future<Map<String, int>> fetchMovimentacoes(String membroId) async {
    final url =
        Uri.parse('${Config.apiUrl}/api/historico-movimentacoes/$membroId');
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> movimentacoesData = jsonDecode(response.body);

        // Mapa para armazenar a soma das quantidades por produto
        Map<String, int> groupedMovimentacoes = {};

        // Agrupa as movimentações
        for (var json in movimentacoesData) {
          final movimentacao = MovimentacaoModel.fromJson(json);
          if (groupedMovimentacoes.containsKey(movimentacao.Produto)) {
            // Se o produto já estiver no mapa, soma a quantidade
            groupedMovimentacoes[movimentacao.Produto] =
                groupedMovimentacoes[movimentacao.Produto]! +
                    movimentacao.Quantidade;
          } else {
            // Se não, adiciona ao mapa
            groupedMovimentacoes[movimentacao.Produto] =
                movimentacao.Quantidade;
          }
        }

        return groupedMovimentacoes;
      } else {
        throw Exception('Erro ao buscar movimentações: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
      return {};
    }
  }

  void filterMembers({String? office, String? name}) {
    setState(() {
      selectedOffice = office;

      // Filtrando os membros com base no escritório e nome
      filteredmembers = members.where((member) {
        final matchesOffice =
            office == null || office == "Todos" || member.office == office;
        final matchesName = name == null ||
            member.name.toLowerCase().contains(name.toLowerCase());
        return matchesOffice && matchesName;
      }).toList();

      // Ordenando os membros para que os com isActive: false venham por último
      filteredmembers.sort((a, b) {
        if (a.isActive == false && b.isActive == true) {
          return 1; // a vem depois de b
        } else if (a.isActive == true && b.isActive == false) {
          return -1; // a vem antes de b
        } else {
          return 0; // mantém a ordem
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    // fetchMembers();
    _searchController.addListener(() {
      filterMembers(
          name: _searchController.text); // Atualiza a filtragem por nome
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Liberar o controlador ao finalizar
    super.dispose();
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotate = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotate,
      child: widget,
      builder: (context, child) {
        final isUnder = (ValueKey(_showFrontSide.value) != widget!.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }

  Widget backCard(String memberId) {
    print(memberId);
    return FutureBuilder<Map<String, int>>(
      future: fetchMovimentacoes(memberId), // Busca as movimentações pelo ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar movimentações.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print(snapshot.data);
          return Center(child: Text('Nenhuma movimentação encontrada.'));
        } else {
          // Acessando os dados agrupados
          final movimentacoes = snapshot.data!;

          return Container(
            height: 240.sp,
            decoration: BoxDecoration(
              color: Color(0xffE3E8EE),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 10),
                    Text("Em uso"),
                    Icon(
                      Icons.circle,
                      color: Color(0xff01244E),
                      size: 15,
                    ),
                    SizedBox(width: 20),
                    Text("Devolvido"),
                    Icon(
                      Icons.circle,
                      color: Color(0xffFFB000),
                      size: 15,
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: movimentacoes.length,
                      itemBuilder: (context, index) {
                        // Acessa a chave e o valor do mapa
                        String produto = movimentacoes.keys.elementAt(index);
                        int quantidade = movimentacoes[produto]!;

                        return ItensMember(
                          label: produto,
                          quantidade: quantidade,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> uniqueOffices =
        members.map((member) => member.office).toSet();

    return ScreenUtilInit(
      designSize: const Size(1154, 682),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.only(left: 50.sp, right: 50.sp),
            child: Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Colaboradores",
                        style: GoogleFonts.roboto(
                            fontSize: 36.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Campo de busca por nome
                  Container(
                    width: double.infinity,
                    height: 50.sp,
                    decoration: ShapeDecoration(
                      color: Color(0xFFE3E8EE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.sp),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8.sp),
                        Icon(Icons.search, color: Color(0xff8092A8)),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Encontrar colaborador pelo nome',
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.roboto(
                                color: Color(0xFFADBFD4),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 13.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 30.sp,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: uniqueOffices.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return SelectorContainer(
                                  office: "Todos",
                                  ContainerColor: selectedOffice == "Todos"
                                      ? Color(0xFF01244E)
                                      : Color(0xFFE3E8EE),
                                  TextColor: selectedOffice == "Todos"
                                      ? Colors.white
                                      : Color(0xFFADBFD4),
                                  onTap: () => filterMembers(office: "Todos"),
                                );
                              }
                              String office =
                                  uniqueOffices.elementAt(index - 1);
                              return SelectorContainer(
                                office: office,
                                ContainerColor: selectedOffice == office
                                    ? Color(0xFF01244E)
                                    : Color(0xFFE3E8EE),
                                TextColor: selectedOffice == office
                                    ? Colors.white
                                    : Color(0xFFADBFD4),
                                onTap: () => filterMembers(office: office),
                              );
                            },
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ConfigMember();
                              });
                        },
                        child: Container(
                          height: 32.sp,
                          decoration: ShapeDecoration(
                            color: Color(0xFFFEB100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.sp),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(right: 30.sp, left: 30.sp),
                            child: Row(
                              children: [
                                Icon(Icons.add_box_rounded,
                                    color: Colors.white),
                                SizedBox(width: 8.sp),
                                Text(
                                  'Adicionar colaborador',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  // Lista de membros filtrados
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: Lottie.asset("lib/assets/load_perfil.json",
                                height: 300.sp, width: 300.sp),
                          )
                        : filteredmembers.isEmpty
                            ? Text(
                                'Nenhuma membro encontrado',
                                style: TextStyle(
                                    color: Color(0xff768AA1),
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.w500),
                              )
                            : GridView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  childAspectRatio: 0.69,
                                  crossAxisSpacing: 5.sp,
                                  mainAxisSpacing: 1.sp,
                                ),
                                itemCount: filteredmembers.length,
                                itemBuilder: (context, index) {
                                  final ValueNotifier<bool> showFrontSide =
                                      ValueNotifier(true);

                                  return Carduser(
                                      ontap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialogProduct(
                                              membro: filteredmembers[index],
                                            );
                                          },
                                        );
                                      },
                                      membro: filteredmembers[index],
                                      key: ValueKey(
                                          "front_${filteredmembers[index].id}"));
                                },
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

class Carduser extends StatefulWidget {
  final MemberModel membro;
  final GestureTapCallback ontap;

  const Carduser({Key? key, required this.membro, required this.ontap})
      : super(key: key);

  @override
  _CarduserState createState() => _CarduserState();
}

class _CarduserState extends State<Carduser> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1154, 682),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHovering = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHovering = false;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 230.sp,
                  decoration: BoxDecoration(
                    color: Color(0xffE3E8EE),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: _isHovering
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0, 5),
                              blurRadius: 15,
                            ),
                          ]
                        : [],
                  ),
                  child: InkWell(
                    onTap: widget.ontap,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        height: 210.sp,
                        width: 150.sp,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRect(
                              child: widget.membro.profileImage != null &&
                                      widget.membro.profileImage!.isNotEmpty
                                  ? Image.network(
                                      widget.membro.profileImage.toString(),
                                      fit: BoxFit.cover,
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          widget.membro.office,
                                          style: TextStyle(
                                            color: Color(0xff01244E),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            // Se o membro estiver inativo, mostrar a sobreposição e o cadeado
                            if (!(widget.membro.isActive ?? true))
                              Container(
                                width: double.infinity,
                                height: 230.sp,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.black.withOpacity(
                                      0.5), // Sobreposição escurecida
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      size: 40.sp, // Tamanho do cadeado
                                      color: Colors
                                          .white, // Cor do ícone de cadeado
                                    ),
                                    Text(
                                      "Inativo",
                                      style: TextStyle(
                                        color: Colors.white, // Cor do texto
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Condicional para o botão de "Ver histórico de atividade"
                            if (_isHovering)
                              Stack(
                                children: [
                                  Container(
                                    height: 230.sp,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.black.withOpacity(0.5)),
                                    child: Center(
                                      child: Container(
                                        height: 30.sp,
                                        width: 130.sp,
                                        decoration: BoxDecoration(
                                          color: Color(0xffFEB100),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Ver histórico de atividade",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfiguereMember(
                                                membro: widget.membro,
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          PhosphorIcons.gear_fill,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget SelectorContainer({
  required String office,
  required Color ContainerColor,
  required Color TextColor,
  required Function onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: 32.sp,
        decoration: ShapeDecoration(
          color: ContainerColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 35, left: 35),
            child: Text(
              office,
              style: GoogleFonts.roboto(
                color: TextColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget ItensMember({required String label, required int quantidade}) {
  return ScreenUtilInit(
    designSize: const Size(1154, 682),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          height: 17.sp,
          decoration: BoxDecoration(
            color: Color(0xff01244E),
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 10),
              // Usar Expanded para que o texto do label ocupe o espaço disponível
              Expanded(
                child: Text(
                  label,
                  maxLines:
                      1, // Define que o texto deve ser exibido em uma linha
                  overflow: TextOverflow
                      .ellipsis, // Adiciona reticências se o texto for muito longo
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 15),
              Text(
                "${quantidade}x",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
