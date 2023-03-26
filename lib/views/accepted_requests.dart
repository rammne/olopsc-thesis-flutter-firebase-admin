import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AcceptedRequests extends StatefulWidget {
  const AcceptedRequests({super.key});

  @override
  State<AcceptedRequests> createState() => _AcceptedRequestsState();
}

class _AcceptedRequestsState extends State<AcceptedRequests> {
  @override
  Widget build(BuildContext context) {
    void _showSettings(remarks) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('${remarks}'),
        ),
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
                  .collection('accepted_requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong (Requests)');
                }
                return Column(
                  children: snapshot.hasData && snapshot.data != null
                      ? snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
                          Timestamp timeStamp = doc.get('date_time');
                          DateTime dateTime = timeStamp.toDate();
                          String formattedDateTime =
                              DateFormat('MM-dd-yyyy – kk:mm').format(dateTime);
                          return Card(
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
                                  // ignore: unnecessary_brace_in_string_interps
                                  ' ${doc.get('item_quantity_accepted')} ${doc.get('item_name_accepted')} for ${userData['full_name']} at ${formattedDateTime}'),
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
