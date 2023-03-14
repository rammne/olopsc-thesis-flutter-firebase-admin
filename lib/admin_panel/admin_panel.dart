import 'package:flutter/material.dart';

import '../views/responsive_views/desktop_view.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxHeight <= 350) {
        return Center(
          child: Text('Screen size is too small to work with.'),
        );
      }
      return DesktopAdminPanel();
    });
  }
}
