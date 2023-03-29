import 'package:admin/views/profile_records.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentsList extends StatefulWidget {
  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  dynamic studentNumberQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: (studentNumberQuery != '' && studentNumberQuery != null)
            ? FirebaseFirestore.instance
                .collection('users')
                .where('student_number_search',
                    arrayContains: studentNumberQuery)
                .snapshots()
            : FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wront (Users)');
          } else {
            return Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: MediaQuery.of(context).size.width <= 700
                      ? null
                      : SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                studentNumberQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Student Number...',
                              icon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                ),
                SizedBox(
                  height: 15,
                ),
                SingleChildScrollView(
                  // SingleChildScrollView can be removed
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            'Student Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Student ID',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Program and Year Level',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(label: Text(''))
                      ],
                      rows: (snapshot.data?.docs ?? [])
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        return DataRow(
                            color: index.isEven
                                ? MaterialStateProperty.all(Colors.white)
                                : MaterialStateProperty.all(Colors.grey[400]),
                            cells: [
                              DataCell(
                                Text('${doc.get('full_name')}'),
                              ),
                              DataCell(
                                Text('${doc.get('student_number')}'),
                              ),
                              DataCell(
                                Text('${doc.get('email')}'),
                              ),
                              DataCell(
                                Text('${doc.get('program')}'),
                              ),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.account_box),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileReport(userID: doc.id),
                                    ),
                                  ),
                                ),
                              ),
                            ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
