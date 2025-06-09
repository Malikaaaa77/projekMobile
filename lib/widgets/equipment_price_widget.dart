import 'package:flutter/material.dart';
import '../models/equipment_model.dart';
import '../services/equipment_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EquipmentPriceWidget extends StatefulWidget {
  const EquipmentPriceWidget({
    super.key,
    required this.muscle,
  });

  final String muscle;

  @override
  State<EquipmentPriceWidget> createState() => _EquipmentPriceWidgetState();
}

class _EquipmentPriceWidgetState extends State<EquipmentPriceWidget> {
  List<EquipmentModel> _equipment = [];
  List<CurrencyRate> _currencies = [];
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadEquipmentData();
  }

  Future<void> _loadEquipmentData() async {
     print('DEBUG EquipmentPriceWidget muscle: ${widget.muscle}');
      setState(() => _isLoading = true);
      try {
    
      final equipment = await EquipmentService.getEquipmentForMuscle(widget.muscle);
      print('DEBUG Loaded equipment: $equipment');
      final currencies = await EquipmentService.getCurrencyRates();
      setState(() {
        _equipment = equipment;
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_equipment.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Equipment Recommendations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  if (_equipment.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_equipment.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...(_equipment.map((equipment) => _buildEquipmentCard(equipment))),
          ],
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: equipment.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fitness_center, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fitness_center, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildNecessityChip(equipment.necessity),
                        const SizedBox(width: 8),
                        Text(
                          equipment.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            equipment.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          if (_currencies.isNotEmpty) ...[
            const Text(
              'Price Comparison:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _currencies.map((currency) {
                final formattedPrice = EquipmentService.formatPrice(
                  equipment.basePriceUSD, currency);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    formattedPrice,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ],
          if (equipment.alternatives.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Free Alternatives:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green, // Gunakan warna solid
              ),
            ),
            const SizedBox(height: 4),
            Text(
              equipment.alternatives.join(', '),
              style: TextStyle(fontSize: 11, color: Colors.green[700]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNecessityChip(String necessity) {
    Color color;
    Color textColor;
    switch (necessity.toLowerCase()) {
      case 'required':
        color = Colors.red;
        textColor = Colors.red;
        break;
      case 'recommended':
        color = Colors.orange;
        textColor = Colors.orange;
        break;
      default:
        color = Colors.green;
        textColor = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30), // Ganti .withOpacity(0.1) -> .withAlpha(30)
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)), // Ganti .withOpacity(0.3) -> .withAlpha(80)
      ),
      child: Text(
        necessity.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}