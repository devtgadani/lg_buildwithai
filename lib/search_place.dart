import 'package:flutter/material.dart';

class Search_Place extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Search_Place> {
  String _searchText = '';
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange[300],
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSearchField(),
          SizedBox(height: 20),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search Place',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search),
      ),
      // onChanged: (value) {
      //   setState(() {
      //     _searchText = value;
      //   });
      // },
          onSubmitted: (value) {
        setState(() {
          _searchText = value;
        });}
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place Info',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Search Text: $_searchText',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Name: Example Place',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Description: Some description about the place.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Latitude: 0.0',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Longitude: 0.0',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

 


class Place {
  final String name;
  final String description;
  final double longitude;
  final double latitude;

  Place({required this.name, required this.description, required this.longitude, required this.latitude});
}
