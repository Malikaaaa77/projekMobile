import 'package:flutter/foundation.dart';
import '../models/equipment_model.dart';
import 'api_service.dart';

class EquipmentService {
  // Equipment mapping tetap sama seperti sebelumnya
  static const Map<String, List<Map<String, dynamic>>> _exerciseEquipmentMap = {
    // Biceps exercises
    'biceps': [
      {
        'id': 'dumbbells_adjustable',
        'name': 'Adjustable Dumbbells (5-25kg)',
        'category': 'weights',
        'base_price_usd': 85.0,
        'necessity': 'recommended',
        'alternatives': ['Water bottles', 'Resistance bands'],
        'image_url': 'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Dumbbells',
        'description': 'Perfect for progressive bicep training with adjustable weight options.',
      },
      {
        'id': 'resistance_bands',
        'name': 'Resistance Band Set',
        'category': 'accessories',
        'base_price_usd': 25.0,
        'necessity': 'optional',
        'alternatives': ['Dumbbells', 'Cable machine'],
        'image_url': 'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Bands',
        'description': 'Versatile and portable option for bicep curls and arm exercises.',
      },
    ],
    
    'triceps': [
      {
        'id': 'dumbbells_adjustable',
        'name': 'Adjustable Dumbbells (5-25kg)',
        'category': 'weights',
        'base_price_usd': 85.0,
        'necessity': 'recommended',
        'alternatives': ['Water bottles', 'Resistance bands'],
        'image_url': 'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Dumbbells',
        'description': 'Essential for tricep extensions and overhead presses.',
      },
      {
        'id': 'tricep_dips_bar',
        'name': 'Parallel Dip Bars',
        'category': 'equipment',
        'base_price_usd': 120.0,
        'necessity': 'optional',
        'alternatives': ['Chair', 'Bench'],
        'image_url': 'https://via.placeholder.com/150x150/9C27B0/FFFFFF?text=Dip+Bars',
        'description': 'Professional equipment for tricep dips and upper body strength.',
      },
    ],

    'chest': [
      {
        'id': 'push_up_handles',
        'name': 'Push-up Handles (Pair)',
        'category': 'accessories',
        'base_price_usd': 17.0,
        'necessity': 'optional',
        'alternatives': ['Floor push-ups', 'Books'],
        'image_url': 'https://via.placeholder.com/150x150/2196F3/FFFFFF?text=Push+Up',
        'description': 'Reduce wrist strain and increase range of motion for push-ups.',
      },
      {
        'id': 'dumbbells_chest',
        'name': 'Dumbbell Set (10-30kg)',
        'category': 'weights',
        'base_price_usd': 150.0,
        'necessity': 'recommended',
        'alternatives': ['Push-ups', 'Resistance bands'],
        'image_url': 'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Heavy+DB',
        'description': 'For chest press, flyes, and advanced chest development.',
      },
      {
        'id': 'yoga_mat',
        'name': 'Exercise Mat (6mm)',
        'category': 'accessories',
        'base_price_usd': 12.0,
        'necessity': 'recommended',
        'alternatives': ['Towel', 'Carpet'],
        'image_url': 'https://via.placeholder.com/150x150/607D8B/FFFFFF?text=Mat',
        'description': 'Comfortable surface for floor exercises and stretching.',
      },
    ],

    'back': [
      {
        'id': 'pull_up_bar',
        'name': 'Doorway Pull-up Bar',
        'category': 'equipment',
        'base_price_usd': 35.0,
        'necessity': 'recommended',
        'alternatives': ['Resistance bands', 'Bent-over rows'],
        'image_url': 'https://via.placeholder.com/150x150/795548/FFFFFF?text=Pull+Bar',
        'description': 'Essential for pull-ups, chin-ups, and lat development.',
      },
      {
        'id': 'resistance_bands_heavy',
        'name': 'Heavy Resistance Bands',
        'category': 'accessories',
        'base_price_usd': 30.0,
        'necessity': 'optional',
        'alternatives': ['Pull-up bar', 'Dumbbells'],
        'image_url': 'https://via.placeholder.com/150x150/FF5722/FFFFFF?text=Heavy+Band',
        'description': 'Great for assisted pull-ups and rowing movements.',
      },
    ],

    'shoulders': [
      {
        'id': 'dumbbells_light',
        'name': 'Light Dumbbells (2-10kg)',
        'category': 'weights',
        'base_price_usd': 45.0,
        'necessity': 'recommended',
        'alternatives': ['Water bottles', 'Resistance bands'],
        'image_url': 'https://via.placeholder.com/150x150/E91E63/FFFFFF?text=Light+DB',
        'description': 'Perfect weight range for shoulder isolation exercises.',
      },
      {
        'id': 'resistance_bands',
        'name': 'Resistance Band Set',
        'category': 'accessories',
        'base_price_usd': 25.0,
        'necessity': 'optional',
        'alternatives': ['Dumbbells', 'Bodyweight'],
        'image_url': 'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Bands',
        'description': 'Excellent for shoulder rehabilitation and strengthening.',
      },
    ],

    'abs': [
      {
        'id': 'yoga_mat',
        'name': 'Exercise Mat (6mm)',
        'category': 'accessories',
        'base_price_usd': 12.0,
        'necessity': 'recommended',
        'alternatives': ['Towel', 'Carpet'],
        'image_url': 'https://via.placeholder.com/150x150/607D8B/FFFFFF?text=Mat',
        'description': 'Essential for comfortable floor ab exercises.',
      },
      {
        'id': 'ab_wheel',
        'name': 'Ab Roller Wheel',
        'category': 'equipment',
        'base_price_usd': 22.0,
        'necessity': 'optional',
        'alternatives': ['Planks', 'Crunches'],
        'image_url': 'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Ab+Wheel',
        'description': 'Advanced core strengthening tool for intense ab workouts.',
      },
    ],

    'quadriceps': [
      {
        'id': 'dumbbells_heavy',
        'name': 'Heavy Dumbbells (15-35kg)',
        'category': 'weights',
        'base_price_usd': 180.0,
        'necessity': 'optional',
        'alternatives': ['Bodyweight squats', 'Jump squats'],
        'image_url': 'https://via.placeholder.com/150x150/3F51B5/FFFFFF?text=Heavy+DB',
        'description': 'For weighted squats and advanced leg development.',
      },
    ],

    'hamstrings': [
      {
        'id': 'dumbbells_heavy',
        'name': 'Heavy Dumbbells (15-35kg)',
        'category': 'weights',
        'base_price_usd': 180.0,
        'necessity': 'optional',
        'alternatives': ['Bodyweight lunges', 'Single-leg deadlifts'],
        'image_url': 'https://via.placeholder.com/150x150/3F51B5/FFFFFF?text=Heavy+DB',
        'description': 'Perfect for Romanian deadlifts and hamstring curls.',
      },
    ],

    'glutes': [
      {
        'id': 'resistance_bands_loop',
        'name': 'Mini Loop Bands Set',
        'category': 'accessories',
        'base_price_usd': 15.0,
        'necessity': 'recommended',
        'alternatives': ['Bodyweight squats', 'Lunges'],
        'image_url': 'https://via.placeholder.com/150x150/E91E63/FFFFFF?text=Loop+Band',
        'description': 'Excellent for glute activation and targeted strengthening.',
      },
    ],

    'calves': [
      {
        'id': 'calf_raise_block',
        'name': 'Calf Raise Platform',
        'category': 'equipment',
        'base_price_usd': 40.0,
        'necessity': 'optional',
        'alternatives': ['Stairs', 'Books', 'Curb'],
        'image_url': 'https://via.placeholder.com/150x150/8BC34A/FFFFFF?text=Platform',
        'description': 'Increases range of motion for effective calf training.',
      },
    ],

    'forearms': [
      {
        'id': 'grip_strengthener',
        'name': 'Hand Grip Strengthener',
        'category': 'accessories',
        'base_price_usd': 8.0,
        'necessity': 'optional',
        'alternatives': ['Squeeze ball', 'Towel twists'],
        'image_url': 'https://via.placeholder.com/150x150/607D8B/FFFFFF?text=Grip',
        'description': 'Portable tool for forearm and grip strength development.',
      },
    ],
  };

