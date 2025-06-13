import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GymFinderView extends StatefulWidget {
  const GymFinderView({super.key});

  @override
  GymFinderViewState createState() => GymFinderViewState();
}

class GymFinderViewState extends State<GymFinderView> {
  Position? _currentPosition;
  bool _isLoading = false;
  String _locationStatus = 'Tap button to get your location';

  // Mock gym data - in real app this would come from Google Places API
  final List<Map<String, dynamic>> _nearbyGyms = [
    {
      'name': 'FitLife Gym',
      'distance': '0.5 km',
      'rating': 4.5,
      'address': 'Jl. Sudirman No. 123',
      'type': 'Fitness Center',
      'isOpen': true,
    },
    {
      'name': 'PowerHouse Fitness',
      'distance': '1.2 km',
      'rating': 4.3,
      'address': 'Jl. Thamrin No. 456',
      'type': 'Gym & Boxing',
      'isOpen': true,
    },
    {
      'name': 'Golds Gym',
      'distance': '1.8 km',
      'rating': 4.7,
      'address': 'Jl. Gatot Subroto No. 789',
      'type': 'Premium Gym',
      'isOpen': false,
    },
    {
      'name': 'Anytime Fitness',
      'distance': '2.1 km',
      'rating': 4.2,
      'address': 'Jl. Kuningan No. 321',
      'type': '24 Hours Gym',
      'isOpen': true,
    },
    {
      'name': 'Celebrity Fitness',
      'distance': '2.5 km',
      'rating': 4.4,
      'address': 'Mall Central Park Lt. 3',
      'type': 'Mall Gym',
      'isOpen': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Finder'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[700]!, Colors.green[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _currentPosition != null ? Icons.location_on : Icons.location_off,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _locationStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_currentPosition != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Get Location Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  _isLoading ? 'Getting Location...' : 'Get My Location',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nearby Gyms Section
            Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Nearby Gyms & Fitness Centers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Gyms List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _nearbyGyms.length,
              itemBuilder: (context, index) {
                final gym = _nearbyGyms[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: gym['isOpen'] ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        Icons.fitness_center,
                        color: gym['isOpen'] ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    title: Text(
                      gym['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(gym['distance']),
                            const SizedBox(width: 16),
                            Icon(Icons.star, size: 16, color: Colors.orange[600]),
                            const SizedBox(width: 4),
                            Text('${gym['rating']}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gym['address'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: gym['isOpen'] ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: gym['isOpen'] ? Colors.green[300]! : Colors.red[300]!,
                                ),
                              ),
                              child: Text(
                                gym['isOpen'] ? 'Open' : 'Closed',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: gym['isOpen'] ? Colors.green[700] : Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              gym['type'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.directions,
                      color: Colors.green[600],
                    ),
                    onTap: () => _showGymDetails(gym),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Info Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Distances are calculated from your current location. Tap on a gym for more details.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationStatus = 'Getting your location...';
    });

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'Location services are disabled. Please enable GPS.';
          _isLoading = false;
        });
        return;
      }

      // Check location permissions
      var permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
        if (permission.isDenied) {
          setState(() {
            _locationStatus = 'Location permission denied. Please allow location access.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission.isPermanentlyDenied) {
        setState(() {
          _locationStatus = 'Location permission permanently denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationStatus = 'Location found successfully!';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _locationStatus = 'Failed to get location: ${e.toString()}';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGymDetails(Map<String, dynamic> gym) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gym['name']),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Distance', gym['distance']),
            _buildDetailRow('Rating', '${gym['rating']} ⭐'),
            _buildDetailRow('Type', gym['type']),
            _buildDetailRow('Address', gym['address']),
            _buildDetailRow('Status', gym['isOpen'] ? 'Open' : 'Closed'),
            const SizedBox(height: 12),
            const Text(
              'Services:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Weight Training\n• Cardio Equipment\n• Group Classes\n• Personal Training'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening directions to ${gym['name']}...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text('Get Directions', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
}