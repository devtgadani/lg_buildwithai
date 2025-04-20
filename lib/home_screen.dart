// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import '/ssh.dart';
// import '/connection_flag.dart';
// import '/reusable_card.dart';
// bool connectionStatus = false;

// const String searchPalce = 'Khadia';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late SSH ssh;

//   @override
//   void initState() {
//     super.initState();
//     ssh = SSH();
//     _connectToLG();
//   }

//   Future<void> _connectToLG() async {
//   bool? result = await ssh.connectToLG();
//     setState(() {
//       connectionStatus = result!;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Task 2 Dev T Gadani',
//           style: TextStyle(fontSize: 40,
//            color: Colors.white,),
         
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(
//               Icons.settings,
//               size: 50,
//               color: Colors.white,
//             ),
//             onPressed: () async {
//               await Navigator.pushNamed(context, '/settings');
//               _connectToLG();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           SizedBox(height: 65),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Container(
//                 height: 300,
//                 child: Image.asset('assets/lg.png')
//               ),
//             ),
//           Column(
//             children: [
//               Wrap(
//                 alignment: WrapAlignment.center,

//                 // mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ReusableCard(
//                     colour: Color(0XFF3629B7),
//                     onPress: () async {
//                       // await ssh.relaunchLG();
//                       showDialog(
//                           context: context,
//                           builder: (context) {
//                             return AlertDialog(
//                               title: Text('Relaunching rig',style: TextStyle(fontSize: 40, color: Colors.green),),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                   BorderRadius.all(Radius.circular(10.0))),
                             
//                               actions: [
//                                 TextButton(
//                                    onPressed: () async {
//                                     await ssh.relaunchLG();
//                                    },
//                                     child: Text(
//                                       'Ok',
//                                       style: TextStyle(fontSize: 40),
//                                     ))
//                               ],
//                             );
//                           });
//                     },
//                     iconData: Icons.restart_alt,
//                     cardChild: const Center(
//                       child: Text(
//                         'Relaunch IG',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   ReusableCard(
//                     colour: Color(0XFF3629B7),
//                     onPress: () async {
//                       await ssh.cleanrig();
//                     },
//                     iconData: Icons.cleaning_services_rounded,
//                     cardChild: const Center(
//                       child: Text(
//                         'clean kml',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   ReusableCard(
//                     colour: Color(0XFF3629B7),
//                     onPress: () async {
//                       await ssh.playOrbit();
//                     },
//                     iconData: Icons.circle_outlined,
//                     cardChild: const Center(
//                       child: Text(
//                         'Orbit ',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               //
//               Wrap(
//                 alignment: WrapAlignment.center,
//                 children: [
//                   ReusableCard(
//                     colour: Color(0XFF3629B7),
//                     onPress: () async {
//                        showDialog(
//                           context: context,
//                           builder: (context) {
//                             return AlertDialog(
//                               title: Text('rebooting rig',style: TextStyle(fontSize: 40, color: Colors.green),),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                   BorderRadius.all(Radius.circular(10.0))),
                             
//                               actions: [
//                                 TextButton(
//                                    onPressed: () async {
//                                     await ssh.rebootlg();
//                                    },
//                                     child: Text(
//                                       'Ok',
//                                       style: TextStyle(fontSize: 40),
//                                     ))
//                               ],
//                             );
//                           });
//                     },
//                     iconData: Icons.restart_alt,
//                     cardChild: const Center(
//                       child: Text(
//                         'Reboot IG',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   ReusableCard(
//                     colour: Color(0XFF3629B7),
//                     onPress: () async {
//                       await ssh.search(searchPalce);
//                     },
//                     iconData: Icons.search,
//                     cardChild: const Center(
//                       child: Text(
//                         'my Home City',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   ReusableCard(
//                     colour: Color(0XFF3629B7),
//                     onPress: () async {
//                       await ssh.sendKml();
//                     },
//                     iconData: Icons.send,
//                     cardChild: const Center(
//                       child: Text(
//                         'Send KML',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
