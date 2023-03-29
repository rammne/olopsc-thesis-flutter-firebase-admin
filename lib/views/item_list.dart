import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemList extends StatefulWidget {
  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final formKey = GlobalKey<FormState>();

  late Map<String, bool> isEditing;
  String? editItemName;
  int? editStocks;
  int? editAvailItems;
  String? editRemarks;
  String itemNameQuery = '';
  String sortItemName = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEditing = {};
    editItemName = '';
    editRemarks = '';
  }

  @override
  Widget build(BuildContext context) {
    void lentItemsClear(String itemName, itemID) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('${itemName}'),
            content: Text('Clear Lent Items Cell?'),
            actions: [
              ElevatedButton(
                child: Text('Yes'),
                onPressed: () async {
                  DocumentSnapshot itemData = await FirebaseFirestore.instance
                      .collection('items')
                      .doc(itemID)
                      .get();

                  if (itemData['lent_items'] != 0) {
                    itemData.reference.update(
                      {
                        'lent_items': 0,
                        'available_items': itemData['available_items'] +
                            itemData['lent_items'],
                      },
                    );
                    final snackBar = SnackBar(
                      content: Text('Cell Cleared'),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    final snackBar = SnackBar(
                      content: Text('Already Cleared'),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: StreamBuilder(
        stream: itemNameQuery != '' && itemNameQuery != null
            ? FirebaseFirestore.instance
                .collection('items')
                .where('searchable_item_name', arrayContains: itemNameQuery)
                .snapshots()
            : FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter an Item Name...',
                          icon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            itemNameQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DataTable(
                        dividerThickness: 5,
                        dataRowHeight: 200,
                        columns: [
                          DataColumn(
                            label: Text('Item Name'),
                          ),
                          DataColumn(
                            label: Text('Stocks'),
                          ),
                          DataColumn(
                            label: Text('Available Items'),
                          ),
                          DataColumn(
                            label: Text('Lent Items'),
                          ),
                          DataColumn(
                            label: Text('Remarks'),
                          ),
                        ],
                        rows: (snapshot.data?.docs ?? [])
                            .asMap()
                            .entries
                            .map((entry) {
                          final doc = entry.value;
                          final index = entry.key;
                          String itemNameField =
                              '${doc.get('item_name')}|${doc.id}';
                          String itemStocksField =
                              '${doc.get('item_stocks')}s|${doc.id}';
                          String availableItems =
                              '${doc.get('available_items') ?? 'no avail'}z|${doc.id}';
                          String lentItems =
                              '${doc.get('lent_items')}l|${doc.id}';
                          String remarks =
                              '${doc.get('remarks') ?? 'no remarks'}|${doc.id}';

                          isEditing.putIfAbsent(itemNameField, () => false);
                          isEditing.putIfAbsent(itemStocksField, () => false);
                          isEditing.putIfAbsent(availableItems, () => false);
                          isEditing.putIfAbsent(lentItems, () => false);
                          isEditing.putIfAbsent(remarks, () => false);

                          return DataRow(
                              color: index.isOdd
                                  ? MaterialStateProperty.all(
                                      Colors.yellow[200])
                                  : MaterialStateProperty.all(Colors.blue[200]),
                              cells: [
                                ////////////////// ITEM NAME CELL ////////////////////////////////
                                DataCell(
                                  TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                    ),
                                    onPressed: () {
                                      setState(
                                        () {
                                          isEditing[itemNameField] =
                                              !isEditing[itemNameField]!;
                                        },
                                      );
                                    },
                                    child: isEditing[itemNameField]!
                                        ? TextFormField(
                                            validator: (value) =>
                                                value!.isNotEmpty
                                                    ? null
                                                    : 'Value required',
                                            initialValue: doc.get('item_name'),
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            onEditingComplete: () async {
                                              try {
                                                await doc.reference.update({
                                                  'item_name':
                                                      editItemName != ''
                                                          ? editItemName
                                                          : doc.get('item_name')
                                                });
                                                setState(
                                                  () {
                                                    isEditing[itemNameField] =
                                                        !isEditing[
                                                            itemNameField]!;
                                                    editItemName = '';
                                                  },
                                                );
                                              } catch (e) {
                                                print(e.toString());
                                              }
                                            },
                                            onTapOutside: (_) async {
                                              try {
                                                await doc.reference.update({
                                                  'item_name':
                                                      editItemName != ''
                                                          ? editItemName
                                                          : doc.get('item_name')
                                                });
                                                setState(
                                                  () {
                                                    isEditing[itemNameField] =
                                                        !isEditing[
                                                            itemNameField]!;
                                                    editItemName = '';
                                                  },
                                                );
                                              } catch (e) {
                                                print(e.toString());
                                              }
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                editItemName =
                                                    value.toUpperCase();
                                              });
                                            },
                                          )
                                        : Text(
                                            '${doc.get('item_name')}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16),
                                          ),
                                  ),
                                ),

                                ////////////////////// ITEM STOCKS CELL ///////////////////////
                                DataCell(
                                  TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                    ),
                                    onPressed: () {
                                      setState(
                                        () {
                                          isEditing[itemStocksField] =
                                              !isEditing[itemStocksField]!;
                                        },
                                      );
                                    },
                                    child: isEditing[itemStocksField]!
                                        ? SizedBox(
                                            width: 50,
                                            child: TextFormField(
                                                initialValue: doc
                                                    .get('item_stocks')
                                                    .toString(),
                                                autofocus: true,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (value) {
                                                  print('object');
                                                  setState(() {
                                                    editStocks =
                                                        int.parse(value);
                                                  });
                                                },
                                                onEditingComplete: () async {
                                                  try {
                                                    await doc.reference.update({
                                                      'item_stocks':
                                                          editStocks != null
                                                              ? editStocks
                                                              : doc.get(
                                                                  'item_stocks')
                                                    });
                                                  } catch (e) {
                                                    print(e.toString());
                                                  }
                                                  setState(() {
                                                    isEditing[itemStocksField] =
                                                        !isEditing[
                                                            itemStocksField]!;
                                                    editStocks = null;
                                                  });
                                                },
                                                onTapOutside: (_) async {
                                                  try {
                                                    await doc.reference.update({
                                                      'item_stocks':
                                                          editStocks != null
                                                              ? editStocks
                                                              : doc.get(
                                                                  'item_stocks')
                                                    });
                                                  } catch (e) {
                                                    print(e.toString());
                                                  }
                                                  setState(() {
                                                    isEditing[itemStocksField] =
                                                        !isEditing[
                                                            itemStocksField]!;
                                                    editStocks = null;
                                                  });
                                                }),
                                          )
                                        : Text('${doc.get('item_stocks')}'),
                                  ),
                                ),

                                ////////////////////// AVAILABLE ITEMS CELL ////////////////
                                DataCell(
                                  TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          doc.get('available_items') != null
                                              ? MaterialStateProperty.all(
                                                  Colors.black)
                                              : MaterialStateProperty.all(
                                                  Colors.blue),
                                    ),
                                    onPressed: () {
                                      if (isEditing[availableItems] != null) {
                                        setState(() {
                                          isEditing[availableItems] =
                                              !isEditing[availableItems]!;
                                        });
                                      }
                                    },
                                    child: isEditing[availableItems]!
                                        ? SizedBox(
                                            width: 50,
                                            child: TextFormField(
                                              validator: (value) => int.parse(
                                                          value!) <
                                                      doc.get('item_stocks ')
                                                  ? null
                                                  : '',
                                              initialValue: doc.get(
                                                          'available_items') !=
                                                      null
                                                  ? doc
                                                      .get('available_items')
                                                      .toString()
                                                  : null,
                                              autofocus: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  editAvailItems = value != ''
                                                      ? int.parse(value)
                                                      : null;
                                                });
                                              },
                                              onEditingComplete: () async {
                                                try {
                                                  if (editAvailItems! <=
                                                      doc.get('item_stocks')) {
                                                    await doc.reference.update({
                                                      'available_items':
                                                          editAvailItems != null
                                                              ? editAvailItems
                                                              : doc.get(
                                                                  'available_items')
                                                    });
                                                  } else if (editAvailItems! >=
                                                      doc.get('item_stocks')) {
                                                    await doc.reference.update({
                                                      'available_items':
                                                          doc.get('item_stocks')
                                                    });
                                                  }
                                                } catch (e) {
                                                  print(e.toString());
                                                }
                                                setState(() {
                                                  isEditing[availableItems] =
                                                      !isEditing[
                                                          availableItems]!;
                                                  editAvailItems = null;
                                                });
                                              },
                                              onTapOutside: (event) async {
                                                // if (isEditing[availableItems] !=
                                                //     null) {
                                                try {
                                                  if (editAvailItems! <=
                                                      doc.get('item_stocks')) {
                                                    await doc.reference.update({
                                                      'available_items':
                                                          editAvailItems != null
                                                              ? editAvailItems
                                                              : doc.get(
                                                                  'available_items')
                                                    });
                                                  } else if (editAvailItems! >=
                                                      doc.get('item_stocks')) {
                                                    await doc.reference.update({
                                                      'available_items':
                                                          doc.get('item_stocks')
                                                    });
                                                  }
                                                } catch (e) {
                                                  print(e.toString());
                                                }
                                                setState(() {
                                                  isEditing[availableItems] =
                                                      !isEditing[
                                                          availableItems]!;
                                                  editAvailItems = null;
                                                });
                                              },
                                            ),
                                          )
                                        : Text(
                                            '${doc.get('available_items') ?? 'Click to add data'}'),
                                  ),
                                ),

                                //////////////////// LENT ITEMS CELL ///////////////////////////////////

                                DataCell(
                                  TextButton(
                                    onPressed: () {
                                      lentItemsClear(
                                        doc.get('item_name'),
                                        doc.id,
                                      );
                                    },
                                    child: Text(
                                      '${doc.get('lent_items')}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),

                                ///////////////////////// REMARKS CELL ///////////////////////////////////////
                                DataCell(
                                  TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          doc.get('remarks') != null
                                              ? MaterialStateProperty.all(
                                                  Colors.black)
                                              : MaterialStateProperty.all(
                                                  Colors.blue),
                                    ),
                                    onPressed: () {
                                      if (isEditing[remarks] != null) {
                                        setState(() {
                                          isEditing[remarks] =
                                              !isEditing[remarks]!;
                                        });
                                      }
                                    },
                                    child: isEditing[remarks]!
                                        ? SizedBox(
                                            width: 300,
                                            child: TextFormField(
                                              maxLength: 25,
                                              maxLines: 2,
                                              initialValue:
                                                  doc.get('remarks') ?? '',
                                              autofocus: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  editRemarks = value;
                                                });
                                              },
                                              onTapOutside: (event) async {
                                                // if (isEditing[remarks] != null) {
                                                if (editRemarks != '') {
                                                  try {
                                                    await doc.reference.update({
                                                      'remarks': editRemarks
                                                    });
                                                  } catch (e) {
                                                    print(e.toString());
                                                  }
                                                }
                                                setState(() {
                                                  isEditing[remarks] =
                                                      !isEditing[remarks]!;
                                                  editRemarks = '';
                                                });
                                              },
                                            ),
                                          )
                                        : Text(
                                            '${doc.get('remarks') ?? 'Click to add data'}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                  ),
                                ),
                              ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}




// ListView.builder(
//               itemCount: snapshot.data?.docs.length ?? 0,
//               itemBuilder: (context, index) {
//                 DocumentSnapshot itemData = snapshot.data!.docs[index];
//                 return Dismissible(
//                   direction: DismissDirection.startToEnd,
//                   background: Container(
//                     color: Colors.red[400],
//                   ),
//                   key: UniqueKey(),
//                   child: Card(
//                     child: ListTile(
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                               onPressed: () async {
//                                 dynamic data = await FirebaseFirestore.instance
//                                     .collection('items')
//                                     .doc(itemData.id)
//                                     .get();
//                                 await FirebaseFirestore.instance
//                                     .collection('items')
//                                     .doc(itemData.id)
//                                     .update({
//                                   'item_quantity': data['item_quantity'] - 1
//                                 });
//                               },
//                               icon: Icon(Icons.arrow_left)),
//                           Text('${itemData['item_quantity']}'),
//                           IconButton(
//                               onPressed: () async {
//                                 dynamic data = await FirebaseFirestore.instance
//                                     .collection('items')
//                                     .doc(itemData.id)
//                                     .get();
//                                 await FirebaseFirestore.instance
//                                     .collection('items')
//                                     .doc(itemData.id)
//                                     .update({
//                                   'item_quantity': data['item_quantity'] + 1
//                                 });
//                               },
//                               icon: Icon(Icons.arrow_right)),
//                         ],
//                       ),
//                       leading: Icon(
//                         Icons.image,
//                       ),
//                       title: Text('${itemData['item_name']}'),
//                     ),
//                   ),
//                   onDismissed: (direction) {
//                     itemData.reference.delete();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text("Item dismissed"),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );