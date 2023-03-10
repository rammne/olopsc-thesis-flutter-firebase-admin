// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestForm extends StatefulWidget {
  int itemQuantityRequested;
  String requestID;
  String userID;
  String itemID;
  RequestForm({
    required this.itemQuantityRequested,
    required this.requestID,
    required this.userID,
    required this.itemID,
  });
  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _formKey = GlobalKey<FormState>();
  String remarks = '';
  int? updatedQuantity;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    onPressed: () async {
                      dynamic itemSnapshot = await FirebaseFirestore.instance
                          .collection('items')
                          .doc(widget.itemID)
                          .get();

                      await FirebaseFirestore.instance
                          .collection('items')
                          .doc(widget.itemID)
                          .update({
                        'item_quantity':
                            itemSnapshot['item_quantity'] - updatedQuantity,
                      });
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userID)
                          .collection('requests')
                          .doc(widget.requestID)
                          .set({
                        'item_quantity_requested': updatedQuantity,
                        'date_time': FieldValue.serverTimestamp(),
                        'remarks': remarks,
                        'status': 'ACCEPTED'
                      }, SetOptions(merge: true));
                      Navigator.pop(context);
                    },
                    child: Text('Accept'),
                  ),
                ),
              ],
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0,
              backgroundColor: Colors.grey[350],
            ),
            body: Container(
              margin: EdgeInsets.fromLTRB(50, 0, 50, 50),
              padding: EdgeInsets.only(top: 75),
              child: Center(
                child: Column(
                  children: [
                    Text('Edit quantity:'),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            updatedQuantity = int.parse(value);
                          });
                        },
                        initialValue: widget.itemQuantityRequested.toString(),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text('Remark:'),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: constraints.maxWidth / 3,
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            remarks = value;
                          });
                        },
                        maxLines: 5,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[400]),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
