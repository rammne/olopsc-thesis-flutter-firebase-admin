import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Text('Something went wrong (Users)');
        }
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Loading...'));
        }
        return ListView.builder(
          itemCount: userSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot userData = userSnapshot.data!.docs[index];
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
                  return Center(child: Text('Loading...'));
                }
                return Column(
                  children:
                      snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
                    Timestamp? _timeStamp = doc.get('date_time');
                    DateTime? _dateTime =
                        _timeStamp != null ? _timeStamp.toDate() : null;
                    return Container(
                      child: doc.get('status') == 'PENDING'
                          ? Card(
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        dynamic itemSnapshot =
                                            await FirebaseFirestore.instance
                                                .collection('items')
                                                .doc(doc.get('item_id'))
                                                .get();
                                        await FirebaseFirestore.instance
                                            .collection('items')
                                            .doc(doc.get('item_id'))
                                            .update({
                                          'item_quantity':
                                              itemSnapshot['item_quantity'] -
                                                  doc.get(
                                                      'item_quantity_requested')
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userData.id)
                                            .collection('requests')
                                            .doc(doc.id)
                                            .update({
                                          'date_time':
                                              FieldValue.serverTimestamp(),
                                          'status': 'ACCEPTED',
                                        });
                                      },
                                      icon: Icon(
                                        Icons.check,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userData.id)
                                            .collection('requests')
                                            .doc(doc.id)
                                            .update({'status': 'REJECTED'});
                                      },
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                    '${doc.get('item_name_requested')} --- ${doc.get('item_quantity_requested')}'),
                                subtitle: Text(
                                    '${doc.get('status')} --- ${_dateTime!.month} ${_dateTime.day}, ${_dateTime.year} at ${_dateTime.hour}:${_dateTime.minute}'),
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
  }
}
