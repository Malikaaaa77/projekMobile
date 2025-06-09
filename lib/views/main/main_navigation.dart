import 'package:flutter/material.dart';
import '../home/home_view.dart';
import '../exercises/exercise_list_view.dart';
import '../location/gym_finder_view.dart';
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
  final GlobalKey<ExerciseListViewState> _exercisePageKey = GlobalKey<ExerciseListViewState>();
  
  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeView(),
      ExerciseListView(key: _exercisePageKey),
      const GymFinderView(),
      const FavoritesHistoryView(),
      const ProfileView(),
      const FeedbackView(),
    ];
    
    // Set initial visibility - exercise page starts as inactive (index 0 is active)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _exercisePageKey.currentState?.setPageVisibility(false);
    });
  }

  void _handlePageVisibilityChange(int previousIndex, int newIndex) {
    // Exercise page is at index 1
    const exercisePageIndex = 1;
    
    // If we're leaving the exercise page
    if (previousIndex == exercisePageIndex && newIndex != exercisePageIndex) {
      _exercisePageKey.currentState?.setPageVisibility(false);
    }
    // If we're entering the exercise page
    else if (previousIndex != exercisePageIndex && newIndex == exercisePageIndex) {
      _exercisePageKey.currentState?.setPageVisibility(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,        onTap: (index) {
          final previousIndex = _currentIndex;
          setState(() {
            _currentIndex = index;
          });
          
          // Handle exercise page visibility
          _handlePageVisibilityChange(previousIndex, index);
        },
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 8,        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
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