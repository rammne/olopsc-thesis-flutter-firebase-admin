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
            return ListView.builder(
              itemCount: snapshot.data?.docs.length ?? 0,
              itemBuilder: (context, index) {
                DocumentSnapshot itemData = snapshot.data!.docs[index];
                return Dismissible(
                  background: Container(
                    color: Colors.grey[400],
                  ),
                  key: UniqueKey(),
                  child: Card(
                    child: ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () async {
                                dynamic data = await FirebaseFirestore.instance
                                    .collection('items')
                                    .doc(itemData.id)
                                    .get();
                                await FirebaseFirestore.instance
                                    .collection('items')
                                    .doc(itemData.id)
                                    .update({
                                  'item_quantity': data['item_quantity'] - 1
                                });
                              },
                              icon: Icon(Icons.arrow_left)),
                          Text('${itemData['item_quantity']}'),
                          IconButton(
                              onPressed: () async {
                                dynamic data = await FirebaseFirestore.instance
                                    .collection('items')
                                    .doc(itemData.id)
                                    .get();
                                await FirebaseFirestore.instance
                                    .collection('items')
                                    .doc(itemData.id)
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
                      title: Text('${itemData['item_name']}'),
                    ),
                  ),
                  onDismissed: (direction) {
                    itemData.reference.delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Item dismissed"),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
