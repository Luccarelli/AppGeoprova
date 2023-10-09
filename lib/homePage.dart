// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:maps_launcher/maps_launcher.dart';
// import 'menu.dart';
// import 'package:text_mask/text_mask.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// Future<void> _openGoogleMaps(String enderecoCompleto) async {
//   MapsLauncher.launchQuery(enderecoCompleto);
// }

// class _HomePageState extends State<HomePage> {
//   TextEditingController _idObracontroller = TextEditingController();
//   TextEditingController _nomeObraController = TextEditingController();
//   TextEditingController _enderecoController = TextEditingController();
//   TextEditingController _cidadeController = TextEditingController();

//   Future<List<ObrasData>> fetchObrasData() async {
//     final url = Uri.parse('http://192.168.0.113:3000/api/obras');
//     final headers = {
//       'Content-Type': 'application/json',
//       'x-api-key': 'minhaChaveDeApiSuperSegura123',
//     };

//     void showCustomAlertDialog(BuildContext context, String message) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Erro'),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Fecha o AlertDialog
//                 },
//                 child: Text('Fechar'),
//               ),
//             ],
//           );
//         },
//       );
//     }

//     final response = await http.get(url, headers: headers);

//     if (response.statusCode == 200) {
//       List<dynamic> decodedJson = jsonDecode(response.body);
//       List<ObrasData> obrasList =
//           decodedJson.map((obra) => ObrasData.fromJson(obra)).toList();
//       return obrasList;
//     } else {
//       showCustomAlertDialog(context, 'Falha ao carregar dados das obras');
//       return [];
//     }
//   }

//   void _openDetailsDialog(ObrasData obra) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Detalhes da Obra'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 8),
//                 Text(
//                   'ID da Obra',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(obra.idObra.toString()),
//                 SizedBox(height: 16),
//                 Text(
//                   'Nome da Obra',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(obra.nome),
//                 SizedBox(height: 16),
//                 Text(
//                   'Endereço',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text('${obra.endereco}, ${obra.num}'),
//                 SizedBox(height: 16),
//                 Text(
//                   'Cidade',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(obra.cidade),
//                 SizedBox(height: 16),
//                 Text(
//                   'CEP',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   TextMask(pallet: '#####-###').getMaskedText(obra.cep),
//                 ),
//                 // Adicione outros detalhes da obra aqui...
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Fechar o modal
//               },
//               child: Text('Fechar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _openFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Filtrar Obras'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   controller: _idObracontroller,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(labelText: 'ID da Obra'),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: _nomeObraController,
//                   decoration: InputDecoration(labelText: 'Nome da Obra'),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: _enderecoController,
//                   decoration: InputDecoration(labelText: 'Endereço'),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: _cidadeController,
//                   decoration: InputDecoration(labelText: 'Cidade'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     _idObracontroller.clear();
//                     _nomeObraController.clear();
//                     _enderecoController.clear();
//                     _cidadeController.clear();
//                     setState(() {
//                       Navigator.of(context).pop();
//                     });
//                   },
//                   child: Text('Apagar filtros'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       Navigator.of(context).pop();
//                     });
//                   },
//                   child: Text('Filtrar'),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   List<ObrasData> _applyFilters(List<ObrasData> obrasList) {
//     String idObraFiltro = _idObracontroller.text.trim().toLowerCase();
//     String nomeFiltro = _nomeObraController.text.trim().toLowerCase();
//     String enderecoFiltro = _enderecoController.text.trim().toLowerCase();
//     String cidadeFiltro = _cidadeController.text.trim().toLowerCase();

//     if (idObraFiltro.isEmpty &&
//         nomeFiltro.isEmpty &&
//         enderecoFiltro.isEmpty &&
//         cidadeFiltro.isEmpty) {
//       return obrasList;
//     }

//     return obrasList.where((obra) {
//       bool idObraMatches =
//           obra.idObra.toString().toLowerCase().contains(idObraFiltro);
//       bool nomeMatches = obra.nome.toLowerCase().contains(nomeFiltro);
//       bool enderecoMatches =
//           obra.endereco.toLowerCase().contains(enderecoFiltro);
//       bool cidadeMatches = obra.cidade.toLowerCase().contains(cidadeFiltro);

//       return (idObraMatches && nomeMatches && enderecoMatches && cidadeMatches);
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Obras cadastradas'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search),
//             onPressed: () {
//               _openFilterDialog(); // Chamar o modal de filtro ao clicar na lupa
//             },
//           ),
//         ],
//       ),
//       drawer: AppDrawer(),
//       body: FutureBuilder<List<ObrasData>>(
//         future: fetchObrasData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Erro ao carregar os dados das obras'),
//             );
//           } else {
//             List<ObrasData> filteredObrasList = _applyFilters(snapshot.data!);

//             return ListView.builder(
//               itemCount: filteredObrasList.length,
//               itemBuilder: (context, index) {
//                 ObrasData obra = filteredObrasList[index];

//                 String enderecoCompleto =
//                     "${obra.endereco}, ${obra.num}, ${obra.cidade}, ${TextMask(pallet: '#####-###').getMaskedText(obra.cep)}";

//                 String titleWithId =
//                     "${obra.idObra} - ${obra.nome}"; // Concatenando o 'id_obra' com o nome da obra

//                 return Container(
//                   child: ListTile(
//                     title: Text(
//                       titleWithId,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     subtitle: Text(
//                       enderecoCompleto,
//                       style: TextStyle(
//                         fontSize: 14,
//                       ),
//                     ),
//                     onTap: () {
//                       _openDetailsDialog(
//                           obra); // Abrir o modal de detalhes ao clicar no item
//                     },
//                     trailing: InkWell(
//                       onTap: () => _openGoogleMaps(enderecoCompleto),
//                       child: Icon(
//                         Icons.location_on,
//                         color: Colors.blue,
//                         size: 30,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class ObrasData {
//   final int idObra;
//   final String nome;
//   final String endereco;
//   final String num;
//   final String cidade;
//   final String cep;

//   ObrasData({
//     required this.idObra,
//     required this.nome,
//     required this.endereco,
//     required this.num,
//     required this.cidade,
//     required this.cep,
//   });

//   factory ObrasData.fromJson(Map<String, dynamic> json) {
//     return ObrasData(
//       idObra: json['id_obra'],
//       nome: json['nome'],
//       endereco: json['endereco'],
//       num: json['num'],
//       cidade: json['cidade'],
//       cep: json['cep'],
//     );
//   }
// }
