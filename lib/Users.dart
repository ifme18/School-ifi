import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Models/models.dart';

class AdminDashboard extends StatefulWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String adminEmail;

  AdminDashboard({Key? key, required this.adminEmail}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('users');
  List<AppUser> _filteredUsers = [];

  bool _loading = false;
  String? _currentUserSchool;

  @override
  void initState() {
    super.initState();
    getUserSchool();
  }

  Future<void> getUserSchool() async {
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(widget._auth.currentUser!.uid);
    await userRef.get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        _currentUserSchool = documentSnapshot.get('schoolName');
      } else {
        _currentUserSchool = null;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      AppUser newUser = AppUser(
        uid: '',
        name: _nameController.text,
        email: _emailController.text,
        className: _classNameController.text,
        role: Role.teacher,
        schoolName: _currentUserSchool!,
      );

      await _userCollection.add(newUser.toJson());

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully')),
      );
    }
  }

  Future<void> filterUsersBySchool() async {
    setState(() {
      _loading = true;
      _filteredUsers.clear();
    });

    QuerySnapshot querySnapshot = await _userCollection
        .where('schoolName', isEqualTo: _currentUserSchool!)
        .get();

    querySnapshot.docs.forEach((doc) {
      final Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      AppUser user = AppUser.fromJson(userData);
      _filteredUsers.add(user);
    });

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _classNameController,
                      decoration: const InputDecoration(
                        labelText: 'Class Name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a class name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _loading ? null : registerUser,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Register User'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _loading ? null : filterUsersBySchool,
                child:
                _loading ? const CircularProgressIndicator() : const Text('Filter Users'),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Filtered Users:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              if (_filteredUsers.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    AppUser user = _filteredUsers[index];
                    return ListTile(
                      title: Text('Name: ${user.name}'),
                      subtitle: Text('Email: ${user.email}'),
                      trailing: Text('Class Name: ${user.className}'),
                    );
                  },
                ),
              if (_filteredUsers.isEmpty && !_loading)
                const Text(
                  'No users found.',
                  style: TextStyle(fontSize: 16.0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherRegistrationForm extends StatefulWidget {
  final String adminEmail;
  final FirebaseAuth _auth;

  const TeacherRegistrationForm(
      {Key? key, required this.adminEmail, required FirebaseAuth auth})
      : _auth = auth,
        super(key: key);

  @override
  _TeacherRegistrationFormState createState() => _TeacherRegistrationFormState();
}

class _TeacherRegistrationFormState extends State<TeacherRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  bool _loading = false;
  String? _currentUserSchool;

  @override
  void initState() {
    super.initState();
    getUserSchool();
  }

  Future<void> getUserSchool() async {
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(widget._auth.currentUser!.uid);
    await userRef.get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        _currentUserSchool = documentSnapshot.get('schoolName');
      } else {
        _currentUserSchool = null;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  Future<void> registerTeacher() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      AppUser newTeacher = AppUser(
        uid: '',
        name: _nameController.text,
        email: _emailController.text,
        className: _classNameController.text,
        role: Role.teacher,
        schoolName: _currentUserSchool!,
      );

      await _usersCollection.add(newTeacher.toJson());

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher registered successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Registration'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _classNameController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _loading ? null : registerTeacher,
                  child: _loading ? const CircularProgressIndicator() : const Text('Register Teacher'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentRegistrationForm extends StatefulWidget {
  final String adminEmail;
  final FirebaseAuth _auth;

  const StudentRegistrationForm(
      {Key? key, required this.adminEmail, required FirebaseAuth auth})
      : _auth = auth,
        super(key: key);

  @override
  _StudentRegistrationFormState createState() => _StudentRegistrationFormState();
}

class _StudentRegistrationFormState extends State<StudentRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  bool _loading = false;
  String? _currentUserSchool;

  @override
  void initState() {
    super.initState();
    getUserSchool();
  }

  Future<void> getUserSchool() async {
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(widget._auth.currentUser!.uid);
    await userRef.get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        _currentUserSchool = documentSnapshot.get('schoolName');
      } else {
        _currentUserSchool = null;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  Future<void> registerStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      AppUser newStudent = AppUser(
        uid: '',
        name: _nameController.text,
        email: _emailController.text,
        className: _classNameController.text,
        role: Role.student,
        schoolName: _currentUserSchool!,
      );

      await _usersCollection.add(newStudent.toJson());

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student registered successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _classNameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a class name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _loading ? null : registerStudent,
                  child: _loading ? const CircularProgressIndicator() : const Text('Register Student'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

