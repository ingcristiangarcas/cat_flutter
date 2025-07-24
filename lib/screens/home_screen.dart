import 'package:flutter/material.dart';
import 'breeds_screen.dart';
import 'breed_carousel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = [
    BreedsScreen(),
    BreedCarouselScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Razas'),
          BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: 'Votar'),
        ],
      ),
    );
  }
}
