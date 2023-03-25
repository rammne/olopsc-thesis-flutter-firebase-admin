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
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('items').get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: SizedBox(
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
                      String remarks =
                          '${doc.get('remarks') ?? 'no remarks'}|${doc.id}';

                      isEditing.putIfAbsent(itemNameField, () => false);
                      isEditing.putIfAbsent(itemStocksField, () => false);
                      isEditing.putIfAbsent(availableItems, () => false);
                      isEditing.putIfAbsent(remarks, () => false);

                      return DataRow(
                          color: index.isOdd
                              ? MaterialStateProperty.all(Colors.grey[400])
                              : MaterialStateProperty.all(Colors.grey[200]),
                          cells: [
                            ////////////////// ITEM NAME CELL ////////////////////////////////
                            DataCell(
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
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
                                        validator: (value) => value!.isNotEmpty
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
                                              'item_name': editItemName != ''
                                                  ? editItemName
                                                  : doc.get('item_name')
                                            });
                                            setState(
                                              () {
                                                isEditing[itemNameField] =
                                                    !isEditing[itemNameField]!;
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
                                              'item_name': editItemName != ''
                                                  ? editItemName
                                                  : doc.get('item_name')
                                            });
                                            setState(
                                              () {
                                                isEditing[itemNameField] =
                                                    !isEditing[itemNameField]!;
                                                editItemName = '';
                                              },
                                            );
                                          } catch (e) {
                                            print(e.toString());
                                          }
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            editItemName = value;
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
                                      MaterialStateProperty.all(Colors.black),
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
                                                editStocks = int.parse(value);
                                              });
                                            },
                                            onTapOutside: (_) async {
                                              try {
                                                await doc.reference.update({
                                                  'item_stocks': editStocks !=
                                                          null
                                                      ? editStocks
                                                      : doc.get('item_stocks')
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
                                  foregroundColor: doc.get('available_items') !=
                                          null
                                      ? MaterialStateProperty.all(Colors.black)
                                      : MaterialStateProperty.all(Colors.blue),
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
                                          validator: (value) =>
                                              int.parse(value!) <
                                                      doc.get('item_stocks ')
                                                  ? null
                                                  : '',
                                          initialValue:
                                              doc.get('available_items') != null
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
                                                  !isEditing[availableItems]!;
                                              editAvailItems = null;
                                            });
                                          },
                                        ),
                                      )
                                    : Text(
                                        '${doc.get('available_items') ?? 'Click to add data'}'),
                              ),
                            ),

                            ///////////////////////// REMARKS CELL ///////////////////////////////////////
                            DataCell(
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor: doc.get('remarks') != null
                                      ? MaterialStateProperty.all(Colors.black)
                                      : MaterialStateProperty.all(Colors.blue),
                                ),
                                onPressed: () {
                                  if (isEditing[remarks] != null) {
                                    setState(() {
                                      isEditing[remarks] = !isEditing[remarks]!;
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
                                                await doc.reference.update(
                                                    {'remarks': editRemarks});
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