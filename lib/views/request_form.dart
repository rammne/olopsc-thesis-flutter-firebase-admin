// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestForm extends StatefulWidget {
  String requestID;
  int itemQuantityRequested;
  String userID;
  String itemID;
  String itemNameRequested;
  RequestForm({
    required this.requestID,
    required this.itemNameRequested,
    required this.itemQuantityRequested,
    required this.userID,
    required this.itemID,
  });
  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  String remarks = '';
  int? updatedQuantity;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text('Edit Quantity: '),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 75,
              child: TextFormField(
                validator: (value) => value!.isNotEmpty ? null : '',
                onChanged: (value) {
                  setState(() {
                    updatedQuantity = int.parse(value);
                  });
                },
                initialValue: widget.itemQuantityRequested.toString(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text('Remarks:'),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  remarks = 'No Remarks';
                }
                return null;
              },
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  remarks = value;
                });
              },
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (updatedQuantity != null) {
                    dynamic itemSnapshot = await FirebaseFirestore.instance
                        .collection('items')
                        .doc(widget.itemID)
                        .get();

                    await FirebaseFirestore.instance
                        .collection('items')
                        .doc(widget.itemID)
                        .update({
                      'available_items':
                          itemSnapshot['available_items'] - updatedQuantity,
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userID)
                        .collection('accepted_requests')
                        .add({
                      'item_id': widget.itemID,
                      'item_name_accepted': widget.itemNameRequested,
                      'item_quantity_accepted': updatedQuantity,
                      'date_time': FieldValue.serverTimestamp(),
                      'remarks': remarks,
                      'status': 'ACCEPTED'
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userID)
                        .collection('pending_requests')
                        .doc(widget.requestID)
                        .delete();
                    Navigator.pop(context);
                  } else {
                    dynamic itemSnapshot = await FirebaseFirestore.instance
                        .collection('items')
                        .doc(widget.itemID)
                        .get();

                    await FirebaseFirestore.instance
                        .collection('items')
                        .doc(widget.itemID)
                        .update({
                      'available_items': itemSnapshot['available_items'] -
                          widget.itemQuantityRequested,
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userID)
                        .collection('accepted_requests')
                        .add({
                      'item_id': widget.itemID,
                      'item_name_accepted': widget.itemNameRequested,
                      'item_quantity_accepted': widget.itemQuantityRequested,
                      'date_time': FieldValue.serverTimestamp(),
                      'remarks': remarks,
                      'status': 'ACCEPTED'
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userID)
                        .collection('pending_requests')
                        .doc(widget.requestID)
                        .delete();
                    Navigator.pop(context);
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                fixedSize: MaterialStateProperty.all(
                  Size.fromWidth(300),
                ),
              ),
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}

// LayoutBuilder(
//           builder: (context, constraints) {
//             return Scaffold(
//               appBar: AppBar(
//                 actions: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       style: ButtonStyle(
//                         backgroundColor:
//                             MaterialStateProperty.all(Colors.black),
//                       ),
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           try {
//                             dynamic itemSnapshot = await FirebaseFirestore
//                                 .instance
//                                 .collection('items')
//                                 .doc(widget.itemID)
//                                 .get();

//                             await FirebaseFirestore.instance
//                                 .collection('items')
//                                 .doc(widget.itemID)
//                                 .update({
//                               'item_quantity': itemSnapshot['item_quantity'] -
//                                   updatedQuantity,
//                             });
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(widget.userID)
//                                 .collection('accepted_requests')
//                                 .add({
//                               'item_id': widget.itemID,
//                               'item_name_accepted': widget.itemNameRequested,
//                               'item_quantity_accepted': updatedQuantity,
//                               'date_time': FieldValue.serverTimestamp(),
//                               'remarks': remarks,
//                               'status': 'ACCEPTED'
//                             });
//                             Navigator.pop(context);
//                           } catch (e) {
//                             print(e.toString());
//                             setState(() {
//                               error = 'Text is not allowed';
//                             });
//                           }
//                         }
//                       },
//                       child: Text('Accept'),
//                     ),
//                   ),
//                 ],
//                 iconTheme: IconThemeData(color: Colors.black),
//                 elevation: 0,
//                 backgroundColor: Colors.blue[100],
//               ),
//               body: Container(
//                 margin: EdgeInsets.fromLTRB(50, 0, 50, 50),
//                 padding: EdgeInsets.only(top: 75),
//                 child: Center(
//                   child: Column(
//                     children: [
//                       Text('Edit quantity:'),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       SizedBox(
//                         width: 50,
//                         child: TextFormField(
//                           validator: (value) => value!.isNotEmpty ? null : '',
//                           onChanged: (value) {
//                             setState(() {
//                               updatedQuantity = int.parse(value);
//                             });
//                           },
//                           initialValue: widget.itemQuantityRequested.toString(),
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(),
//                               filled: true,
//                               fillColor: Colors.white),
//                         ),
//                       ),
//                       Text(
//                         error,
//                         style: TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Text('Remark:'),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       SizedBox(
//                         width: constraints.maxWidth / 3,
//                         child: TextFormField(
//                           onChanged: (value) {
//                             setState(() {
//                               remarks = value != '' && value != null
//                                   ? value
//                                   : 'No Remarks';
//                             });
//                           },
//                           maxLines: 5,
//                           decoration: InputDecoration(
//                               border: InputBorder.none,
//                               filled: true,
//                               fillColor: Colors.white),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),