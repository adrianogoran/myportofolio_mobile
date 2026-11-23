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
├── main.dart                 # Bootstrap: runApp() + MyApp (MaterialApp, theme)
├── screens/
│   ├── menu.dart             # MyHomePage, InfoCard, ItemHomepage model
│   ├── project_form.dart     # ProjectFormPage (StatefulWidget form)
│   └── education_form.dart   # EducationFormPage (dates, GPA, URL validation)
└── widgets/
    ├── left_drawer.dart      # LeftDrawer navigation menu (Home / Add Project / Add Education)
    └── project_card.dart     # ItemCard (coloured button + navigation)
```

## Weekly Progress

| Week | Topic | What was added |
|---|---|---|
| Tutorial 08 | Basic Flutter | Created the project, moved `MyHomePage` into `menu.dart`, made it a `StatelessWidget`, added `InfoCard`, `ItemCard` and the SnackBar on tap |
| Assignment 7 | Basic Flutter | Showed my own identity (NPM, full name, class), gave each action button its own colour through a `color` field on `ItemHomepage`, wrote this README |
| Tutorial 09 | Navigation, Layouts, Forms | Added a `LeftDrawer` (Home / Add Project), `ProjectFormPage` with validated `TextFormField`s and a category dropdown, a dialog showing the submitted data, `Navigator.push` from the Add Project card, and split files into `screens/` and `widgets/` |
| Assignment 8 | Navigation, Layouts, Forms | Added `EducationFormPage` (institution, degree dropdown, field of study, start/end dates with `showDatePicker`, "currently studying" checkbox, optional GPA and website) with validation and a summary `AlertDialog`; an **Add Education** action card and drawer entry; `ItemHomepage.destination` so cards navigate without if-else on names; drawer navigation that keeps Home as the root route |

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

### Assignment 8

1. **`Navigator.push()` vs `pushReplacement()` vs `pop()`**

   Flutter's `Navigator` keeps the pages as a stack of routes.
   - `push()` puts a new route **on top** of the current one. The old page stays underneath, so Back (or `pop()`) returns to it.
   - `pushReplacement()` pushes the new route and **removes the current one** at the same time. Back skips the replaced page.
   - `pop()` removes the **top** route and returns to the page below it. It can also return a value to the page that pushed it. It also closes things that live on top of a route, such as a dialog (the **OK** button in the summary dialog uses `Navigator.pop(context)`) or an open drawer.

   The **Add Education** action card opens the form with `Navigator.push()`. `ItemCard` reads the card's `destination` builder and pushes it, so the home screen stays below and the system Back button returns to it.

   The **Home** option in the drawer calls `Navigator.popUntil(context, (route) => route.isFirst)`. It pops every route above the first one, including the open drawer, until only the original `MyHomePage` is left. Tutorial 09 used `pushReplacement(MyHomePage())`, but that builds a *second* home on top of the first when the form was opened with `push()`, so Back would show Home again. With `popUntil` there is always exactly one home at the bottom of the stack. The form entries in the drawer use `push()` when opened from Home and `pushReplacement()` when opened from another form, so forms never pile up.

2. **Consistent page structure with `Scaffold`, `AppBar` and `Drawer`**

   Every page (`MyHomePage`, `ProjectFormPage`, `EducationFormPage`) returns the same skeleton: a `Scaffold` with an `appBar`, `drawer: const LeftDrawer()` and a `body`. The `Scaffold` gives each page the same slots, so the title bar is always at the top, the hamburger button that opens the drawer is always in the same place, and only the `body` changes. Because `LeftDrawer` is one widget in `lib/widgets/` reused by all pages, adding the **Add Education** entry once made it appear everywhere.

   Colours come from the theme set once in `main.dart` (`ColorScheme.fromSeed(seedColor: Colors.indigo)`). For example, `Theme.of(context).colorScheme.primary` is used for the home `AppBar` background, the Education form `AppBar` background, and the Education form's **Save** button. All three use white text and icons on top. The drawer header and the Project form use the matching `Colors.indigo`.

3. **Form layout and behaviour when space is limited**

   The form is a single column of fields, one per row, which suits a narrow phone screen and reads top to bottom in the order you would fill it in. Each field uses a label and an `OutlineInputBorder`, so it stays clear what the field is after text is typed in. The fields that are fixed choices use input widgets that prevent typing mistakes: a `DropdownButtonFormField` for the degree, `showDatePicker()` behind read-only date fields, and a `CheckboxListTile` for "currently studying". Ticking that checkbox hides the End Date field, since it no longer applies.

   - `Padding(EdgeInsets.all(8))` around every field keeps them apart, so the error text under a field doesn't collide with the next one and tap targets stay separate.
   - `SingleChildScrollView` wraps the `Column`. When the keyboard opens, the `Scaffold` shrinks the body (`resizeToAvoidBottomInset`), and on short screens the fields are taller than the viewport. Instead of overflowing, the form scrolls, so every field and the **Save** button can still be reached.
   - The summary dialog's content is also wrapped in a `SingleChildScrollView`, so long values don't overflow the dialog.

4. **`GlobalKey<FormState>`, `validator` and `validate()`**

   - `GlobalKey<FormState>` (`_formKey`) is attached to the `Form`. It lets the **Save** button's `onPressed` reach the form's state, even though the button is not the form itself.
   - Each `TextFormField` / `DropdownButtonFormField` has a `validator`: a function that receives the current value and returns `null` if it is valid or an error string if it is not.
   - `_formKey.currentState!.validate()` runs **every** field's validator, rebuilds the fields so each error message appears under its own field, and returns `true` only if all of them passed. The summary dialog is shown only in that case.

   **Example:** the form rejects the GPA `4.5` with "GPA must be between 0.00 and 4.00." It also rejects an institution name made only of spaces, `"   "` (the validator checks `value.trim().isEmpty`). The GPA field uses `TextInputType.numberWithOptions(decimal: true)`, but a keyboard type is only a *hint* to the on-screen keyboard. It still accepts `4.5`, `3..2`, or pasted text, and on Chrome/desktop a physical keyboard ignores it completely. Similarly, `TextInputType.url` doesn't make `ui.ac.id` a valid `http(s)://` URL, and a date picker guarantees a real date but not that the end date comes after the start date. Rules about meaning, such as ranges, formats and the order between fields, can only be enforced by a validator.

---

## AI Usage Disclosure
- I didnt use AI in this task, i referred to the tutorial files and documentation for the button and item cards.