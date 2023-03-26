import 'package:admin/views/request_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestsPage extends StatefulWidget {
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  Widget build(BuildContext context) {
    Future<void> _onEditTap(String requestID, String itemName, String itemID,
        int available_items, String userID) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            content: RequestForm(
              requestID: requestID,
              itemNameRequested: itemName,
              itemQuantityRequested: available_items,
              userID: userID,
              itemID: itemID,
            ),
          );
        },
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Text('Something went wrong (Users)');
        }
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: userSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot userData = userSnapshot.data!.docs[index];
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userData.id)
                  .collection('pending_requests')
                  .orderBy("date_time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong (Requests)');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('');
                }
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Item Name')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Student Name')),
                      DataColumn(label: Text('Date and Time')),
                      DataColumn(label: Text('')),
                    ],
                    rows: (snapshot.data?.docs ?? [])
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      Timestamp? timeStamp = doc.get('date_time');
                      DateTime? dateTime =
                          timeStamp != null ? timeStamp.toDate() : null;
                      String formattedDateTime =
                          DateFormat('MM-dd-yyyy – kk:mm').format(dateTime!);
                      return DataRow(
                          color: index == 0
                              ? MaterialStateProperty.all(Colors.white)
                              : MaterialStateProperty.all(Colors.grey),
                          cells: [
                            DataCell(
                              Text(
                                '${doc.get('item_name_requested')}',
                                style: TextStyle(
                                    color:
                                        index == 0 ? null : Colors.grey[350]),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${doc.get('item_quantity_requested')}',
                                style: TextStyle(
                                    color:
                                        index == 0 ? null : Colors.grey[350]),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${userData.get('full_name')}',
                                style: TextStyle(
                                    color:
                                        index == 0 ? null : Colors.grey[350]),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${formattedDateTime}',
                                style: TextStyle(
                                    color:
                                        index == 0 ? null : Colors.grey[350]),
                              ),
                            ),
                            DataCell(
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                ElevatedButton(
                                  onPressed: index == 0
                                      ? () async {
                                          dynamic itemSnapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('items')
                                                  .doc(doc.get('item_id'))
                                                  .get();
                                          await FirebaseFirestore.instance
                                              .collection('items')
                                              .doc(doc.get('item_id'))
                                              .update({
                                            'available_items': itemSnapshot[
                                                    'available_items'] -
                                                doc.get(
                                                    'item_quantity_requested')
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userData.id)
                                              .collection('accepted_requests')
                                              .add({
                                            'item_id': doc.get('item_id'),
                                            'item_name_accepted':
                                                doc.get('item_name_requested'),
                                            'item_quantity_accepted': doc
                                                .get('item_quantity_requested'),
                                            'date_time':
                                                FieldValue.serverTimestamp(),
                                            'status': 'ACCEPTED',
                                          });
                                          await doc.reference.delete();
                                        }
                                      : null,
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                        color: index == 0 ? null : Colors.grey),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: index == 0
                                      ? () async {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userData.id)
                                              .collection('rejected_requests')
                                              .add({
                                            'item_id': doc.get('item_id'),
                                            'item_name_rejected':
                                                doc.get('item_name_requested'),
                                            'item_quantity_rejected': doc
                                                .get('item_quantity_requested'),
                                            'date_time':
                                                FieldValue.serverTimestamp(),
                                            'status': 'REJECTED',
                                          });
                                          await doc.reference.delete();
                                        }
                                      : null,
                                  style: ButtonStyle(
                                    backgroundColor: index == 0
                                        ? MaterialStateProperty.all(Colors.red)
                                        : null,
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: index == 0 ? null : Colors.grey),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: index == 0
                                        ? MaterialStateProperty.all(
                                            Colors.black)
                                        : null,
                                  ),
                                  onPressed: index == 0
                                      ? () => _onEditTap(
                                          doc.id,
                                          doc.get('item_name_requested'),
                                          doc.get('item_id'),
                                          doc.get('item_quantity_requested'),
                                          userData.id)
                                      : null,
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                        color: index == 0 ? null : Colors.grey),
                                  ),
                                ),
                              ]),
                            )
                          ]);
                    }).toList(),
                  ),
                );
                // return Column(
                //   children: snapshot.data!.docs.map((doc) {
                //     print(i);
                //     Timestamp? _timeStamp = doc.get('date_time');
                //     DateTime? _dateTime =
                //         _timeStamp != null ? _timeStamp.toDate() : null;
                //     return Container(
                //       child: doc.get('status') == 'PENDING'
                //           ? Card(
                //               child: ListTile(
                //                 onTap: () {
                //                   Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (context) => RequestForm(
                //                           requestID: doc.id,
                //                           itemQuantityRequested: doc
                //                               .get('item_quantity_requested'),
                //                           userID: userData.id,
                //                           itemID: doc.get('item_id')),
                //                     ),
                //                   );
                //                 },
                //                 trailing: Row(
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: [
                //                     IconButton(
                //                       onPressed: () async {
                //                         dynamic itemSnapshot =
                //                             await FirebaseFirestore.instance
                //                                 .collection('items')
                //                                 .doc(doc.get('item_id'))
                //                                 .get();
                //                         await FirebaseFirestore.instance
                //                             .collection('items')
                //                             .doc(doc.get('item_id'))
                //                             .update({
                //                           'item_quantity':
                //                               itemSnapshot['item_quantity'] -
                //                                   doc.get(
                //                                       'item_quantity_requested')
                //                         });
                //                         await FirebaseFirestore.instance
                //                             .collection('users')
                //                             .doc(userData.id)
                //                             .collection('requests')
                //                             .doc(doc.id)
                //                             .update({
                //                           'date_time':
                //                               FieldValue.serverTimestamp(),
                //                           'status': 'ACCEPTED',
                //                         });
                //                       },
                //                       icon: Icon(
                //                         Icons.check,
                //                         color: Colors.blue,
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       width: 10,
                //                     ),
                //                     IconButton(
                //                       onPressed: () async {
                //                         await FirebaseFirestore.instance
                //                             .collection('users')
                //                             .doc(userData.id)
                //                             .collection('requests')
                //                             .doc(doc.id)
                //                             .update({'status': 'REJECTED'});
                //                       },
                //                       icon: Icon(
                //                         Icons.cancel,
                //                         color: Colors.red,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //                 title: Text(
                //                     '${doc.get('item_name_requested')} --- ${doc.get('item_quantity_requested')} requested by ${userData.get('full_name')}'),
                //                 subtitle: Text(
                //                     '${doc.get('status')} --- ${_dateTime!.month} ${_dateTime.day}, ${_dateTime.year} at ${_dateTime.hour}:${_dateTime.minute}'),
                //               ),
                //             )
                //           : null,
                //     );
                //   }).toList(),
                // );
              },
            );
          },
        );
      },
    );
  }
}
