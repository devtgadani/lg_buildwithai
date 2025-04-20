import 'package:flutter/material.dart';
import 'geminidev.dart';

class Tourist_Place extends StatefulWidget {
  @override
  _TouristPlaceState createState() => _TouristPlaceState();
}

class _TouristPlaceState extends State<Tourist_Place> {
  final GeminiI gsd = GeminiI();
  final TextEditingController _searchController = TextEditingController();
  String _searchTourist = '';
  List _places = [];
  bool _isLoading = false;
  String _selectedDescription = '';
  String _polygonData = '';

  Future _searchPlaces(String query) async {
    setState(() {
      _isLoading = true;
      _searchTourist = query;
      _selectedDescription = '';
      _polygonData = '';
    });
    final results = await gsd.generateContent(query: query, topic: 'tourist');
    setState(() {
      _places = results;
      _isLoading = false;
    });
  }

Future _getKMLData(String placeName, double lan, double lat) async {
  setState(() {
    _isLoading = true;
  });

  final kmlResponse = await gsd.generateContent(
    query: placeName,
    lan: lan,
    lat: lat,
    topic: 'kml',
  );

  print("🌍 Full KML Response: $kmlResponse");

  if (kmlResponse is Map<String, dynamic>) {
    setState(() {
      _selectedDescription = kmlResponse['description']?.toString() ?? 'No description available';
      _polygonData = kmlResponse['polygon']?.toString() ?? 'No polygon data available';
    });
  } else {
    print("🌍 No valid KML data found for $placeName");
    setState(() {
      _selectedDescription = 'No description available';
      _polygonData = 'No polygon data available';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onSubmitted: _searchPlaces,
            decoration: InputDecoration(
              labelText: "Search Tourist Places",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (_isLoading)
          Center(child: CircularProgressIndicator())
        else if (_places.isEmpty && _searchTourist.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("No results found for '$_searchTourist'"),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (BuildContext context, int index) {
                final place = _places[index];
                return GestureDetector(
                  onTap: () => _getKMLData(place['name'] , place['lat'], place['lan']),
                  child: Card(
                    margin: EdgeInsets.all(10.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${index + 1}. ${place['name'] ?? ''}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Related to: $_searchTourist",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 12),
                          Text(
                            place['des'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.redAccent),
                              SizedBox(width: 6),
                              Text("Lat: ${place['lat']} | Lon: ${place['lan']}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (_selectedDescription.isNotEmpty || _polygonData.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📍 KML Description", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(_selectedDescription),
                    SizedBox(height: 16),
                    Text("🗺️ Polygon KML", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(_polygonData),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
