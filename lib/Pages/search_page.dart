import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../main.dart'; 

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String urlPosterSelecionado = "";
  String tituloSelecionado = "";
  int notaAvaliacao = 5;

  final String apiKey = "e9b01cc0";


  Future<List<Map<String, String>>> buscarFilmesOnline(String query) async {
    if (query.length < 3) return [];

    final url = Uri.parse('https://www.omdbapi.com/?s=$query&apikey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          final List filmes = data['Search'];
          return filmes.map((f) {
            return {
              'titulo': f['Title'].toString(),
              'poster': f['Poster'].toString(),
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Erro na busca: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Search & Rate"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchAnchor.bar(
              barHintText: "Pesquisar filme...",
              barTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
              suggestionsBuilder: (context, controller) async {
                final resultados = await buscarFilmesOnline(controller.text);
                return resultados.map((filme) {
                  final temPoster = filme['poster'] != "N/A";
                  return ListTile(
                    leading: temPoster
                        ? Image.network(filme['poster']!, width: 30, fit: BoxFit.cover)
                        : const Icon(Icons.movie),
                    title: Text(filme['titulo']!, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      setState(() {
                        urlPosterSelecionado = temPoster ? filme['poster']! : "";
                        tituloSelecionado = filme['titulo']!;
                        controller.closeView(filme['titulo']);
                      });
                    },
                  );
                }).toList();
              },
            ),
            
            if (urlPosterSelecionado.isNotEmpty) ...[
              const SizedBox(height: 30),
              // Poster com sombra e borda
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    urlPosterSelecionado,
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Título do Filme
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  tituloSelecionado,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              // Estrelas 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < notaAvaliacao ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        notaAvaliacao = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Botão Save
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("SAVE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {
                  setState(() {
                    listaFavoritosGlobal.add(
                      FilmeAvaliado(
                        titulo: tituloSelecionado,
                        urlPoster: urlPosterSelecionado,
                        nota: notaAvaliacao,
                      ),
                    );
                    urlPosterSelecionado = "";
                    tituloSelecionado = "";
                    notaAvaliacao = 5;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Filme salvo nos favoritos!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ] else 
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Text(
                    "Busque um filme para avaliar",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}