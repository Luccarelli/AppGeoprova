import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maps_launcher/maps_launcher.dart';
import 'obraDetailsScreen.dart';
import 'menu.dart';
import 'package:text_mask/text_mask.dart';
import 'database_helper.dart';
import 'api_requests.dart';

class Obras extends StatefulWidget {
  @override
  const Obras({Key? key}) : super(key: key);
  _Obras createState() => _Obras();
}

Future<void> _openGoogleMaps(String enderecoCompleto) async {
  MapsLauncher.launchQuery(enderecoCompleto);
}

class _Obras extends State<Obras> {
  TextEditingController _idObracontroller = TextEditingController();
  TextEditingController _codContratoController = TextEditingController();
  TextEditingController _nomeObraController = TextEditingController();
  TextEditingController _nomeClienteController = TextEditingController();
  TextEditingController _enderecoController = TextEditingController();
  TextEditingController _cidadeController = TextEditingController();

  void showCustomAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<List<ObrasData>> _fetchData() async {
    List<ObrasData> obras = await ApiRequests.fetchObrasData();
    return obras;
  }

  // Future<List<ObrasData>> fetchObrasData() async {
  //   final url = Uri.parse('https://geoprova.eaglesgroup.com.br/api/obra_app');
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'x-api-key': 'minhaChaveDeApiSuperSegura123',
  //   };

  //   final response = await http.get(url, headers: headers);

  //   if (response.statusCode == 200) {
  //     List<dynamic> decodedJson = jsonDecode(response.body);
  //     List<ObrasData> obrasList =
  //         decodedJson.map((obra) => ObrasData.fromJson(obra)).toList();
  //     return obrasList;
  //   } else {
  //     showCustomAlertDialog(context, 'Falha ao carregar dados das obras');
  //     return [];
  //   }
  // }

