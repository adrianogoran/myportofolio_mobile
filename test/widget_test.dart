import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const project = {
    'id': '1',
    'title': 'Sample Project',
    'description': 'Portfolio app',
    'tech_stack': 'Flutter',
    'project_url': 'https://example.com',
    'project_image_url': null,
  };

  // The test font is much wider than real fonts, so use a tall screen and
  // smaller text to lay the pages out the way a phone does.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .implicitView!;
    view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    view.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(view.reset);
    addTearDown(view.platformDispatcher.clearTextScaleFactorTestValue);
  });

  // Records requests and answers like the Django backend.
  Widget app(
    List<http.Request> requests, {
    bool empty = false,
    int createStatus = 201,
  }) {
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.path.endsWith('/auth/token/')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return body['password'] == 'right'
            ? http.Response('{"token": "abc"}', 200)
            : http.Response('{}', 400);
      }
      if (request.url.path.endsWith('/auth/logout/')) {
        return http.Response('', 204);
      }
      if (request.method == 'POST') {
        return http.Response(jsonEncode(project), createStatus);
      }
      return http.Response(jsonEncode(empty ? [] : [project]), 200);
    });
    return MyApp(apiClient: ApiClient(client: client));
  }

  Future<void> login(WidgetTester tester, String password) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'owner');
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  Future<void> fillAndSave(WidgetTester tester) async {
    const values = ['T', 'D', 'Flutter', 'https://example.com'];
    for (final (index, value) in values.indexed) {
      await tester.enterText(find.byType(TextFormField).at(index), value);
    }
    // Wait for the SnackBar to go away so it does not cover the button.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final save = find.widgetWithText(ElevatedButton, 'Save');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  testWidgets('projects are public and open a detail screen', (tester) async {
    await tester.pumpWidget(app([]));
    await tester.tap(find.text('View Projects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sample Project'));
    await tester.pumpAndSettle();
    expect(find.text('Tech Stack: Flutter'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('empty list shows a message', (tester) async {
    await tester.pumpWidget(app([], empty: true));
    await tester.tap(find.text('View Projects'));
    await tester.pumpAndSettle();
    expect(find.text('No projects found.'), findsOneWidget);
  });

  testWidgets('server error can be retried', (tester) async {
    final client = MockClient((_) async => http.Response('secret', 500));
    await tester.pumpWidget(MyApp(apiClient: ApiClient(client: client)));
    await tester.tap(find.text('View Projects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.textContaining('server error (500)'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
  });

  testWidgets('login guard, authenticated POST and logout', (tester) async {
    final requests = <http.Request>[];
    await tester.pumpWidget(app(requests));
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    await login(tester, 'wrong');
    expect(find.textContaining('(400)'), findsOneWidget);
    await login(tester, 'right');
    expect(find.text('Add Project Form'), findsOneWidget);

    await fillAndSave(tester);
    expect(find.text('Project added successfully!'), findsOneWidget);
    expect(requests.last.headers['Authorization'], 'Token abc');
    final body = jsonDecode(requests.last.body) as Map<String, dynamic>;
    expect(body['tech_stack'], 'Flutter');
    expect(body.containsKey('id'), isFalse);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Add Project Form'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(requests.last.url.path, '/api/v1/auth/logout/');
    expect(find.text('You have logged out.'), findsOneWidget);
  });

  testWidgets('expired token prompts login again', (tester) async {
    await tester.pumpWidget(app([], createStatus: 401));
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    await login(tester, 'right');
    await fillAndSave(tester);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('drawer guards Add Project', (tester) async {
    await tester.pumpWidget(app([]));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
    await tester.pumpAndSettle();
    await login(tester, 'right');
    expect(find.text('Add Project Form'), findsOneWidget);
  });
}
