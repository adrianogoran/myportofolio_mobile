import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  String? _validateRequired(String? value, String label, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label cannot be empty!';
    if (maxLength != null && text.length > maxLength) {
      return '$label must be at most $maxLength characters.';
    }
    return null;
  }

  String? _validateUrl(String? value, {required bool isRequired}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? 'Project URL cannot be empty!' : null;
    if (text.length > 200) return 'URL must be at most 200 characters.';
    final uri = Uri.tryParse(text);
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valid ? null : 'Enter a valid URL starting with http:// or https://';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureLoggedIn(context) || !mounted) return;

    final auth = context.read<AuthState>();
    final token = auth.token;
    if (token == null) return;

    final newProject = Project(
      title: _title.trim(),
      description: _description.trim(),
      techStack: _techStack.trim(),
      projectUrl: _projectUrl.trim(),
      projectImageUrl: _projectImageUrl.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });

    Project? created;
    var sessionExpired = false;
    try {
      created = await context.read<ApiClient>().createProject(
        newProject,
        token: token,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        // The token is invalid or revoked: end the session and log in again.
        await auth.logout();
        sessionExpired = true;
      } else {
        _showMessage('Failed to add project: ${friendlyError(error)}');
      }
    } on http.ClientException catch (error) {
      _showMessage('Failed to add project: ${friendlyError(error)}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    if (!mounted) return;
    if (created != null) {
      await _showSuccess(created);
    } else if (sessionExpired) {
      _showMessage('Your session has expired. Please log in again.');
      await ensureLoggedIn(context);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showSuccess(Project project) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Project added successfully!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${project.title}'),
                Text('Description: ${project.description}'),
                Text('Tech Stack: ${project.techStack}'),
                Text('Project URL: ${project.projectUrl}'),
                if (project.projectImageUrl.isNotEmpty)
                  Text('Project Image URL: ${project.projectImageUrl}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    _formKey.currentState!.reset();
    setState(() {
      _title = '';
      _description = '';
      _techStack = '';
      _projectUrl = '';
      _projectImageUrl = '';
    });
  }

  Widget _field({
    required String label,
    required ValueChanged<String> onChanged,
    required FormFieldValidator<String> validator,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint ?? label,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                label: 'Title',
                onChanged: (value) => _title = value,
                validator: (value) =>
                    _validateRequired(value, 'Title', maxLength: 255),
              ),
              _field(
                label: 'Description',
                maxLines: 5,
                onChanged: (value) => _description = value,
                validator: (value) => _validateRequired(value, 'Description'),
              ),
              _field(
                label: 'Tech Stack',
                hint: 'Example: Flutter, Django, Figma',
                onChanged: (value) => _techStack = value,
                validator: (value) =>
                    _validateRequired(value, 'Tech Stack', maxLength: 255),
              ),
              _field(
                label: 'Project URL',
                hint: 'https://example.com',
                keyboardType: TextInputType.url,
                onChanged: (value) => _projectUrl = value,
                validator: (value) => _validateUrl(value, isRequired: true),
              ),
              _field(
                label: 'Project Image URL (Optional)',
                hint: 'https://example.com/image.png',
                keyboardType: TextInputType.url,
                onChanged: (value) => _projectImageUrl = value,
                validator: (value) => _validateUrl(value, isRequired: false),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
