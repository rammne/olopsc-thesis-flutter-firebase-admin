import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wront (Users)');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }
          return Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 200),
                child: TextField(
                  decoration: InputDecoration(
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
                      label: Text('Student Name'),
                    ),
                    DataColumn(
                      label: Text('Student ID'),
                    ),
                    DataColumn(
                      label: Text('Program and Year Level'),
                    ),
                  ],
                  rows: snapshot.data!.docs.map((doc) {
                    return DataRow(cells: [
                      DataCell(
                        Text('${doc.get('full_name')}'),
                      ),
                      DataCell(
                        Text('${doc.id}'),
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
        },
      ),
    );
  }
}
