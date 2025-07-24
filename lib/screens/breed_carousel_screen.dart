import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BreedCarouselScreen extends StatefulWidget {
  const BreedCarouselScreen({super.key});

  @override
  State<BreedCarouselScreen> createState() => _BreedCarouselScreenState();
}

class _BreedCarouselScreenState extends State<BreedCarouselScreen> {
  final String apiKey = 'live_JBT0Ah0Nt12iyl2IpjQVLDWjcLk0GQwf4zI9wBMfmfejKmcC31mOJp4yJz5TsOUP';
  List<dynamic> breeds = [];
  int currentIndex = 0;

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

  void voteLike() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Te gusta esta raza!')),
    );
  }

  void voteDislike() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No te gusta esta raza')),
    );
  }

  void nextBreed() {
    if (currentIndex < breeds.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay más razas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (breeds.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final breed = breeds[currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Votaciones')),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            nextBreed(); // deslizar a la izquierda
          }
        },
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(breed['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: fetchImage(breed['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) return const Text('Sin imagen');
                  return Image.network(snapshot.data!, fit: BoxFit.cover);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Image.network('https://cdn-icons-png.flaticon.com/512/7854/7854889.png', width: 40),
                  onPressed: voteLike,
                ),
                IconButton(
                  icon: Image.network('https://cdn-icons-png.flaticon.com/512/4466/4466315.png', width: 40),
                  onPressed: voteDislike,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<String?> fetchImage(String breedId) async {
    final res = await http.get(Uri.parse(
        'https://api.thecatapi.com/v1/images/search?limit=1&breed_ids=$breedId&api_key=$apiKey'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data.isNotEmpty) {
        return data[0]['url'];
      }
    }
    return null;
  }
}
