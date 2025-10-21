import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _breakfastTimeController = TextEditingController(
    text: "7:00 AM - 8:30 AM",
  );
  final TextEditingController _lunchTimeController = TextEditingController(
    text: "12:30 PM - 2:00 PM",
  );
  final TextEditingController _dinnerTimeController = TextEditingController(
    text: "7:00 PM - 9:00 PM",
  );
  final TextEditingController _roomTimeController = TextEditingController(
    text: "4:30 PM - 5:00 PM",
  );

  String _mood = 'romantic';
  List<String> _selectedActivities = [];
  List<String> _selectedMeals = [];
  bool _needsRoom = false;
  String _roomType = 'Suite';
  Map<String, dynamic>? _generatedData;
  Map<String, dynamic>? _apiResponse;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _moods = [
    {
      'value': 'romantic',
      'label': 'Romantic',
      'emoji': '💕',
      'color': Colors.pink,
    },
    {'value': 'fun', 'label': 'Fun', 'emoji': '🎉', 'color': Colors.orange},
    {
      'value': 'adventurous',
      'label': 'Adventurous',
      'emoji': '🗺️',
      'color': Colors.red,
    },
    {'value': 'chill', 'label': 'Chill', 'emoji': '😌', 'color': Colors.blue},
  ];

  final List<String> _activityOptions = [
    'Walk',
    'Picnic',
    'Cinema',
    'Park Stroll',
    'Shopping',
    'Coffee Shop',
    'Beach Walk',
    'Concert',
    'Restaurant',
  ];

  final List<String> _mealOptions = ['breakfast', 'lunch', 'dinner'];
  final List<String> _roomTypes = ['Standard', 'Deluxe', 'Suite', 'Executive'];

  void _toggleActivity(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else {
        _selectedActivities.add(activity);
      }
    });
  }

  void _toggleMeal(String meal) {
    setState(() {
      if (_selectedMeals.contains(meal)) {
        _selectedMeals.remove(meal);
      } else {
        _selectedMeals.add(meal);
      }
    });
  }

  Future<void> _generatePlan() async {
    if (_cityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a city name')));
      return;
    }

    if (_selectedActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one activity')),
      );
      return;
    }

    if (_selectedMeals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one meal')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _apiResponse = null;
    });

    // Create preferences in the exact JSON format
    final Map<String, dynamic> preferences = {
      'mood': _mood,
      'activities': _selectedActivities,
      'city': _cityController.text,
      'meals': _selectedMeals,
      'meal_times': {
        if (_selectedMeals.contains('breakfast'))
          'breakfast': _breakfastTimeController.text,
        if (_selectedMeals.contains('lunch'))
          'lunch': _lunchTimeController.text,
        if (_selectedMeals.contains('dinner'))
          'dinner': _dinnerTimeController.text,
      },
      'want_room': _needsRoom,
      'room_type': _roomType,
      'room_timing': _roomTimeController.text,
    };

    try {
      // Send data to API
      final response = await http.post(
        Uri.parse('https://ai-dating-planer-app.onrender.com/generate-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(preferences),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _apiResponse = responseData;
          _generatedData = preferences;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date plan generated successfully! 💕'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to generate plan');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMoodCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = screenWidth < 600 ? 2 : 4;
        final childAspectRatio = screenWidth < 600 ? 2.5 : 2.0;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mood,
                      color: Colors.pink[600],
                      size: screenWidth < 600 ? 20 : 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'What\'s the vibe?',
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    final isSelected = _mood == mood['value'];
                    return GestureDetector(
                      onTap: () => setState(() => _mood = mood['value']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? mood['color'].withOpacity(0.1)
                              : Colors.grey[100],
                          border: Border.all(
                            color: isSelected
                                ? mood['color']
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mood['emoji'],
                              style: TextStyle(
                                fontSize: screenWidth < 600 ? 20 : 24,
                              ),
                            ),
                            SizedBox(height: screenWidth < 600 ? 2 : 4),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth < 600 ? 12 : 14,
                                color: isSelected
                                    ? mood['color']
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitiesCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.purple[600],
                      size: screenWidth < 600 ? 20 : 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Activities you\'d love',
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: screenWidth < 600 ? 6 : 8,
                  runSpacing: screenWidth < 600 ? 6 : 8,
                  children: _activityOptions.map((activity) {
                    final isSelected = _selectedActivities.contains(activity);
                    return GestureDetector(
                      onTap: () => _toggleActivity(activity),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 600 ? 12 : 16,
                          vertical: screenWidth < 600 ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          activity,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth < 600 ? 12 : 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealsCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.orange[600],
                      size: screenWidth < 600 ? 20 : 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'When do you want to eat?',
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: screenWidth < 600 ? 6 : 8,
                  runSpacing: screenWidth < 600 ? 6 : 8,
                  children: _mealOptions.map((meal) {
                    final isSelected = _selectedMeals.contains(meal);
                    return GestureDetector(
                      onTap: () => _toggleMeal(meal),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 600 ? 12 : 16,
                          vertical: screenWidth < 600 ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          meal.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth < 600 ? 12 : 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Meal Times
                if (_selectedMeals.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Meal Times:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth < 600 ? 14 : 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isTablet && _selectedMeals.length > 1)
                    // For tablets, show meal times in a row layout
                    Column(
                      children: [
                        if (_selectedMeals.contains('breakfast') &&
                            _selectedMeals.contains('lunch'))
                          Row(
                            children: [
                              if (_selectedMeals.contains('breakfast'))
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: TextField(
                                      controller: _breakfastTimeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Breakfast Time',
                                        prefixIcon: Icon(Icons.free_breakfast),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_selectedMeals.contains('lunch'))
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: TextField(
                                      controller: _lunchTimeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Lunch Time',
                                        prefixIcon: Icon(Icons.lunch_dining),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        if (_selectedMeals.contains('dinner')) ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: _dinnerTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Dinner Time',
                              prefixIcon: Icon(Icons.dinner_dining),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    // For mobile, show in column layout
                    Column(
                      children: [
                        if (_selectedMeals.contains('breakfast')) ...[
                          TextField(
                            controller: _breakfastTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Breakfast Time',
                              prefixIcon: Icon(Icons.free_breakfast),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (_selectedMeals.contains('lunch')) ...[
                          TextField(
                            controller: _lunchTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Lunch Time',
                              prefixIcon: Icon(Icons.lunch_dining),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (_selectedMeals.contains('dinner')) ...[
                          TextField(
                            controller: _dinnerTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Dinner Time',
                              prefixIcon: Icon(Icons.dinner_dining),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomCard() {
    // Show room selection for all moods
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.hotel,
                            color: Colors.red[600],
                            size: screenWidth < 600 ? 20 : 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Need accommodation?',
                              style: TextStyle(
                                fontSize: screenWidth < 600 ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _needsRoom,
                      onChanged: (value) => setState(() => _needsRoom = value),
                      activeColor: Colors.red[600],
                    ),
                  ],
                ),
                if (_needsRoom) ...[
                  const SizedBox(height: 16),
                  if (isTablet)
                    // For tablets, show room type and timing in a row
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: DropdownButtonFormField<String>(
                              value: _roomType,
                              decoration: const InputDecoration(
                                labelText: 'Room Type',
                                border: OutlineInputBorder(),
                              ),
                              items: _roomTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _roomType = value!),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextField(
                              controller: _roomTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Room Timing',
                                prefixIcon: Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // For mobile, show in column
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _roomType,
                          decoration: const InputDecoration(
                            labelText: 'Room Type',
                            border: OutlineInputBorder(),
                          ),
                          items: _roomTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _roomType = value!),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _roomTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Room Timing',
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApiResponseCard() {
    if (_apiResponse == null) return const SizedBox.shrink();

    final generatedPlan =
        _apiResponse!['generated_plan'] as Map<String, dynamic>;
    final activities = generatedPlan.entries.toList();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.pink[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Your Perfect Date Plan 💕',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Activities
            ...activities.map((entry) {
              final activityData = entry.value as Map<String, dynamic>;
              final index = activities.indexOf(entry);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Activity number and title
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getActivityColor(index),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            activityData['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Timing
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activityData['timing'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Details
                    Text(
                      activityData['details'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Location
                    if (activityData['location name'] != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.red[400],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activityData['location name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Room location if available
                    if (activityData['Room Location'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.hotel,
                            size: 16,
                            color: Colors.purple[400],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activityData['Room Location'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.purple[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _apiResponse = null;
                        _generatedData = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[100],
                      foregroundColor: Colors.pink[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Create New Plan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plan saved to favorites! 💕'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: const Icon(Icons.favorite),
                    label: const Text('Save Plan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(int index) {
    final colors = [Colors.pink, Colors.purple, Colors.orange];
    return colors[index % colors.length];
  }

  Widget _buildGeneratedDataCard() {
    if (_generatedData == null) return const SizedBox.shrink();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.pink[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.pink[600], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Your Perfect Date Plan 💕',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDataRow('🏙️ City', _generatedData!['city']),
                  _buildDataRow(
                    '😊 Mood',
                    _generatedData!['mood'].toString().toUpperCase(),
                  ),
                  _buildDataRow(
                    '🎯 Activities',
                    (_generatedData!['activities'] as List).join(', '),
                  ),
                  _buildDataRow(
                    '🍽️ Meals',
                    (_generatedData!['meals'] as List).join(', '),
                  ),
                  if ((_generatedData!['meal_times'] as Map).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '⏰ Meal Times:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    ...(_generatedData!['meal_times'] as Map).entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                  ],
                  if (_generatedData!['want_room']) ...[
                    const SizedBox(height: 8),
                    _buildDataRow('🏨 Room', _generatedData!['room_type']),
                    _buildDataRow(
                      '🕐 Room Time',
                      _generatedData!['room_timing'],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _generatedData = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[100],
                  foregroundColor: Colors.pink[700],
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Create New Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final maxWidth = isTablet ? 800.0 : screenWidth;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF2F8), // Very light pink
              Color(0xFFFCE7F3), // Light pink
              Color(0xFFF3E8FF), // Light purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.pink,
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Let\'s Plan Your Date',
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: isTablet ? 52 : 48),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell us what makes your perfect day together',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isTablet ? 18 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 16,
                      ),
                      child: Column(
                        children: [
                          _buildMoodCard(),
                          SizedBox(height: isTablet ? 20 : 16),
                          _buildActivitiesCard(),
                          SizedBox(height: isTablet ? 20 : 16),
                          _buildMealsCard(),
                          SizedBox(height: isTablet ? 20 : 16),
                          _buildRoomCard(),
                          SizedBox(height: isTablet ? 20 : 16),

                          // Generated Data Display
                          _buildGeneratedDataCard(),
                          SizedBox(height: isTablet ? 20 : 16),

                          // API Response Display
                          _buildApiResponseCard(),
                          SizedBox(height: isTablet ? 20 : 16),

                          // City Input
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isTablet ? 24 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.green[600],
                                        size: isTablet ? 28 : 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Where are you?',
                                          style: TextStyle(
                                            fontSize: isTablet ? 20 : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _cityController,
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your city (e.g., Theni)',
                                      prefixIcon: Icon(
                                        Icons.location_city,
                                        size: isTablet ? 24 : 20,
                                      ),
                                      border: const OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: isTablet ? 20 : 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isTablet ? 32 : 24),

                          // Generate Button
                          SizedBox(
                            width: double.infinity,
                            height: isTablet ? 64 : 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _generatePlan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isLoading
                                    ? Colors.grey
                                    : Colors.pink,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 32 : 28,
                                  ),
                                ),
                                elevation: 8,
                              ),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Generating Plan...',
                                          style: TextStyle(
                                            fontSize: isTablet ? 18 : 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Generate My Date Plan',
                                          style: TextStyle(
                                            fontSize: isTablet ? 20 : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.auto_awesome,
                                          size: isTablet ? 28 : 24,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          SizedBox(height: isTablet ? 20 : 16),

                          // Back Button
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Back to Home',
                              style: TextStyle(fontSize: isTablet ? 18 : 16),
                            ),
                          ),

                          SizedBox(height: isTablet ? 32 : 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _breakfastTimeController.dispose();
    _lunchTimeController.dispose();
    _dinnerTimeController.dispose();
    _roomTimeController.dispose();
    super.dispose();
  }
}
