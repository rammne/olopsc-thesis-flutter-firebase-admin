import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemList extends StatefulWidget {
  const ItemList({super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else {
            return ListView(
              children: snapshot.hasData
                  ? snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
                      return Card(
                        child: ListTile(
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    dynamic data = await FirebaseFirestore
                                        .instance
                                        .collection('items')
                                        .doc(doc.id)
                                        .get();
                                    await FirebaseFirestore.instance
                                        .collection('items')
                                        .doc(doc.id)
                                        .update({
                                      'item_quantity': data['item_quantity'] - 1
                                    });
                                  },
                                  icon: Icon(Icons.arrow_left)),
                              Text('${doc.get('item_quantity')}'),
                              IconButton(
                                  onPressed: () async {
                                    dynamic data = await FirebaseFirestore
                                        .instance
                                        .collection('items')
                                        .doc(doc.id)
                                        .get();
                                    await FirebaseFirestore.instance
                                        .collection('items')
                                        .doc(doc.id)
                                        .update({
                                      'item_quantity': data['item_quantity'] + 1
                                    });
                                  },
                                  icon: Icon(Icons.arrow_right)),
                            ],
                          ),
                          leading: Icon(
                            Icons.image,
                          ),
                          title: Text('${doc.get('item_name')}'),
                        ),
                      );
                    }).toList()
                  : [],
            );
          }
        },
      ),
    );
  }
}
