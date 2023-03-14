import 'package:admin/views/history_page.dart';
import 'package:admin/views/item_list.dart';
import 'package:admin/views/requests_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../add_item_form.dart';
import '../students_list.dart';

class DesktopAdminPanel extends StatefulWidget {
  const DesktopAdminPanel({super.key});

  @override
  State<DesktopAdminPanel> createState() => _DesktopAdminPanelState();
}

class _DesktopAdminPanelState extends State<DesktopAdminPanel> {
  //states
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    void _showSettings() async {
      showModalBottomSheet(
          constraints: BoxConstraints(maxWidth: 400),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          context: context,
          builder: (context) => AddItemForm());
    }

    Future<void> deleteAllRequests() async {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (DocumentSnapshot userDoc in usersSnapshot.docs) {
        QuerySnapshot requestsSnapshot =
            await userDoc.reference.collection('requests').get();

        for (DocumentSnapshot requestDoc in requestsSnapshot.docs) {
          batch.delete(requestDoc.reference);
        }
      }

      await batch.commit();
    }

    Widget page = ItemList();
    switch (selectedIndex) {
      case 0:
        page = StudentsList();
        break;
      case 1:
        page = ItemList();
        break;
      case 2:
        page = RequestsPage();
        break;
      case 3:
        page = History();
        break;
      default:
        throw UnimplementedError('Something went wrong with ${selectedIndex}');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                trailing: selectedIndex == 1
                    ? TextButton.icon(
                        onPressed: () async {
                          _showSettings();
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                        label: Text(
                          'Add Item',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    : selectedIndex != 0
                        ? IconButton(
                            onPressed: () {
                              deleteAllRequests();
                            },
                            icon: Icon(Icons.delete))
                        : null,
                minExtendedWidth: 150,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.group),
                    label: Text('Students'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.list),
                    label: Text('List'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.pending),
                    label: Text('Requests'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history),
                    label: Text('History'),
                  ),
                ],
                selectedIndex: selectedIndex,
                extended: constraints.maxWidth >= 600,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(child: page)
          ],
        ),
      );
    });
  }
}
