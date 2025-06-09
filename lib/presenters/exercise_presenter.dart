import '../models/exercise_model.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

abstract class ExerciseViewContract {
  void showExercises(List<ExerciseModel> exercises);
  void showAvailableMuscles(List<String> muscles);
  void showError(String message);
  void showLoading();
  void hideLoading();
}

class ExercisePresenter {
  final ExerciseViewContract view;

  ExercisePresenter(this.view);

  Future<void> loadAvailableMuscles() async {
    try {
      final muscles = await ApiService.getAvailableMuscles();
      view.showAvailableMuscles(muscles);
      if (kDebugMode) debugPrint('Available muscles loaded: ${muscles.length}');
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading muscles: $e');
      view.showError('Failed to load muscle groups');
    }
  }

  Future<void> loadAllExercises() async {
    view.showLoading();
    try {
      final exercises = await ApiService.getAllExercises();
      view.showExercises(exercises);
      if (kDebugMode) debugPrint('All exercises loaded: ${exercises.length}');
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading all exercises: $e');
      view.showError('Failed to load exercises: $e');
    } finally {
      view.hideLoading();
    }
  }

  Future<void> loadExercisesByMuscle(String muscle) async {
    view.showLoading();
    try {
      final exercises = await ApiService.getExercisesByMuscle(muscle);
      view.showExercises(exercises);
      if (kDebugMode) debugPrint('Exercises for $muscle loaded: ${exercises.length}');
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading exercises for $muscle: $e');
      view.showError('Failed to load $muscle exercises: $e');
    } finally {
      view.hideLoading();
    }
  }
}