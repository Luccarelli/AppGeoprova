import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maps_launcher/maps_launcher.dart';
import 'obraDetailsScreen.dart';
import 'menu.dart';
import 'package:text_mask/text_mask.dart';
import 'database_helper.dart';
import 'api_requests.dart';

class ObrasFavoritas extends StatefulWidget {
  @override
  _ObrasFavoritas createState() => _ObrasFavoritas();
}

Future<void> _openGoogleMaps(String enderecoCompleto) async {
  MapsLauncher.launchQuery(enderecoCompleto);
}

class _ObrasFavoritas extends State<ObrasFavoritas> {
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

  Future<List<ObrasData>> _fetchData(List<int> favoritos) async {
    List<ObrasData> obras = await ApiRequests.fetchObrasData();
    return obras.where((obra) => favoritos.contains(obra.idContrato)).toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Obras favoritas"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<ObrasData>>(
        future: _fetchData(idsFavoritos),
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
                child: Text('Nenhuma obra favorita encontrada!'),
              );
            }

            // Continue com a construção da lista de obras
            return ListView.builder(
              itemCount: obrasList.length,
              itemBuilder: (context, index) {
                ObrasData obra = obrasList[index];

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
