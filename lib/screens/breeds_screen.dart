import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BreedsScreen extends StatefulWidget {
  const BreedsScreen({super.key});

  @override
  State<BreedsScreen> createState() => _BreedsScreenState();
}

class _BreedsScreenState extends State<BreedsScreen> {
  final String apiKey = 'live_JBT0Ah0Nt12iyl2IpjQVLDWjcLk0GQwf4zI9wBMfmfejKmcC31mOJp4yJz5TsOUP';
  List<dynamic> breeds = [];
  String? selectedBreedId;
  Map<String, dynamic>? selectedBreed;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    fetchBreeds();
  }

  Future<void> fetchBreeds() async {
    final res = await http.get(
      Uri.parse('https://api.thecatapi.com/v1/breeds'),
      headers: {'x-api-key': apiKey},
    );
    if (res.statusCode == 200) {
      setState(() {
        breeds = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchImages(String breedId) async {
    final res = await http.get(
      Uri.parse('https://api.thecatapi.com/v1/images/search?limit=10&breed_ids=$breedId&api_key=$apiKey'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        images = List<String>.from(data.map((item) => item['url']));
      });
    }
  }

  void onBreedSelected(String? breedId) {
    setState(() {
      selectedBreedId = breedId;
      selectedBreed = breeds.firstWhere((b) => b['id'] == breedId);
      images = [];
    });
    if (breedId != null) {
      fetchImages(breedId);
    }
  }

  Future<void> _openWikipedia() async {
    if (selectedBreed == null || selectedBreed!['wikipedia_url'] == null) return;

    final Uri url = Uri.parse(selectedBreed!['wikipedia_url']);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxContentWidth = 600; // ancho máximo para mantener centrado
    final double screenWidth = MediaQuery.of(context).size.width;
    final double contentWidth = screenWidth > maxContentWidth ? maxContentWidth : screenWidth;

    return Scaffold(
      appBar: AppBar(title: const Text('Razas de gatos')),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedBreedId,
                  hint: const Text('Selecciona una raza'),
                  isExpanded: true,
                  items: breeds.map<DropdownMenuItem<String>>((b) {
                    return DropdownMenuItem<String>(
                      value: b['id'] as String,
                      child: Text(b['name'] as String),
                    );
                  }).toList(),
                  onChanged: onBreedSelected,
                ),
                const SizedBox(height: 16),
                if (selectedBreed != null) ...[
                  Text(selectedBreed!['name'],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Vida: ${selectedBreed!['life_span']} años'),
                  Text('Inteligencia: ${selectedBreed!['intelligence']}'),
                  Text('Origen: ${selectedBreed!['origin']}'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: images.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : CarouselSlider(
                            options: CarouselOptions(
                              viewportFraction: 1.0,
                              autoPlay: true,
                              enableInfiniteScroll: true,
                              enlargeCenterPage: true,
                            ),
                            items: images.map((url) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedBreed!['description'] ?? '',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _openWikipedia,
                    child: const Text('Leer más en Wikipedia'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
