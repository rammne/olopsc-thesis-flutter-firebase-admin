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
                .where('student_number', isEqualTo: studentNumberQuery)
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 200),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        studentNumberQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Student Number search for now',
                      icon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
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
                    ],
                    rows: (snapshot.data?.docs ?? []).map((doc) {
                      return DataRow(cells: [
                        DataCell(
                          Text('${doc.get('full_name')}'),
                        ),
                        DataCell(
                          Text('${doc.get('email')}'),
                        ),
                        DataCell(
                          Text('${doc.get('student_number')}'),
                        ),
                        DataCell(
                          Text('${doc.get('program')}'),
                        ),
                      ]);
                    }).toList(),
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
