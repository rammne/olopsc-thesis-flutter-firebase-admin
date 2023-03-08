import 'package:admin/views/history_page.dart';
import 'package:admin/views/item_list.dart';
import 'package:admin/views/requests_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    void _showSettings() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container();
        },
      );
    }

    Widget page = ItemList();
    switch (selectedIndex) {
      case 0:
        page = ItemList();
        break;
      case 1:
        page = RequestsPage();
        break;
      case 2:
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
                trailing: selectedIndex == 0
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
                    : IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
                minExtendedWidth: 150,
                destinations: [
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
