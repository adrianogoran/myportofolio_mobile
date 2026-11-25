import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506558251";
  final String nama = "Goran Adriano Tamrella";
  final String kelas = "PBP KKI";

  final List<ItemHomepage> items = [
    ItemHomepage(
      "View Projects",
      Icons.folder,
      Colors.blue,
      destination: (context) => const ProjectListScreen(),
    ),
    ItemHomepage(
      "Add Project",
      Icons.add_circle,
      Colors.green,
      destination: (context) => const ProjectFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage(
      "Add Education",
      Icons.school,
      Colors.purple,
      destination: (context) => const EducationFormPage(),
    ),
    ItemHomepage("Logout", Icons.logout, Colors.red, isLogout: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Horizontal row showing 3 InfoCards.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: 'NPM', content: npm),
                InfoCard(title: 'Name', content: nama),
                InfoCard(title: 'Class', content: kelas),
              ],
            ),

            const SizedBox(height: 16.0),

            // Greeting and 3-column action grid.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Welcome to MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  GridView.count(
                    primary: true,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Information card displaying a title and its associated content.
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}

/// Data model for a single action button on the home page.
///
/// Each item carries its own [color] and an optional [destination],
/// so [ItemCard] can style itself and navigate without any if-else
/// chains on the item name.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  /// Builds the screen opened with `Navigator.push()` when the card is
  /// tapped. `null` means the card only shows a SnackBar.
  final WidgetBuilder? destination;

  /// Whether the user must log in before [destination] opens.
  final bool requiresLogin;

  /// Whether tapping the card ends the current session.
  final bool isLogout;

  ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.destination,
    this.requiresLogin = false,
    this.isLogout = false,
  });
}
