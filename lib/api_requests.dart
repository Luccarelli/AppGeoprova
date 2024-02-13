import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiRequests {
  static Future<List<ObrasData>> fetchObrasData() async {
    final url = Uri.parse('https://geoprova.eaglesgroup.com.br/api/obra_app');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': 'minhaChaveDeApiSuperSegura123',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      List<ObrasData> obrasList =
          decodedJson.map((obra) => ObrasData.fromJson(obra)).toList();
      return obrasList;
    } else {
      // Lide com erros ao buscar os dados das obras
      return [];
    }
  }
}

class ObrasData {
  final int idObra;
  final String nome;
  final String endereco;
  final String num;
  final String cidade;
  final String complemento;
  final String cep;
  final String nomeCliente;
  final String nomeContratante;
  final String codContrato;
  final int idContrato;
  final int idCliente;

  ObrasData({
    required this.idObra,
    required this.nome,
    required this.endereco,
    required this.num,
    required this.cidade,
    required this.complemento,
    required this.cep,
    required this.nomeCliente,
    required this.nomeContratante,
    required this.codContrato,
    required this.idContrato,
    required this.idCliente,
  });

  factory ObrasData.fromJson(Map<String, dynamic> json) {
    return ObrasData(
      idObra: json['id_obra'],
      nome: json['nome'],
      endereco: json['endereco'],
      num: json['num'],
      cidade: json['cidade'],
      cep: json['cep'],
      complemento: json['complemento'],
      nomeCliente: json['nome_cliente'],
      nomeContratante: json['nome_contratante'],
      codContrato: json['cod_contrato'],
      idContrato: json['id_contrato'],
      idCliente: json['id_cliente'],
    );
  }
}
