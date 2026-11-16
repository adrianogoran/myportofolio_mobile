# MyPortfolio Mobile

The Flutter mobile app for my personal portfolio, built for the Platform-Based Programming (PBP) course at Fasilkom UI, Odd Semester 2026/2027. It extends the Django portfolio website onto mobile. The Django code lives in a separate repository.

| | |
|---|---|
| **Name** | Goran Adriano Tamrella |
| **NPM** | 2506558251 |
| **Class** | PBP KKI |

## Setup

Requirements: Flutter SDK (stable channel, Dart `^3.14.0`) and an emulator, a physical device, or Chrome.

```bash
git clone https://github.com/adrianogoran/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
flutter run            # pick a device, or: flutter run -d chrome
flutter analyze        # should print "No issues found!"
```

## Project Structure

```
lib/
├── main.dart   # Bootstrap: runApp() + MyApp (MaterialApp, theme)
└── menu.dart   # MyHomePage (StatelessWidget), InfoCard, ItemHomepage, ItemCard
```

## Weekly Progress

| Week | Topic | What was added |
|---|---|---|
| Tutorial 08 | Basic Flutter | Created the project, moved `MyHomePage` into `menu.dart`, made it a `StatelessWidget`, added `InfoCard`, `ItemCard` and the SnackBar on tap |
| Assignment 7 | Basic Flutter | Showed my own identity (NPM, full name, class), gave each action button its own colour through a `color` field on `ItemHomepage`, wrote this README |

---

### Assignment 7

1. **Widget tree and parent-child relationships**

   In Flutter, everything on screen is a widget, and widgets are nested inside each other to form a tree. The root of this app is `MyApp`. It returns a `MaterialApp`, whose `home` is `MyHomePage`. That returns a `Scaffold`, which holds an `AppBar` and a `body`, and so on down to `Text` and `Icon` at the leaves.

   - A **parent** decides where and how its children are placed. Single-child widgets such as `Padding`, `Center` and `Container` take a `child`. Multi-child widgets such as `Row`, `Column` and `GridView` take `children`.
   - Layout follows one rule: constraints go down, sizes go up, and the parent sets the position. The parent tells the child how big it may be, the child picks its size within those limits, and the parent then places it.
   - Data also travels down the tree. A child can read things provided by its ancestors, such as `Theme.of(context)`, `MediaQuery.of(context)` or `ScaffoldMessenger.of(context)`.
   - When a widget rebuilds, only its subtree is rebuilt. Flutter then compares the new widgets with the existing Element tree and updates only what changed.

2. **Widgets used in this project**

   | Widget | Function |
   |---|---|
   | `MaterialApp` | Root of the app. Sets the title, theme and home page, and provides Material features such as navigation and localization |
   | `Scaffold` | Basic Material page layout with slots for `appBar` and `body`. It also hosts SnackBars |
   | `AppBar` | The top bar showing the title "MyPortfolio" |
   | `Text` | Shows text: the title, card labels, button names and the welcome message |
   | `Padding` | Adds empty space around its child |
   | `Column` | Arranges its children vertically |
   | `Row` | Arranges the 3 `InfoCard`s horizontally |
   | `SizedBox` | Fixed-height gap between sections |
   | `Center` | Centres its child |
   | `GridView.count` | 3-column grid that holds the `ItemCard`s. `shrinkWrap: true` makes it fit inside the `Column` |
   | `Card` | Raised Material surface used by `InfoCard` |
   | `Container` | Sets the width and padding inside the cards |
   | `Material` | Gives each `ItemCard` its background colour (`item.color`), rounded corners and a surface for ink effects |
   | `InkWell` | Handles taps and shows the ripple effect |
   | `Icon` | Shows each button's icon (folder, add, logout) |
   | `SnackBar` | Short message at the bottom: "You pressed the [Button Name] button!" |
   | `ScaffoldMessenger` | Shows and hides SnackBars for the nearest `Scaffold` |
   | `InfoCard` *(custom)* | Stateless card showing a title and its content (NPM / Name / Class) |
   | `ItemCard` *(custom)* | Stateless coloured button built from an `ItemHomepage` model |
   | `MyHomePage` *(custom)* | The main page (stateless) |
   | `MyApp` *(custom)* | The root widget that builds `MaterialApp` |

   I also used `Theme`/`ThemeData`/`ColorScheme` (theming) and `MediaQuery` (reading the screen width). These are inherited data rather than visible layout widgets.

