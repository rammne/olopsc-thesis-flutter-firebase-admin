import 'package:admin/views/rejected_requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'accepted_requests.dart';

class History extends StatefulWidget {
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String studentIDQuery = '';

  Future<void> deleteAcceptedRequests() async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (DocumentSnapshot userDoc in usersSnapshot.docs) {
      QuerySnapshot acceptedRequests =
          await userDoc.reference.collection('accepted_requests').get();

      for (DocumentSnapshot acceptedRequests in acceptedRequests.docs) {
        batch.delete(acceptedRequests.reference);
      }
    }
    await batch.commit();
  }

  Future<void> deleteRejectedRequests() async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (DocumentSnapshot userDoc in usersSnapshot.docs) {
      QuerySnapshot rejectedRequests =
          await userDoc.reference.collection('rejected_requests').get();

      for (DocumentSnapshot rejectedRequests in rejectedRequests.docs) {
        batch.delete(rejectedRequests.reference);
      }
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Column(
            children: [
              TabBar(
                labelColor: Colors.black,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content:
                                      Text('Delete all Accepted Requests?'),
                                  actions: [
                                    ElevatedButton(
                                      child: Text('Yes'),
                                      onPressed: () {
                                        deleteAcceptedRequests();
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.clear_all),
                        ),
                        Text('Accepted'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content:
                                      Text('Delete all Rejected Requests?'),
                                  actions: [
                                    ElevatedButton(
                                      child: Text('Yes'),
                                      onPressed: () {
                                        deleteRejectedRequests();
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.clear_all),
                        ),
                        Text('Rejected'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Student Number...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      studentIDQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: TabBarView(children: [
                  AcceptedRequests(
                    studentIDQuery: studentIDQuery,
                  ),
                  RejectedRequests(
                    studentIDQuery: studentIDQuery,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
