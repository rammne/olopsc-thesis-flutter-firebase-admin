import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddItemForm extends StatefulWidget {
  const AddItemForm({super.key});

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  String itemName = '';
  int itemQuantity = 0;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Text('Item Name:'),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              validator: (value) => value!.isNotEmpty ? null : '',
              decoration: InputDecoration(border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  itemName = value;
                });
              },
              onFieldSubmitted: (value) async {
                if (_formKey.currentState!.validate() &&
                    (itemName != '' && itemName != null) &&
                    (itemQuantity != '' && itemQuantity != null)) {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance.collection('items').add(
                      {'item_name': itemName, 'item_quantity': itemQuantity});
                }
              },
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text('Quantity:'),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 175),
            child: TextFormField(
              validator: (value) => value == int ? null : '',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  try {
                    itemQuantity = int.parse(value);
                  } catch (e) {
                    print(e.toString());
                  }
                });
              },
              onFieldSubmitted: (value) async {
                if (_formKey.currentState!.validate() &&
                    (itemName != '' && itemName != null) &&
                    (itemQuantity != '' && itemQuantity != null)) {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance.collection('items').add(
                      {'item_name': itemName, 'item_quantity': itemQuantity});
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