3. **Purpose of `MaterialApp`**

   `MaterialApp` wraps the app in everything Material Design widgets expect to find above them:
   - a **theme** (`ThemeData`, `ColorScheme`), so any widget can call `Theme.of(context)`
   - a **Navigator** and route handling (`home`, `routes`, `onGenerateRoute`) for moving between pages
   - **localization**, text direction and `MediaQuery`
   - a root `ScaffoldMessenger`, used for SnackBars
   - the app `title` used by the OS task switcher

   Widgets such as `Scaffold`, `AppBar`, `InkWell` and `SnackBar` look up these ancestors through `context`. Without `MaterialApp` above them, they fail or render incorrectly. That is why it is almost always the root widget. The main alternatives are `CupertinoApp` for iOS styling and `WidgetsApp` for a bare app with no design system.

4. **`StatelessWidget` vs `StatefulWidget`**

   - A **`StatelessWidget`** has no mutable state. Its output depends only on its constructor parameters and inherited data. It rebuilds only when its parent rebuilds it with new parameters or when an inherited value it depends on changes.
   - A **`StatefulWidget`** is paired with a `State` object that lives across rebuilds. Calling `setState()` marks it dirty so that `build()` runs again with the new values. It also has lifecycle methods (`initState`, `didUpdateWidget`, `dispose`).

   Choose **stateless** when the UI is fully determined by its inputs. Examples here are `MyHomePage`, `InfoCard` and `ItemCard`: the identity data is fixed, and the SnackBar is triggered without storing anything. Choose **stateful** when the widget must remember something that changes while it is on screen. Examples are a counter, form input, a checkbox or toggle, an animation controller, or data loaded asynchronously that should update the UI. It is good practice to keep as much of the tree stateless as possible and keep state small and close to where it is used.

5. **`BuildContext`**

   `BuildContext` is a handle to a widget's position in the tree. Under the hood it is the widget's `Element`. Every `build(BuildContext context)` receives the context of the widget being built. It matters because Flutter finds services by walking up the tree from that position:
   - `Theme.of(context).colorScheme.primary` sets the AppBar colour
   - `MediaQuery.of(context).size.width` sets the `InfoCard` width
   - `ScaffoldMessenger.of(context).showSnackBar(...)` shows the message in `ItemCard`
   - `Navigator.of(context)` will be used for page navigation later

   Because the lookup starts from where the context is, the *right* context matters. For example, a context from above the `Scaffold` cannot find that `Scaffold`. A context should also not be used after its widget has been removed from the tree.

6. **Hot reload vs hot restart**

   - **Hot reload** (`r` in the terminal, or saving in the IDE) injects the changed source into the running Dart VM and re-runs `build()`. **State is kept**: the current page, form values and `State` fields stay as they were. It is the fastest way to iterate on UI.
   - **Hot restart** (`R`) reloads the code and **restarts the app from `main()`**, so all state is lost. It is still faster than a full rebuild because the native app is not recompiled.
   - **Full restart** (stop, then `flutter run` again) recompiles everything, including native code.

   Hot reload is **not enough** when the change affects code that ran only once or was already initialised:
   - changes to `main()` or code that runs before `runApp()`
   - changes to `initState()` (it does not run again for a widget that already exists)
   - changing the initial values of static or global variables, which were already initialised
   - converting a `StatelessWidget` into a `StatefulWidget` or the reverse, or changing generic type parameters
   - changing an `enum` into a regular class or the reverse

   These need a **hot restart**. A **full restart** is needed for native or platform changes: editing `pubspec.yaml` to add plugins, changing Android or iOS files (Gradle, `AndroidManifest.xml`, `Info.plist`), or changing assets. Hot reload and hot restart also only work in debug mode, not in profile or release builds.

---

## AI Usage Disclosure
- I didnt use AI in this task, i referred to the tutorial files and documentation for the button and item cards.