import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/session_manager.dart';
import '../../services/database_service.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  FeedbackViewState createState() => FeedbackViewState();
}

class FeedbackViewState extends State<FeedbackView> {
  final _suggestionController = TextEditingController();
  final _impressionController = TextEditingController();
  UserModel? _currentUser;
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await SessionManager.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _submitFeedback() async {
    if (_suggestionController.text.trim().isEmpty && 
        _impressionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide at least a suggestion or impression'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      if (_currentUser?.id != null) {
        await DatabaseService.instance.saveFeedback(
          userId: _currentUser!.id!,
          rating: _rating,
          suggestion: _suggestionController.text.trim().isEmpty 
              ? null 
              : _suggestionController.text.trim(),
          impression: _impressionController.text.trim().isEmpty 
              ? null 
              : _impressionController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Clear form
      _suggestionController.clear();
      _impressionController.clear();
      setState(() {
        _rating = 5;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saran & Kesan'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[700]!, Colors.purple[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mata Kuliah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Teknologi dan Pemrograman Mobile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semester Genap 2024/2025',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rating Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rate, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Rating Mata Kuliah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = index + 1;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.star,
                                size: 40,
                                color: index < _rating 
                                    ? Colors.orange[700]
                                    : Colors.grey[300],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Center(
                      child: Text(
                        _getRatingText(_rating),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Suggestion Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Saran untuk Mata Kuliah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _suggestionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Berikan saran untuk perbaikan mata kuliah ini...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Impression Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_outline, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Kesan terhadap Mata Kuliah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _impressionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Bagikan kesan Anda terhadap mata kuliah ini...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitFeedback,
                icon: const Icon(Icons.send),
                label: const Text(
                  'Kirim Feedback',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User Info
            if (_currentUser != null)
              Center(
                child: Text(
                  'Feedback dari: ${_currentUser!.fullName} (${_currentUser!.username})',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Sangat Kurang';
      case 2: return 'Kurang';
      case 3: return 'Cukup';
      case 4: return 'Baik';
      case 5: return 'Sangat Baik';
      default: return 'Belum dinilai';
    }
  }

  @override
  void dispose() {
    _suggestionController.dispose();
    _impressionController.dispose();
    super.dispose();
  }
}