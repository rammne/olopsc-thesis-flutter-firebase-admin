// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RejectedRequests extends StatefulWidget {
  String studentIDQuery;
  RejectedRequests({
    required this.studentIDQuery,
  });

  @override
  State<RejectedRequests> createState() => _RejectedRequestsState();
}

class _RejectedRequestsState extends State<RejectedRequests> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.studentIDQuery != '' && widget.studentIDQuery != null
          ? FirebaseFirestore.instance
              .collection('users')
              .where('student_name_search',
                  arrayContains: widget.studentIDQuery)
              .snapshots()
          : FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Text('Something went wrong (User)');
        }
        return ListView.builder(
          itemCount: userSnapshot.data?.docs.length ?? 0,
          itemBuilder: (context, index) {
            dynamic userData = userSnapshot.data!.docs[index];
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userData.id)
                  .collection('rejected_requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong (Requests)');
                }
                return Column(
                  children: snapshot.hasData && snapshot.data != null
                      ? snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${doc.get('item_name_rejected')} --- ${userData['full_name']}'),
                              subtitle: Text(
                                  '${doc.get('item_quantity_rejected')} --- ${doc.get('status')}'),
                            ),
                          );
                        }).toList()
                      : [],
                );
              },
            );
          },
        );
      },
    );
    ;
  }
}