   static List<CurrencyRate> _cachedRates = [];
  static DateTime? _cacheTime;
  static const Duration _cacheTimeout = Duration(hours: 6);


  static Future<List<EquipmentModel>> getEquipmentForMuscle(String muscle) async {
    try {
      final muscleKey = muscle.toLowerCase().trim();
      final equipmentData = _exerciseEquipmentMap[muscleKey] ?? [];
      
      if (equipmentData.isEmpty) {
        // Return generic equipment for unmapped muscles
        return [
          EquipmentModel(
            id: 'yoga_mat',
            name: 'Exercise Mat (6mm)',
            category: 'accessories',
            basePriceUSD: 12.0,
            necessity: 'recommended',
            alternatives: ['Towel', 'Floor'],
            imageUrl: 'https://via.placeholder.com/150x150/607D8B/FFFFFF?text=Mat',
            description: 'Comfortable surface for floor exercises.',
          ),
        ];
      }
      
      return equipmentData.map((data) => EquipmentModel.fromJson(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting equipment for muscle: $e');
      }
      return [];
    }
  }

  // **UPDATED: Use existing ApiService.getCurrencyRates method**
  static Future<List<CurrencyRate>> getCurrencyRates() async {
    // Check cache first
    if (_cachedRates.isNotEmpty && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheTimeout) {
      return _cachedRates;
    }

    try {
      if (kDebugMode) {
        debugPrint('Fetching fresh currency rates using existing API...');
      }
      
      // **USE EXISTING API SERVICE METHOD**
      final response = await ApiService.getCurrencyRates('USD');
      
      if (response['success'] == true && response['conversion_rates'] != null) {
        final rates = response['conversion_rates'] as Map<String, dynamic>;
        
        final supportedCurrencies = [
          {'code': 'IDR', 'symbol': 'Rp', 'flag': '🇮🇩'},
          {'code': 'USD', 'symbol': '\$', 'flag': '🇺🇸'},
          {'code': 'EUR', 'symbol': '€', 'flag': '🇪🇺'},
          {'code': 'GBP', 'symbol': '£', 'flag': '🇬🇧'},
        ];
        
        _cachedRates = supportedCurrencies.map((currency) {
          final rate = currency['code'] == 'USD' 
              ? 1.0 
              : (rates[currency['code']] ?? 1.0).toDouble();
          
          return CurrencyRate(
            code: currency['code']!,
            symbol: currency['symbol']!,
            rate: rate,
            flag: currency['flag']!,
          );
        }).toList();
        
        _cacheTime = DateTime.now();
        
        if (kDebugMode) {
          debugPrint('Currency rates updated successfully:');
          for (final rate in _cachedRates) {
            debugPrint('  ${rate.flag} ${rate.code}: ${rate.rate}');
          }
        }
        
        return _cachedRates;
      } else {
        throw Exception('Invalid currency API response');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching currency rates: $e');
      }
      
      // **FALLBACK: Return static rates if API fails**
      _cachedRates = [
        CurrencyRate(code: 'IDR', symbol: 'Rp', rate: 15000.0, flag: '🇮🇩'),
        CurrencyRate(code: 'USD', symbol: '\$', rate: 1.0, flag: '🇺🇸'),
        CurrencyRate(code: 'EUR', symbol: '€', rate: 0.85, flag: '🇪🇺'),
        CurrencyRate(code: 'GBP', symbol: '£', rate: 0.73, flag: '🇬🇧'),
      ];
      
      if (kDebugMode) {
        debugPrint('Using fallback currency rates');
      }
      
      return _cachedRates;
    }
  }

  static String formatPrice(double priceUSD, CurrencyRate currency) {
    final convertedPrice = priceUSD * currency.rate;
    
    switch (currency.code) {
      case 'IDR':
        // Format IDR dengan proper thousand separators
        final formattedAmount = convertedPrice.toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
              (Match m) => '${m[1]}.'
            );
        return '${currency.flag} ${currency.symbol}$formattedAmount';
        
      case 'USD':
      case 'EUR':
      case 'GBP':
        return '${currency.flag} ${currency.symbol}${convertedPrice.toStringAsFixed(0)}';
        
      default:
        return '${currency.flag} ${currency.symbol}${convertedPrice.toStringAsFixed(2)}';
    }
  }

