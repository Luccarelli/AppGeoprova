import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher_string.dart';
import 'api_requests.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:text_mask/text_mask.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DetalhesObraScreen extends StatelessWidget {
  final ObrasData obraSelecionada;

  Future<void> _openGoogleMaps(String enderecoCompleto) async {
    MapsLauncher.launchQuery(enderecoCompleto);
  }

  DetalhesObraScreen({required this.obraSelecionada});

  Future<void> _launchLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: false, forceSafariVC: false);
    } else {
      print("Não pode executar o link $url");
    }
  }

  Future<List<dynamic>> fetchClientes() async {
    final url = (Uri.parse(
        'https://geoprova.eaglesgroup.com.br/api/cliente_contato_app'));
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': 'minhaChaveDeApiSuperSegura123',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .where((contrato) =>
              contrato['id_contrato'] == obraSelecionada.idContrato)
          .toList();
    } else {
      throw Exception('Falha ao carregar Contatos!');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 17),
      ],
    );
  }

  void _showContactModal(
      BuildContext context,
      String nome,
      String email,
      String telefone,
      String celular,
      String observacao,
      String tipo,
      String funcao) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contato',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildContactInfo('Nome', nome),
              _buildContactInfo('Tipo do contato', tipo),
              _buildContactInfo('Função', funcao),
              _buildContactInfo('Email', email),
              _buildContactInfo(
                  'Telefone',
                  telefone.isNotEmpty
                      ? TextMask(pallet: '(##) ####-####')
                          .getMaskedText(telefone)
                      : '-'),
              _buildContactInfo(
                  'Celular',
                  celular.isNotEmpty
                      ? TextMask(pallet: '(##) #####-####')
                          .getMaskedText(celular)
                      : '-'),
              _buildContactInfo(
                  'Observação', observacao.isNotEmpty ? observacao : '-'),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        final url =
                            'tel://${celular.replaceAll(RegExp(r'[^0-9]'), '')}';
                        launch(url);
                      },
                      child: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(width: 8.0), // Espaçamento entre os botões
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        _launchLink('mailto:${email}');
                      },
                      child: Icon(Icons.mail),
                    ),
                  ),
                  SizedBox(width: 8.0), // Espaçamento entre os botões
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        final whatsappUrl =
                            'https://api.whatsapp.com/send?phone=${celular.replaceAll(RegExp(r'[^0-9]'), '')}';
                        launch(whatsappUrl);
                      },
                      child: Image.asset(
                        'assets/img/whatsapp.png', // Substitua com o caminho correto para o ícone do WhatsApp
                        width:
                            24.0, // Ajuste o tamanho do ícone conforme necessário
                        height:
                            24.0, // Ajuste o tamanho do ícone conforme necessário
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
      },
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String enderecoCompleto =
        "${obraSelecionada.endereco}, ${obraSelecionada.num}, ${obraSelecionada.cidade}, ${obraSelecionada.cep}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Obra ${obraSelecionada.nome}'),
        actions: [
          IconButton(
            icon: Icon(Icons.pin_drop),
            onPressed: () {
              _openGoogleMaps(
                  enderecoCompleto); // Chamar o modal de filtro ao clicar na lupa
            },
          ),
        ],
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          children: [
            _buildInfoRow('Cod. Contrato', obraSelecionada.codContrato),
            _buildInfoRow('Cliente', obraSelecionada.nomeCliente),
            _buildInfoRow('Contratante', obraSelecionada.nomeContratante),
            _buildInfoRow('Cidade', obraSelecionada.cidade),
            _buildInfoRow('Endereço', obraSelecionada.endereco),
            _buildInfoRow('Número', obraSelecionada.num),
            _buildInfoRow('Complemento', obraSelecionada.complemento),
            _buildInfoRow(
                'CEP',
                TextMask(pallet: '#####-###')
                    .getMaskedText(obraSelecionada.cep)),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Contatos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
// ...

            FutureBuilder<List<dynamic>>(
              future: fetchClientes(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top:
                              30.0), // Ajuste a margem superior conforme necessário
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top:
                              30.0), // Ajuste a margem superior conforme necessário
                      child: Text('Nenhum contato encontrado!'),
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final nome = snapshot.data![index]['nome_pessoa'];
                      final email = snapshot.data![index]['email'];
                      final telefone = snapshot.data![index]['telefone'];
                      final celular = snapshot.data![index]['celular'];
                      final observacao = snapshot.data![index]['observacao'];
                      final tipo = snapshot.data![index]['tipo'];
                      final funcao = snapshot.data![index]['funcao'];
                      return ListTile(
                        title: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: tipo,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              TextSpan(text: ' - $nome'),
                            ],
                          ),
                        ),
                        subtitle: Text(email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                final url =
                                    'tel://${celular.replaceAll(RegExp(r'[^0-9]'), '')}';
                                launch(url);
                              },
                              icon: Icon(Icons.phone),
                            ),
                          ],
                        ),
                        onTap: () {
                          _showContactModal(context, nome, email, telefone,
                              celular, observacao, tipo, funcao);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