  String _loggedInUser = '';

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser();
  }

  void _fetchLoggedInUser() async {
    List<Map<String, dynamic>> rows =
        await DatabaseHelper.instance.queryAllRows();
    if (rows.isNotEmpty) {
      setState(() {
        _loggedInUser = rows[0][DatabaseHelper.columnLogin];
      });
      fetchFavoritos(_loggedInUser);
    }
  }

  List<int> idsFavoritos = [];

  Future<void> fetchFavoritos(String _loggedInUser) async {
    final url = Uri.parse(
        'https://geoprova.eaglesgroup.com.br/api/obra_favoritos?login=$_loggedInUser');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': 'minhaChaveDeApiSuperSegura123',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      setState(() {
        idsFavoritos = List<int>.from(jsonDecode(response.body));
      });
    } else {
      // Lide com erros ao buscar os favoritos
    }
  }

  Future<void> addToFavorites(int idContrato) async {
    final url =
        Uri.parse('https://geoprova.eaglesgroup.com.br/api/obra_favoritos');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': 'minhaChaveDeApiSuperSegura123',
    };

    final body = jsonEncode({
      'id_contrato': idContrato,
      'login': _loggedInUser,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Tratamento de sucesso
    } else {
      // Tratamento de erro
    }
  }

  Future<void> removeFromFavorites(int idContrato) async {
    final url =
        Uri.parse('https://geoprova.eaglesgroup.com.br/api/obra_favoritos');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': 'minhaChaveDeApiSuperSegura123',
    };

    final body = jsonEncode({
      'id_contrato': idContrato,
      'login': _loggedInUser,
    });

    final response = await http.delete(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Tratamento de sucesso
    } else {
      // Tratamento de erro
    }
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtrar Obras'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _idObracontroller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'ID da obra'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _codContratoController,
                  decoration: InputDecoration(labelText: 'Código do contrato'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _nomeObraController,
                  decoration: InputDecoration(labelText: 'Nome da obra'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _nomeClienteController,
                  decoration: InputDecoration(labelText: 'Nome do cliente'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _enderecoController,
                  decoration: InputDecoration(labelText: 'Endereço'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _cidadeController,
                  decoration: InputDecoration(labelText: 'Cidade'),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _idObracontroller.clear();
                    _codContratoController.clear();
                    _nomeObraController.clear();
                    _nomeClienteController.clear();
                    _enderecoController.clear();
                    _cidadeController.clear();
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text('Apagar filtros'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text('Filtrar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<ObrasData> _applyFilters(List<ObrasData> obrasList) {
    String idObraFiltro = _idObracontroller.text.trim().toLowerCase();
    String codContratoFiltro = _codContratoController.text.trim().toLowerCase();
    String nomeFiltro = _nomeObraController.text.trim().toLowerCase();
    String nomeClienteFiltro = _nomeClienteController.text.trim().toLowerCase();
    String enderecoFiltro = _enderecoController.text.trim().toLowerCase();
    String cidadeFiltro = _cidadeController.text.trim().toLowerCase();

    if (idObraFiltro.isEmpty &&
        codContratoFiltro.isEmpty &&
        nomeFiltro.isEmpty &&
        nomeClienteFiltro.isEmpty &&
        enderecoFiltro.isEmpty &&
        cidadeFiltro.isEmpty) {
      return obrasList;
    }

    return obrasList.where((obra) {
      bool idObraMatches =
          obra.idObra.toString().toLowerCase().contains(idObraFiltro);
      bool codContratoMatches =
          obra.codContrato.toLowerCase().contains(codContratoFiltro);
      bool nomeMatches = obra.nome.toLowerCase().contains(nomeFiltro);
      bool nomeClienteMatches =
          obra.nomeCliente.toLowerCase().contains(nomeClienteFiltro);
      bool enderecoMatches =
          obra.endereco.toLowerCase().contains(enderecoFiltro);
      bool cidadeMatches = obra.cidade.toLowerCase().contains(cidadeFiltro);

      return (idObraMatches &&
          nomeMatches &&
          enderecoMatches &&
          cidadeMatches &&
          codContratoMatches &&
          nomeClienteMatches);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Obras cadastradas"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _openFilterDialog();
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<ObrasData>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar os dados das obras'),
            );
          } else {
            final obrasList = snapshot.data ?? [];

            if (obrasList.isEmpty) {
              // Se não houver obras favoritas, exiba a mensagem
              return Center(
                child: Text('Nenhuma obra encontrada!'),
              );
            }

            List<ObrasData> filteredObrasList = _applyFilters(snapshot.data!);

            return ListView.builder(
              itemCount: filteredObrasList.length,
              itemBuilder: (context, index) {
                ObrasData obra = filteredObrasList[index];

                String enderecoCompleto =
                    "${obra.endereco}, ${obra.num}, ${obra.cidade}, ${TextMask(pallet: '#####-###').getMaskedText(obra.cep)}";

                String titleWithId =
                    "${obra.codContrato} - ${obra.nomeCliente} - ${obra.nome}";

                bool isFavorito = idsFavoritos.contains(obra.idContrato);

                return Container(
                  child: ListTile(
                    title: Text(
                      titleWithId,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      enderecoCompleto,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesObraScreen(
                            obraSelecionada: obra,
                          ),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              isFavorito = !isFavorito;
                              if (isFavorito) {
                                idsFavoritos.add(obra.idContrato);
                                addToFavorites(obra.idContrato);
                              } else {
                                idsFavoritos.remove(obra.idContrato);
                                removeFromFavorites(obra.idContrato);
                              }
                            });
                          },
                          icon: Icon(
                            isFavorito ? Icons.star : Icons.star_border,
                            color: isFavorito ? Colors.yellow : null,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openGoogleMaps(enderecoCompleto),
                          icon: Icon(Icons.pin_drop),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// class ObrasData {
//   final int idObra;
//   final String nome;
//   final String endereco;
//   final String num;
//   final String cidade;
//   final String cep;
//   final String nomeCliente;
//   final String nomeContratante;
//   final String codContrato;
//   final int idContrato;
//   final int idCliente;

//   ObrasData({
//     required this.idObra,
//     required this.nome,
//     required this.endereco,
//     required this.num,
//     required this.cidade,
//     required this.cep,
//     required this.nomeCliente,
//     required this.nomeContratante,
//     required this.codContrato,
//     required this.idContrato,
//     required this.idCliente,
//   });

//   factory ObrasData.fromJson(Map<String, dynamic> json) {
//     return ObrasData(
//       idObra: json['id_obra'],
//       nome: json['nome'],
//       endereco: json['endereco'],
//       num: json['num'],
//       cidade: json['cidade'],
//       cep: json['cep'],
//       nomeCliente: json['nome_cliente'],
//       nomeContratante: json['nome_contratante'],
//       codContrato: json['cod_contrato'],
//       idContrato: json['id_contrato'],
//       idCliente: json['id_cliente'],
//     );
//   }
// }
