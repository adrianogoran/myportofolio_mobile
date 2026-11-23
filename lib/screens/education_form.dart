import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Form for adding an Education entry to the portfolio.
///
/// Fields follow the Education model:
/// institution, degree level, field of study, start/end date,
/// an optional GPA (0.00–4.00) and an optional institution website.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers are used for the date fields (read-only, filled by the
  // date picker) so the selected date is shown inside the text field.
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _institution = "";
  String _degree = "Bachelor's (S1)"; // default
  String _fieldOfStudy = "";
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  String _gpa = "";
  String _website = "";

  static const int _maxNameLength = 100;

  final List<String> _degrees = [
    'High School',
    "Diploma (D3)",
    "Bachelor's (S1)",
    "Master's (S2)",
    'Doctorate (S3)',
    'Course / Bootcamp',
  ];

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Formats a date as YYYY-MM-DD without needing the intl package.
  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  /// Opens the date picker and stores the result in the matching field.
  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  /// Shared validator for required free-text fields.
  String? _validateRequiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return "Enter the $label.";
    }
    if (value.trim().length > _maxNameLength) {
      return "$label must be at most $_maxNameLength characters.";
    }
    return null;
  }

  /// Clears every field after a successful save.
  void _resetForm() {
    _formKey.currentState!.reset();
    _startDateController.clear();
    _endDateController.clear();
    setState(() {
      _institution = "";
      _degree = "Bachelor's (S1)";
      _fieldOfStudy = "";
      _startDate = null;
      _endDate = null;
      _isCurrent = false;
      _gpa = "";
      _website = "";
    });
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Education Form')),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView keeps every field and the Save button
        // reachable on small screens and when the keyboard is open.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Institution ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Institution",
                    hint: "Example: Universitas Indonesia",
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (String? value) {
                    setState(() {
                      _institution = value!;
                    });
                  },
                  validator: (value) =>
                      _validateRequiredText(value, "institution name"),
                ),
              ),

              // === Degree ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: _decoration("Degree / Level"),
                  initialValue: _degree,
                  items: _degrees
                      .map(
                        (degree) => DropdownMenuItem(
                          value: degree,
                          child: Text(degree),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _degree = newValue!;
                    });
                  },
                ),
              ),

              // === Field of Study ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Field of Study",
                    hint: "Example: Computer Science",
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (String? value) {
                    setState(() {
                      _fieldOfStudy = value!;
                    });
                  },
                  validator: (value) =>
                      _validateRequiredText(value, "field of study"),
                ),
              ),

              // === Start Date ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: _decoration(
                    "Start Date",
                    hint: "Tap to choose a date",
                    suffix: const Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) {
                    if (_startDate == null) {
                      return "Choose a start date.";
                    }
                    if (_startDate!.isAfter(DateTime.now())) {
                      return "Start date cannot be in the future.";
                    }
                    return null;
                  },
                ),
              ),

              // === Currently Studying ===
              CheckboxListTile(
                title: const Text("I am currently studying here"),
                value: _isCurrent,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  setState(() {
                    _isCurrent = value ?? false;
                    if (_isCurrent) {
                      _endDate = null;
                      _endDateController.clear();
                    }
                  });
                },
              ),

              // === End Date (hidden while currently studying) ===
              if (!_isCurrent)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: _decoration(
                      "End Date",
                      hint: "Tap to choose a date",
                      suffix: const Icon(Icons.event),
                    ),
                    onTap: () => _pickDate(isStart: false),
                    validator: (_) {
                      if (_endDate == null) {
                        return "Choose an end date, or tick \"currently studying\".";
                      }
                      if (_startDate != null &&
                          _endDate!.isBefore(_startDate!)) {
                        return "End date must be after the start date.";
                      }
                      return null;
                    },
                  ),
                ),

              // === GPA (optional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "GPA (optional)",
                    hint: "0.00 – 4.00",
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _gpa = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final gpa = double.tryParse(value.trim());
                    if (gpa == null) {
                      return "GPA must be a number, e.g. 3.75.";
                    }
                    if (gpa < 0 || gpa > 4) {
                      return "GPA must be between 0.00 and 4.00.";
                    }
                    return null;
                  },
                ),
              ),

              // === Website (optional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Institution Website (optional)",
                    hint: "https://ui.ac.id",
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (String? value) {
                    setState(() {
                      _website = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final uri = Uri.tryParse(value.trim());
                    final valid =
                        uri != null &&
                        (uri.scheme == 'http' || uri.scheme == 'https') &&
                        uri.host.isNotEmpty;
                    if (!valid) {
                      return "Enter a valid URL starting with http:// or https://";
                    }
                    return null;
                  },
                ),
              ),

              // === Save Button ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(primary),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showSummary();
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows every entered value in a dialog after validation passes.
  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Education added successfully!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Institution: ${_institution.trim()}'),
                Text('Degree: $_degree'),
                Text('Field of Study: ${_fieldOfStudy.trim()}'),
                Text('Start Date: ${_formatDate(_startDate!)}'),
                Text(
                  'End Date: ${_isCurrent ? "Present" : _formatDate(_endDate!)}',
                ),
                Text('GPA: ${_gpa.trim().isEmpty ? "-" : _gpa.trim()}'),
                Text(
                  'Website: ${_website.trim().isEmpty ? "-" : _website.trim()}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }
}
