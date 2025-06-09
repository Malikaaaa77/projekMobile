import 'package:flutter/material.dart';
import '../home/home_view.dart';
import '../exercises/exercise_list_view.dart';
import '../conversion/conversion_view.dart';
import '../location/gym_finder_view.dart'; // Add this import
import '../favorites/favorites_history_view.dart';
import '../profile/profile_view.dart';
import '../feedback/feedback_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const ExerciseListView(),
    const ConversionView(),
    const GymFinderView(),        // Add Gym Finder
    const FavoritesHistoryView(),
    const ProfileView(),
    const FeedbackView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
        selectedFontSize: 10,
        unselectedFontSize: 8,
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
            label: 'Converter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),     // Add Gym Finder tab
            label: 'Gym Finder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
        ],
      ),
    );
  }
}