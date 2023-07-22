import 'package:flutter/material.dart';
import 'package:school_ifi/Users.dart';
import 'package:school_ifi/exam%20update.dart';
import 'package:school_ifi/updateFees.dart';
import 'Models/services.dart';
import 'Models/models.dart';



class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        currentUser: AppUser(
          uid: '1',
          name: 'John Doe',
          email: 'johndoe@example.com',
          className: '4 west',
          schoolName: 'schoolfi',
          role: Role.admin,
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final AppUser currentUser;

  const MyHomePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      drawer: DrawerMenu(currentUser: currentUser),
      body: Center(
        child: Text('Welcome, ${currentUser.name}!'),
      ),
    );
  }
}

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key, required this.currentUser}) : super(key: key);

  final AppUser currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(currentUser.name),
            accountEmail: Text(currentUser.email),
            currentAccountPicture: CircleAvatar(
              child: Text(currentUser.name.substring(0, 1)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Admin Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminDashboard(adminEmail: currentUser.email),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Student Exam Records'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamScreen(
                    currentUser: currentUser, // replace with your AppUser object
                    dbService: FirebaseFirestoreService(), // replace with your db service object
                    users: [], // replace with the list of users
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text('Fees'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FeesScreen(currentUser: currentUser),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Logout
              Navigator.of(context)
                  .pushReplacementNamed('/login'); // Redirect to login screen
            },
          ),
        ],
      ),
    );
  }
}











