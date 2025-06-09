import '../services/api_service.dart';
import '../views/conversion/conversion_view.dart';
import 'package:flutter/foundation.dart';

class ConversionPresenter {
  final ConversionViewContract view;

  ConversionPresenter(this.view);

  Future<void> convertCurrency(String from, String to, double amount) async {
    view.showCurrencyLoading();
    
    try {
      final response = await ApiService.getCurrencyRates(from);
      
      if (response['result'] == 'success') {
        final rates = response['conversion_rates'];
        final rate = rates[to];
        
        if (rate != null) {
          final result = amount * rate;
          view.showCurrencyResult(
            '$amount $from = ${result.toStringAsFixed(2)} $to\n'
            'Rate: 1 $from = ${rate.toStringAsFixed(4)} $to'
          );
        } else {
          view.showError('Currency $to not found in rates');
        }
      } else {
        view.showError('API Error: ${response['error-type']}');
      }
      
      view.hideCurrencyLoading();
    } catch (e) {
      view.hideCurrencyLoading();
      view.showError('Failed to convert currency: $e');
    }
  }

  Future<void> convertTime(String fromTimezone, String toTimezone) async {
    view.showTimeLoading();
    
    try {
      try {
        final fromTime = await ApiService.getTimezone(fromTimezone);
        final toTime = await ApiService.getTimezone(toTimezone);
        
        final fromFormatted = _formatTimeResponse(fromTime);
        final toFormatted = _formatTimeResponse(toTime);
        
        view.showTimeResult(
          'From: $fromFormatted (${fromTimezone.split('/').last})\n'
          'To: $toFormatted (${toTimezone.split('/').last})\n\n'
          'Day: ${fromTime['dayOfWeek']} → ${toTime['dayOfWeek']}'
        );
      } catch (apiError) {
        // Fallback ke manual calculation jika API gagal
        if (kDebugMode) {
          debugPrint('API failed, using manual calculation: $apiError');
        }
        
        final fromTime = ApiService.getTimezoneManual(fromTimezone);
        final toTime = ApiService.getTimezoneManual(toTimezone);
        
        final fromFormatted = _formatTimeResponse(fromTime);
        final toFormatted = _formatTimeResponse(toTime);
        
        view.showTimeResult(
          'From: $fromFormatted (${fromTimezone.split('/').last})\n'
          'To: $toFormatted (${toTimezone.split('/').last})\n\n'
          '⚠️ Using offline calculation\n'
          'Day: ${fromTime['dayOfWeek']} → ${toTime['dayOfWeek']}'
        );
      }
      
      view.hideTimeLoading();
    } catch (e) {
      view.hideTimeLoading();
      view.showError('Failed to convert time: $e');
    }
  }

  String _formatTimeResponse(Map<String, dynamic> timeData) {
    final year = timeData['year'];
    final month = timeData['month'].toString().padLeft(2, '0');
    final day = timeData['day'].toString().padLeft(2, '0');
    final hour = timeData['hour'].toString().padLeft(2, '0');
    final minute = timeData['minute'].toString().padLeft(2, '0');
    final seconds = timeData['seconds'].toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute:$seconds';
  }
}