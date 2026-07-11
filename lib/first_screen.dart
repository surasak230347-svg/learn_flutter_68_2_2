import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_flutter_68_2_2/services/filestore.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _timer(context);
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (!mounted) {
      return;
    }

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      _showToast('Mobile network available');
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      _showToast('Wi-Fi available');
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      _showToast('Ethernet available');
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      _showToast('VPN active');
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      _showToast('Bluetooth connection available');
    } else if (connectivityResult.contains(ConnectivityResult.satellite)) {
      _showToast('Satellite network available');
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      _showToast('Other network available');
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      _showToast('No network available');
    }
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.lightGreenAccent,
      textColor: Colors.black,
      fontSize: 24,
    );
  }

  void _timer(BuildContext context) {
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SecondScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.cyanAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          tileMode: TileMode.mirror,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(child: Image.asset('android/assets/image/app_screen.png')),
          const SizedBox(height: 20),
          const SpinKitSpinningLines(color: Colors.pinkAccent),
        ],
      ),
    );
  }
}


// class SecondScreen extends StatelessWidget {
//   const SecondScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Second Screen')),
//       body: const Center(
//         child: Text(
//           'This is a second screen.',
//           style: TextStyle(
//             fontSize: 24,
//             color: Colors.amberAccent,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Alike',
//           ),
//         ),
//       ),
//     );
//   }
// }
class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
 final FirestoreService firestoreService = FirestoreService();

 final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  void openPersonBox(String? personID) async {
    Map<String, dynamic>? person;
    if (personID != null) {
      person = await firestoreService.getPersonById(personID);
      nameController.text = person?['personName'] ?? '';
      emailController.text = person?['personEmail'] ?? '';
      ageController.text = person?['personAge']?.toString() ?? '';
    } else {
      nameController.clear();
      emailController.clear();
      ageController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final String name = nameController.text;
              final String email = emailController.text;
              final int age = int.tryParse(ageController.text) ?? 0;

              if (personID != null) {
                firestoreService.updatePerson(personID, name, email, age);
              } else {
                firestoreService.addPerson(name, email, age);
              }
              nameController.clear();
              emailController.clear();
              ageController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPersons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          final persons = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              final personData = person.data() as Map<String, dynamic>;
              final personName = personData['personName'] ?? '';
              final personEmail = personData['personEmail'] ?? '';
              final personAge = personData['personAge'] ?? 0;
              return ListTile(
                title: Text(personName),
                subtitle: Text('$personEmail, Age: $personAge'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => openPersonBox(person.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => firestoreService.deletePerson(person.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openPersonBox(null),
        child: const Icon(Icons.add),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openPersonBox(null),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPersons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }
         body: SteramBuilder<QuerySnapshot>(
        stream: firestoreService.getPersons(),
        builder: (context, snapshot) 
        if(sapshot.hashData) {
          final persons = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) 

            DocumentSnapshot person = persons[index];
            String personId = person.id;
            Map<String, dynamic> personData = person.data() as Map<String, dynamic>;
            String personName = personData['personName'] ?? '';
            String personEmail = personData['personEmail'] ?? '';
            int personAge = personData['personAge'] ?? 0;
            return ListTile(
              title: Text(personName),
              subtitle: Text('$personEmail, Age: $personAge'),
                  ],
                ),
              
            },
          );
        },
      ),
  };

}