  static void clearCache() {
    _cachedRates.clear();
    _cacheTime = null;
    if (kDebugMode) {
      debugPrint('✅ Equipment service cache cleared');
    }
  }

  // **OPTIONAL: Method to get fresh rates and update cache**
  static Future<void> refreshCurrencyRates() async {
    clearCache();
    await getCurrencyRates();
  }

  // **OPTIONAL: Get specific currency rate**
  static Future<CurrencyRate?> getCurrencyRate(String currencyCode) async {
    final rates = await getCurrencyRates();
    try {
      return rates.firstWhere(
        (rate) => rate.code.toUpperCase() == currencyCode.toUpperCase()
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Currency $currencyCode not found');
      }
      return null;
    }
  }

  // **BONUS: Convert price from one currency to another**
  static Future<String> convertPrice(
    double amount, 
    String fromCurrency, 
    String toCurrency
  ) async {
    try {
      final rates = await getCurrencyRates();
      final fromRate = rates.firstWhere((r) => r.code == fromCurrency);
      final toRate = rates.firstWhere((r) => r.code == toCurrency);
      
      // Convert to USD first, then to target currency
      final amountInUSD = amount / fromRate.rate;
      final convertedAmount = amountInUSD * toRate.rate;
      
      return formatPrice(convertedAmount / toRate.rate, toRate);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error converting $amount from $fromCurrency to $toCurrency: $e');
      }
      return 'Error';
    }
  }
}