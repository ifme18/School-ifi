import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Models/services.dart';
import 'Models/models.dart';

class FeesScreen extends StatefulWidget {
  FeesScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final AppUser currentUser;
  final FirebaseFirestoreService dbService = FirebaseFirestoreService();

  @override
  _FeesScreenState createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isPaymentInProgress = false;
  bool _isLoading = false;

  List<AppUser> _userList = [];
  List<Payment> _paymentList = [];
  List<Payment> _filteredPaymentList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _filteredPaymentList = _paymentList;
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    final snapshot =
    await FirebaseFirestore.instance.collection('users').get();
    _userList = snapshot.docs
        .map((doc) => AppUser.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchPaymentsOfUser(String userId) async {
    setState(() {
      _isLoading = true;
    });

    _paymentList = await widget.dbService.fetchPaymentsOfUser(userId);
    _filteredPaymentList = _paymentList;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handlePaymentUpdateForSelectedUser(
      double amount, String description) async {
    setState(() {
      _isPaymentInProgress = true;
    });

    try {
      Payment payment = Payment(
        paymentId: _selectedUser!.uid + DateTime.now().toIso8601String(),
        userId: _selectedUser!.uid,
        amount: amount,
        description: description,
        timestamp: DateTime.now(),
      );

      await widget.dbService.updatePaymentRecord(payment);

      _paymentList.add(payment);
      _filteredPaymentList.add(payment);

      _amountController.clear();
      _descriptionController.clear();
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      _isPaymentInProgress = false;
    });
  }

  AppUser? _selectedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Fees Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _userList = _userList.where((user) =>
                      user.name.toLowerCase().contains(value.toLowerCase())).toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search user name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _userList.length,
              itemBuilder: (BuildContext context, int index) {
                final user = _userList[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.className),
                  onTap: () {
                    setState(() {
                      _selectedUser = user;
                      _fetchPaymentsOfUser(user.uid);
                    });
                  },
                  trailing: Icon(Icons.arrow_forward_ios),
                );
              },
            ),
          ),
          if (_selectedUser != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _amountController,
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter payment amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter payment description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isPaymentInProgress
                  ? null
                  : (_amountController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty
                  ? () => _handlePaymentUpdateForSelectedUser(
                  double.parse(_amountController.text),
                  _descriptionController.text)
                  : null),
              child: _isPaymentInProgress
                  ? CircularProgressIndicator()
                  : Text('Update Payment'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Payments Over Time',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              child: _filteredPaymentList.isNotEmpty
                  ? PaymentChart(paymentList: _filteredPaymentList)
                  : Center(
                child: Text(
                  'No payments found...',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Payment History',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              child: _filteredPaymentList.isNotEmpty
                  ? PaymentListForUser(
                paymentList: _filteredPaymentList,
                onUpdatePressed:
                _handlePaymentUpdateForSelectedUser,
              )
                  : Center(
                child: Text(
                  'No payments found...',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PaymentChart extends StatelessWidget {
  final List<Payment> paymentList;

  const PaymentChart({
    Key? key,
    required this.paymentList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(),
      series: <ChartSeries>[
        LineSeries<Payment, DateTime>(
          dataSource: paymentList,
          xValueMapper: (Payment payment, _) => payment.timestamp,
          yValueMapper: (Payment payment, _) => payment.amount,
        ),
      ],
    );
  }
}

class PaymentListForUser extends StatelessWidget {
  final List<Payment> paymentList;
  final Function(double amount, String description) onUpdatePressed;

  PaymentListForUser({
    Key? key,
    required this.paymentList,
    required this.onUpdatePressed,
  }) : super(key: key);

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: paymentList.length,
      itemBuilder: (BuildContext ctxt, int index) {
        Payment payment = paymentList[index];
        String formattedDate =
        DateFormat('dd/MM/yyyy').format(payment.timestamp);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: ListTile(
              title: Text(
                  'Amount: ${payment.amount.toStringAsFixed(2)} - Description: ${payment.description}'),
              subtitle: Text('Date: $formattedDate'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      _amountController.text = payment.amount.toStringAsFixed(2);
                      _descriptionController.text = payment.description;

                      return AlertDialog(
                        title: Text('Update Payment'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _amountController,
                              keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: 'Enter payment amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16.0),
                              ),
                            ),
                            TextField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                hintText: 'Enter payment description',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16.0),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => onUpdatePressed(
                              double.parse(_amountController.text),
                              _descriptionController.text,
                            ),
                            child: Text('Save'),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

