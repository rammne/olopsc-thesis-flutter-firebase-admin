import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AcceptedRequests extends StatefulWidget {
  const AcceptedRequests({super.key});

  @override
  State<AcceptedRequests> createState() => _AcceptedRequestsState();
}

class _AcceptedRequestsState extends State<AcceptedRequests> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Text('Something went wrong (User)');
        }
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }
        return ListView.builder(
          itemCount: userSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            dynamic userData = userSnapshot.data!.docs[index];
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userData.id)
                  .collection('requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong (Requests)');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }
                return Column(
                  children:
                      snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
                    Timestamp _timeStamp = doc.get('date_time');
                    DateTime _dateTime = _timeStamp.toDate();
                    return Container(
                      child: doc.get('status') == 'ACCEPTED'
                          ? Card(
                              child: ListTile(
                                title: Text(
                                    '${doc.get('item_name_requested')} --- ${userData['full_name']}'),
                                subtitle: Text(
                                    '${doc.get('item_quantity_requested')} --- ${doc.get('status')} --- ${_dateTime.month} ${_dateTime.day}, ${_dateTime.year} at ${_dateTime.hour}:${_dateTime.minute}'),
                              ),
                            )
                          : null,
                    );
                  }).toList(),
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
