import 'package:flutter/material.dart';

import '../views/responsive_views/desktop_view.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth <= 400) {
        return Text('MOBILE');
      } else if (constraints.maxWidth <= 800) {
        return Text('TABLET');
      } else {
        return DesktopAdminPanel();
      }
    });
  }
}
