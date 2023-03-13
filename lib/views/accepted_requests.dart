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
    void _showSettings(remarks) {
      showModalBottomSheet(
        backgroundColor: Colors.grey[350],
        context: context,
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
        shape: Border.all(width: 5, color: Color(Colors.blue.shade300.value)),
        builder: ((context) {
          return Container(
            height: 500,
            child: Center(
              child: Text(
                '${remarks}',
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                  .collection('requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong (Requests)');
                }
                return Column(
                  children: snapshot.hasData && snapshot.data != null
                      ? snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
                          Timestamp _timeStamp = doc.get('date_time');
                          DateTime _dateTime = _timeStamp.toDate();
                          return Container(
                            child: doc.get('status') == 'ACCEPTED'
                                ? Card(
                                    child: ListTile(
                                      trailing: IconButton(
                                        onPressed: () {
                                          try {
                                            _showSettings(doc.get('remarks'));
                                          } catch (e) {
                                            _showSettings('No remarks');
                                          }
                                        },
                                        icon: Icon(Icons.mail),
                                      ),
                                      title: Text(
                                          '${doc.get('item_name_requested')} --- ${userData['full_name']}'),
                                      subtitle: Text(
                                          '${doc.get('item_quantity_requested')} --- ${doc.get('status')} --- ${_dateTime.month} ${_dateTime.day}, ${_dateTime.year} at ${_dateTime.hour}:${_dateTime.minute}'),
                                    ),
                                  )
                                : null,
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
