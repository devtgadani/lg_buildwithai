import 'package:flutter/material.dart';


class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80.0,
              backgroundImage: AssetImage('images/dev.jpg'),
            ),
            SizedBox(height: 16.0),
            Text(
            'Dev T Gadani  ', 
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Wanna Be GSoC 25  ', 
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('devtgadani2552@gmail.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('+91 999822579'), 
            ),
            ListTile(
               leading: Icon(Icons.description),
              title: Text('pursing degree at the gec , gandhinagar & and also work in lg-wiki develoment '), // Replace '+1 (123) 456-7890' with your phone number
            ),      
                ],
        ),
      ),
    );
  }
}
