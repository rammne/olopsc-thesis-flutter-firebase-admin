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
  int itemStocks = 0;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
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
            SizedBox(
              width: 200,
              child: TextFormField(
                autofocus: true,
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
                      (itemStocks != '' && itemStocks != null)) {
                    Navigator.pop(context);
                    await FirebaseFirestore.instance.collection('items').add({
                      'item_name': itemName,
                      'item_stocks': itemStocks,
                      'available_items': null,
                      'remarks': null,
                    });
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
            SizedBox(
              width: 50,
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    try {
                      itemStocks = int.parse(value);
                    } catch (e) {
                      print(e.toString());
                    }
                  });
                },
                onFieldSubmitted: (value) async {
                  if (_formKey.currentState!.validate() &&
                      (itemName != '' && itemName != null) &&
                      (itemStocks != '' && itemStocks != null)) {
                    Navigator.pop(context);
                    await FirebaseFirestore.instance.collection('items').add({
                      'item_name': itemName,
                      'item_stocks': itemStocks,
                      'available_items': null,
                      'remarks': null,
                    });
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  fixedSize:
                      MaterialStateProperty.resolveWith((_) => Size(200, 50)),
                  backgroundColor:
                      MaterialStateColor.resolveWith((_) => Colors.black)),
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    (itemName != '' && itemName != null) &&
                    (itemStocks != '' && itemStocks != null)) {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance.collection('items').add({
                    'item_name': itemName,
                    'item_stocks': itemStocks,
                    'available_items': null,
                    'remarks': null,
                  });
                }
              },
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
