import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Pop every route above the home screen (including this
            // drawer), returning to the original MyHomePage instead of
            // stacking a second copy on top of it.
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () => _openPage(context, const ProjectFormPage()),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Add Education'),
            onTap: () => _openPage(context, const EducationFormPage()),
          ),
        ],
      ),
    );
  }

  /// Closes the drawer and opens [page], keeping the home screen as the
  /// root route so the system Back button always leads back to it.
  ///
  /// - From the home screen, the page is pushed on top of it.
  /// - From another page (e.g. one form to the other), that page is
  ///   replaced, so forms never pile up in the back stack.
  void _openPage(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    final onHome = ModalRoute.of(context)?.isFirst ?? true;
    final route = MaterialPageRoute(builder: (context) => page);

    navigator.pop(); // close the drawer
    if (onHome) {
      navigator.push(route);
    } else {
      navigator.pushReplacement(route);
    }
  }
}
