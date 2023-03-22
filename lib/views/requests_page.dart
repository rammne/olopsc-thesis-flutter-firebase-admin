import 'package:admin/views/request_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestsPage extends StatefulWidget {
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
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
                    rows: (snapshot.data?.docs ?? []).map((doc) {
                      Timestamp? _timeStamp = doc.get('date_time');
                      DateTime? _dateTime =
                          _timeStamp != null ? _timeStamp.toDate() : null;
                      String formattedDateTime =
                          DateFormat('MM-dd-yyyy – kk:mm').format(_dateTime!);
                      return DataRow(cells: [
                        DataCell(
                          Text('${doc.get('item_name_requested')}'),
                        ),
                        DataCell(
                          Text('${doc.get('item_quantity_requested')}'),
                        ),
                        DataCell(
                          Text('${userData.get('full_name')}'),
                        ),
                        DataCell(
                          Text('${formattedDateTime}'),
                        ),
                        DataCell(
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            ElevatedButton(
                              onPressed: () async {
                                dynamic itemSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('items')
                                    .doc(doc.get('item_id'))
                                    .get();
                                await FirebaseFirestore.instance
                                    .collection('items')
                                    .doc(doc.get('item_id'))
                                    .update({
                                  'item_quantity':
                                      itemSnapshot['item_quantity'] -
                                          doc.get('item_quantity_requested')
                                });
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userData.id)
                                    .collection('accepted_requests')
                                    .add({
                                  'item_id': doc.get('item_id'),
                                  'item_name_accepted':
                                      doc.get('item_name_requested'),
                                  'item_quantity_accepted':
                                      doc.get('item_quantity_requested'),
                                  'date_time': FieldValue.serverTimestamp(),
                                  'status': 'ACCEPTED',
                                });
                                await doc.reference.delete();
                              },
                              child: Text('Confirm'),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userData.id)
                                    .collection('rejected_requests')
                                    .add({
                                  'item_id': doc.get('item_id'),
                                  'item_name_rejected':
                                      doc.get('item_name_requested'),
                                  'item_quantity_rejected':
                                      doc.get('item_quantity_requested'),
                                  'date_time': FieldValue.serverTimestamp(),
                                  'status': 'REJECTED',
                                });
                                await doc.reference.delete();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                              child: Text('Cancel'),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RequestForm(
                                        itemNameRequested:
                                            doc.get('item_name_requested'),
                                        requestID: doc.id,
                                        itemQuantityRequested:
                                            doc.get('item_quantity_requested'),
                                        userID: userData.id,
                                        itemID: doc.get('item_id')),
                                  ),
                                );
                              },
                              child: Text('Edit'),
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
