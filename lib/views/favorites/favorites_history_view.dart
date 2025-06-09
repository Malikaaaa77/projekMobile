import 'package:flutter/material.dart';
import '../../models/favorite_model.dart';
import '../../models/history_model.dart';
import '../../presenters/favorites_presenter.dart';

class FavoritesHistoryView extends StatefulWidget {
  const FavoritesHistoryView({super.key});

  @override
  FavoritesHistoryViewState createState() => FavoritesHistoryViewState();
}

class FavoritesHistoryViewState extends State<FavoritesHistoryView> 
    with SingleTickerProviderStateMixin implements FavoritesViewContract {
  
  late FavoritesPresenter _presenter;
  late TabController _tabController;
  
  List<FavoriteModel> _favorites = [];
  List<HistoryModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _presenter = FavoritesPresenter(this);
    _tabController = TabController(length: 2, vsync: this);
    _presenter.loadData(); // Fixed method call
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites & History'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _presenter.refreshData(),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFavoritesTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add exercises to your favorites to see them here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.red[100],
              child: Icon(Icons.favorite, color: Colors.red[700]),
            ),
            title: Text(
              favorite.exerciseName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Muscle: ${favorite.muscle}'),
                Text('Equipment: ${favorite.equipment}'),
                Text('Difficulty: ${favorite.difficulty}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red[600]),
              onPressed: () => _confirmRemoveFavorite(favorite.exerciseName),
            ),
            onTap: () => _showExerciseDetails(favorite),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No completed exercises yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Complete exercises to see your progress here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final history = _history[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.check_circle, color: Colors.green[700]),
            ),
            title: Text(
              history.exerciseName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Muscle: ${history.muscle}'),
                Text('Equipment: ${history.equipment}'),
                Text('Completed: ${_formatDate(history.completedAt)}'),
              ],
            ),
            onTap: () => _showExerciseDetails(history),
          ),
        );
      },
    );
  }

  void _confirmRemoveFavorite(String exerciseName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: Text('Are you sure you want to remove "$exerciseName" from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _presenter.removeFavorite(exerciseName); // Fixed method call
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showExerciseDetails(dynamic exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.exerciseName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', exercise.exerciseType),
              _buildDetailRow('Muscle', exercise.muscle),
              _buildDetailRow('Equipment', exercise.equipment),
              _buildDetailRow('Difficulty', exercise.difficulty),
              const SizedBox(height: 12),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(exercise.instructions),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void showFavorites(List<FavoriteModel> favorites) {
    if (mounted) {
      setState(() {
        _favorites = favorites;
      });
    }
  }

  @override
  void showHistory(List<HistoryModel> history) {
    if (mounted) {
      setState(() {
        _history = history;
      });
    }
  }

  @override
  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void showLoading() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  @override
  void hideLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}