import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'Models/models.dart';
import 'Models/services.dart';

class ExamScreen extends StatefulWidget {
  ExamScreen({
    Key? key,
    required this.currentUser,
    required this.dbService,
    required this.users,
  }) : super(key: key);

  final AppUser currentUser;
  final FirebaseFirestoreService dbService;
  final List<AppUser> users;

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  bool _isExamUploadInProgress = false;
  bool _isLoading = false;

  AppUser? _selectedUser;
  List<Exam> _examList = [];

  List<AppUser> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.users;
    _fetchExamsOfUser(_filteredUsers.first);
  }

  Future<void> _fetchExamsOfUser(AppUser user) async {
    setState(() {
      _isLoading = true;
      _selectedUser = user;
    });

    _examList = await widget.dbService.fetchExamsOfUser(user.uid);

    _filteredUsers = widget.users.where(
          (u) =>
          u.name.toLowerCase().contains(user.name.toLowerCase()),
    ).toList();

    setState(() {
      _isLoading = false;
      _selectedUser = _filteredUsers.first;
    });
  }

  Future<void> _handleExamUpload(AppUser user) async {
    setState(() {
      _isExamUploadInProgress = true;
    });

    try {
      Exam exam = Exam(
        examId: _selectedUser!.uid + '_' + DateTime.now().toIso8601String(),
        userId: _selectedUser!.uid,
        className: _selectedUser!.className,
        examName: 'Exam',
        teacherName: 'Teacher',
        subject: _subjectController.text.trim(),
        marks: {
          _selectedUser!.name: double.parse(_marksController.text.trim())
        },
        timestamp: DateTime.now(),
      );
      await widget.dbService.updateExamRecord(exam);

      _examList.add(exam);

      _subjectController.clear();
      _marksController.clear();
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      _isExamUploadInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Exam Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Enter exam subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _marksController,
              keyboardType:
              TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter marks obtained',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isExamUploadInProgress
                ? null
                : (_subjectController.text.isNotEmpty &&
                _marksController.text.isNotEmpty
                ? () => _handleExamUpload(_selectedUser!)
                : null),
            child: _isExamUploadInProgress
                ? CircularProgressIndicator()
                : Text('Upload Exam Record'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _filteredUsers = widget.users.where(
                        (u) => u.name
                        .toLowerCase()
                        .contains(value.toLowerCase().trim()),
                  ).toList();
                  _selectedUser = _filteredUsers.first;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search user',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator()
          else
            Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        AppUser user = _filteredUsers[index];
                        return GestureDetector(
                          onTap: () {
                            _fetchExamsOfUser(user);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedUser == user
                                      ? Colors.redAccent
                                      : Colors.transparent,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(user.name.substring(0, 1)),
                                ),
                                title: Text(user.name),
                                subtitle: Text(user.className),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _examList.isNotEmpty
                        ? ListView.builder(
                      itemCount: _examList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        Exam exam = _examList[index];
                        if (exam.marks[_selectedUser!.name] == null)
                          return SizedBox.shrink();
                        String formattedDate =
                        DateFormat('dd/MM/yyyy').format(
                          exam.timestamp,
                        );
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  exam.subject,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                Container(
                                  height: 200,
                                  child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    series: <ChartSeries>[
                                      ColumnSeries<MarksData, String>(
                                        dataSource: exam.marks.entries
                                            .map((entry) => MarksData(
                                          entry.key,
                                          entry.value,
                                        ))
                                            .toList(),
                                        xValueMapper:
                                            (MarksData data, _) =>
                                        data.name,
                                        yValueMapper:
                                            (MarksData data, _) =>
                                        data.marks,
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Marks: ${exam.marks[_selectedUser!.name]!.toStringAsFixed(2)}',
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Average Marks: ${exam.averageMarks.toStringAsFixed(2)}',
                                    ),
                                    Text(formattedDate),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        : const Center(child: Text('No exams found.')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MarksData {
  MarksData(this.name, this.marks);
  final String name;
  final double marks;
}