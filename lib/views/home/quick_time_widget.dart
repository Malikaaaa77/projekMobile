import 'dart:async';
import 'package:flutter/material.dart';

/// Quick Time Reference Widget - MVP View Component
/// Menampilkan waktu real-time untuk timezone Indonesia dan GMT
/// Untuk user: Malikaaaa77
class QuickTimeWidget extends StatefulWidget {
  const QuickTimeWidget({super.key});

  @override
  State<QuickTimeWidget> createState() => _QuickTimeWidgetState();
}

class _QuickTimeWidgetState extends State<QuickTimeWidget> {
  late Timer _timer;
  Map<String, DateTime> _worldTimes = {};
  bool _isExpanded = false;

  // Timezone configurations - Indonesia + International
  final Map<String, Map<String, dynamic>> _timezones = {
    'WIB': {
      'offset': 7,
      'flag': '🇮🇩',
      'name': 'Jakarta',
      'color': Colors.blue[600],
      'cities': 'Jakarta, Medan, Palembang',
    },
    'WITA': {
      'offset': 8,
      'flag': '🇮🇩',
      'name': 'Makassar',
      'color': Colors.green[600],
      'cities': 'Makassar, Denpasar, Balikpapan',
    },
    'WIT': {
      'offset': 9,
      'flag': '🇮🇩',
      'name': 'Jayapura',
      'color': Colors.orange[600],
      'cities': 'Jayapura, Ambon, Manado',
    },
    'GMT': {
      'offset': 0,
      'flag': '🇬🇧',
      'name': 'London',
      'color': Colors.purple[600],
      'cities': 'London, Dublin, Lisbon',
    },
  };

  @override
  void initState() {
    super.initState();
    _updateWorldTimes();
    
    // Update every 30 seconds for battery efficiency
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _updateWorldTimes();
      }
    });
    
    // MVP Pattern: Log initialization
    print('[MVP] QuickTimeWidget initialized for user: Malikaaaa77');
  }

  @override
  void dispose() {
    _timer.cancel();
    print('[MVP] QuickTimeWidget disposed');
    super.dispose();
  }

  /// Update world times based on current UTC - Pure business logic
  void _updateWorldTimes() {
    // Current UTC: 2025-06-09 10:26:56
    final utcNow = DateTime.now().toUtc();
    
    setState(() {
      _worldTimes = {};
      _timezones.forEach((code, config) {
        _worldTimes[code] = utcNow.add(Duration(hours: config['offset']));
      });
    });

    // MVP Pattern: Business logic logging
    print('[MVP] QuickTimeWidget updated at UTC: ${utcNow.toString()}');
    
    // Debug current times
    _worldTimes.forEach((code, time) {
      print('  $code: ${_formatTime(time, false)}');
    });
  }

  /// Format time for display - View presentation logic
  String _formatTime(DateTime dateTime, bool showSeconds) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    if (showSeconds) {
      final second = dateTime.second.toString().padLeft(2, '0');
      return '$hour:$minute:$second';
    }
    
    return '$hour:$minute';
  }

  /// Format date for display - View presentation logic
  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    
    return '$day $month';
  }

  /// Get background color based on time context - View logic
  Color _getTimeContextColor(DateTime dateTime) {
    final hour = dateTime.hour;
    
    if (hour >= 6 && hour < 12) {
      return Colors.blue[50]!; // Morning
    } else if (hour >= 12 && hour < 17) {
      return Colors.yellow[50]!; // Afternoon
    } else if (hour >= 17 && hour < 21) {
      return Colors.orange[50]!; // Evening
    } else {
      return Colors.indigo[50]!; // Night
    }
  }

  /// Handle user interaction - MVP View event handling
  void _handleToggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    // MVP Pattern: Log user interaction (could be sent to presenter)
    print('[MVP] QuickTimeWidget: User ${_isExpanded ? "expanded" : "collapsed"} view');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _handleToggleExpand,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          child: _isExpanded ? _buildExpandedView() : _buildCompactView(),
        ),
      ),
    );
  }

  /// Compact view - MVP View component
  Widget _buildCompactView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.schedule, size: 18, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              'QUICK TIME REFERENCE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.expand_more,
              size: 18,
              color: Colors.grey[600],
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Time displays in row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _timezones.keys.map((code) {
            final time = _worldTimes[code];
            final config = _timezones[code]!;
            
            if (time == null) return const SizedBox.shrink();
            
            return Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(config['flag'], style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 2),
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time, false),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: config['color'],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Expanded view - MVP View component
  Widget _buildExpandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.public, size: 18, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              'WORLD CLOCK',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Icon(Icons.expand_less, size: 18, color: Colors.grey[600]),
          ],
        ),
        const SizedBox(height: 16),
        
        // Detailed time displays
        ..._timezones.entries.map((entry) {
          final code = entry.key;
          final config = entry.value;
          final time = _worldTimes[code];
          
          if (time == null) return const SizedBox.shrink();
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTimeContextColor(time),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (config['color'] as Color).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Flag container
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (config['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(config['flag'], style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 12),
                
                // Location info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${config['name']} ($code)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(time),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Time display
                Text(
                  _formatTime(time, true),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: config['color'],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        
        const SizedBox(height: 8),
        
        // Footer
        Center(
          child: Text(
            'Tap to toggle • Updates every 30s • User: Malikaaaa77',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}