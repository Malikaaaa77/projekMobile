import 'package:flutter/material.dart';
import '../home/home_view.dart';
import '../exercises/exercise_list_view.dart';
import '../conversion/conversion_view.dart';
import '../favorites/favorites_history_view.dart';
import '../profile/profile_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  MainNavigationViewState createState() => MainNavigationViewState();
}

class MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeView(),
    const ExerciseListView(),
    const ConversionView(),
    const FavoritesHistoryView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Convert',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}