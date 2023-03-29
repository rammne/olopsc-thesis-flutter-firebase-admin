import 'package:admin/views/request_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestsPage extends StatefulWidget {
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  String userFullName = '';

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

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collectionGroup('pending_requests')
            .orderBy('date_time')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Text('Something went wrong ${snapshot.error.toString()}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Student Name')),
                  DataColumn(label: Text('Date and Time')),
                  DataColumn(label: Text('')),
                ],
                rows: (snapshot.data?.docs ?? []).asMap().entries.map((entry) {
                  final index = entry.key;
                  final parent =
                      snapshot.data!.docs[index].reference.parent.parent!;
                  DocumentSnapshot userPendingRequest =
                      snapshot.data!.docs[index];
                  Timestamp? timeStamp = userPendingRequest.get('date_time');
                  DateTime? dateTime = timeStamp!.toDate();
                  String formattedDate = DateFormat('yMMMMd').format(dateTime);
                  String formattedTime = DateFormat('jm').format(dateTime);

                  return DataRow(
                    color: index == 0
                        ? MaterialStateProperty.all(Colors.white)
                        : MaterialStateProperty.all(Colors.grey),
                    cells: [
                      DataCell(
                        Text(
                          '${userPendingRequest.get('item_name_requested')}',
                          style: TextStyle(
                              color: index == 0 ? null : Colors.grey[350]),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${userPendingRequest.get('item_quantity_requested')}',
                          style: TextStyle(
                              color: index == 0 ? null : Colors.grey[350]),
                        ),
                      ),
                      DataCell(StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(parent.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                                'Something went wrong ${snapshot.error.toString()}');
                          }
                          if (!snapshot.hasData) {
                            return Text('Loading Data...');
                          }
                          return Text(
                            '${snapshot.data!.get('full_name') ?? ''}',
                            style: TextStyle(
                                color: index == 0 ? null : Colors.grey[350]),
                          );
                        },
                      )),
                      DataCell(
                        Text(
                          '${formattedDate} at ${formattedTime}',
                          style: TextStyle(
                              color: index == 0 ? null : Colors.grey[350]),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: index == 0
                                  ? () async {
                                      dynamic itemSnapshot =
                                          await FirebaseFirestore
                                              .instance
                                              .collection('items')
                                              .doc(userPendingRequest
                                                  .get('item_id'))
                                              .get();
                                      if (itemSnapshot['available_items'] !=
                                          0) {
                                        await FirebaseFirestore.instance
                                            .collection('items')
                                            .doc(userPendingRequest
                                                .get('item_id'))
                                            .update({
                                          'available_items': itemSnapshot[
                                                  'available_items'] -
                                              userPendingRequest.get(
                                                  'item_quantity_requested'),
                                          'lent_items':
                                              itemSnapshot['lent_items'] +
                                                  userPendingRequest.get(
                                                      'item_quantity_requested')
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(parent.id)
                                            .collection('accepted_requests')
                                            .add({
                                          'item_id':
                                              userPendingRequest.get('item_id'),
                                          'item_name_accepted':
                                              userPendingRequest
                                                  .get('item_name_requested'),
                                          'item_quantity_accepted':
                                              userPendingRequest.get(
                                                  'item_quantity_requested'),
                                          'date_time':
                                              FieldValue.serverTimestamp(),
                                          'status': 'ACCEPTED',
                                        });
                                        await userPendingRequest.reference
                                            .delete();
                                      } else {
                                        final snackbar = SnackBar(
                                            content: Text(
                                                '${itemSnapshot['item_name']} unavailable'));

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      }
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
                                          .doc(parent.id)
                                          .collection('rejected_requests')
                                          .add({
                                        'item_id':
                                            userPendingRequest.get('item_id'),
                                        'item_name_rejected': userPendingRequest
                                            .get('item_name_requested'),
                                        'item_quantity_rejected':
                                            userPendingRequest
                                                .get('item_quantity_requested'),
                                        'date_time':
                                            FieldValue.serverTimestamp(),
                                        'status': 'REJECTED',
                                      });
                                      await userPendingRequest.reference
                                          .delete();
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
                                    ? MaterialStateProperty.all(Colors.black)
                                    : null,
                              ),
                              onPressed: index == 0
                                  ? () => _onEditTap(
                                      userPendingRequest.id,
                                      userPendingRequest
                                          .get('item_name_requested'),
                                      userPendingRequest.get('item_id'),
                                      userPendingRequest
                                          .get('item_quantity_requested'),
                                      parent.id)
                                  : null,
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                    color: index == 0 ? null : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}



// SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   child: DataTable(
//                     columns: [
//                       DataColumn(label: Text('Item Name')),
//                       DataColumn(label: Text('Quantity')),
//                       DataColumn(label: Text('Student Name')),
//                       DataColumn(label: Text('Date and Time')),
//                       DataColumn(label: Text('')),
//                     ],
//                     rows: (snapshot.data?.docs ?? [])
//                         .asMap()
//                         .entries
//                         .map((entry) {
//                       final index = entry.key;
//                       final doc = entry.value;
//                       Timestamp? timeStamp = doc.get('date_time');
//                       DateTime? dateTime = timeStamp!.toDate();
//                       String formattedDate =
//                           DateFormat('yMMMMd').format(dateTime);
//                       String formattedTime = DateFormat('jm').format(dateTime);
//                       return DataRow(
//                           color: index == 0
//                               ? MaterialStateProperty.all(Colors.white)
//                               : MaterialStateProperty.all(Colors.grey),
//                           cells: [
//                             DataCell(
//                               Text(
//                                 '${doc.get('item_name_requested')}',
//                                 style: TextStyle(
//                                     color:
//                                         index == 0 ? null : Colors.grey[350]),
//                               ),
//                             ),
//                             DataCell(
//                               Text(
//                                 '${doc.get('item_quantity_requested')}',
//                                 style: TextStyle(
//                                     color:
//                                         index == 0 ? null : Colors.grey[350]),
//                               ),
//                             ),
//                             DataCell(
//                               Text(
//                                 '${userData.get('full_name')}',
//                                 style: TextStyle(
//                                     color:
//                                         index == 0 ? null : Colors.grey[350]),
//                               ),
//                             ),
//                             DataCell(
//                               Text(
//                                 '${formattedDate} at ${formattedTime}',
//                                 style: TextStyle(
//                                     color:
//                                         index == 0 ? null : Colors.grey[350]),
//                               ),
//                             ),
//                             DataCell(
//                               Row(mainAxisSize: MainAxisSize.min, children: [
//                                 ElevatedButton(
//                                   onPressed: index == 0
//                                       ? () async {
//                                           dynamic itemSnapshot =
//                                               await FirebaseFirestore.instance
//                                                   .collection('items')
//                                                   .doc(doc.get('item_id'))
//                                                   .get();
//                                           if (itemSnapshot['available_items'] !=
//                                               0) {
//                                             await FirebaseFirestore.instance
//                                                 .collection('items')
//                                                 .doc(doc.get('item_id'))
//                                                 .update({
//                                               'available_items': itemSnapshot[
//                                                       'available_items'] -
//                                                   doc.get(
//                                                       'item_quantity_requested'),
//                                               'lent_items': itemSnapshot[
//                                                       'lent_items'] +
//                                                   doc.get(
//                                                       'item_quantity_requested')
//                                             });
//                                             await FirebaseFirestore.instance
//                                                 .collection('users')
//                                                 .doc(userData.id)
//                                                 .collection('accepted_requests')
//                                                 .add({
//                                               'item_id': doc.get('item_id'),
//                                               'item_name_accepted': doc
//                                                   .get('item_name_requested'),
//                                               'item_quantity_accepted': doc.get(
//                                                   'item_quantity_requested'),
//                                               'date_time':
//                                                   FieldValue.serverTimestamp(),
//                                               'status': 'ACCEPTED',
//                                             });
//                                             await doc.reference.delete();
//                                           } else {
//                                             final snackbar = SnackBar(
//                                                 content: Text(
//                                                     '${itemSnapshot['item_name']} unavailable'));

//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(snackbar);
//                                           }
//                                         }
//                                       : null,
//                                   child: Text(
//                                     'Confirm',
//                                     style: TextStyle(
//                                         color: index == 0 ? null : Colors.grey),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: index == 0
//                                       ? () async {
//                                           await FirebaseFirestore.instance
//                                               .collection('users')
//                                               .doc(userData.id)
//                                               .collection('rejected_requests')
//                                               .add({
//                                             'item_id': doc.get('item_id'),
//                                             'item_name_rejected':
//                                                 doc.get('item_name_requested'),
//                                             'item_quantity_rejected': doc
//                                                 .get('item_quantity_requested'),
//                                             'date_time':
//                                                 FieldValue.serverTimestamp(),
//                                             'status': 'REJECTED',
//                                           });
//                                           await doc.reference.delete();
//                                         }
//                                       : null,
//                                   style: ButtonStyle(
//                                     backgroundColor: index == 0
//                                         ? MaterialStateProperty.all(Colors.red)
//                                         : null,
//                                   ),
//                                   child: Text(
//                                     'Cancel',
//                                     style: TextStyle(
//                                         color: index == 0 ? null : Colors.grey),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                                 ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor: index == 0
//                                         ? MaterialStateProperty.all(
//                                             Colors.black)
//                                         : null,
//                                   ),
//                                   onPressed: index == 0
//                                       ? () => _onEditTap(
//                                           doc.id,
//                                           doc.get('item_name_requested'),
//                                           doc.get('item_id'),
//                                           doc.get('item_quantity_requested'),
//                                           userData.id)
//                                       : null,
//                                   child: Text(
//                                     'Edit',
//                                     style: TextStyle(
//                                         color: index == 0 ? null : Colors.grey),
//                                   ),
//                                 ),
//                               ]),
//                             )
//                           ]);
//                     }).toList(),
//                   ),
//                 );