import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'catalog.dart';
import 'forms.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.state});
  final AppState state;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  String error = '';

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.public, size: 72, color: Color(0xff053aa7)),
                      const Text(
                        'National Revival Desk',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Revival coordination, planning, reporting and media.'),
                      const SizedBox(height: 24),
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Official email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      if (error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(error, style: const TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: widget.state.busy
                            ? null
                            : () async {
                                try {
                                  await widget.state.login(email.text.trim(), password.text);
                                  if (mounted) setState(() => error = '');
                                } catch (exception) {
                                  if (mounted) setState(() => error = exception.toString());
                                }
                              },
                        icon: const Icon(Icons.login),
                        label: Text(widget.state.busy ? 'Signing in…' : 'Sign in'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrationPage(state: widget.state),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt),
                        label: const Text('Register as Coordinator'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.state});
  final AppState state;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final player = AudioPlayer();
  bool playing = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _toggleRadio() async {
    if (playing) {
      await player.stop();
    } else {
      await player.play(UrlSource('https://s3.radio.co/s97f38db97/listen'));
    }
    if (mounted) setState(() => playing = !playing);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      Dashboard(state: widget.state),
      ReportForm(state: widget.state),
      PlanForm(state: widget.state),
      QueuePage(state: widget.state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('National Revival Desk'),
        actions: [
          Icon(widget.state.online ? Icons.cloud_done : Icons.cloud_off),
          IconButton(
            tooltip: 'Sync now',
            onPressed: widget.state.sync,
            icon: const Icon(Icons.sync),
          ),
          PopupMenuButton<String>(
            itemBuilder: (_) => const [
              PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
            onSelected: (_) => widget.state.logout(),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.description_outlined), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.sync_problem), label: 'Queue'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleRadio,
        icon: Icon(playing ? Icons.stop : Icons.radio),
        label: Text(playing ? 'Stop Radio' : 'Live Radio'),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Welcome', style: Theme.of(context).textTheme.headlineMedium),
        const Text('National → Province → County → Region → Coordinator → Altar → Report'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _stat('Categories', '${state.categories.length}', Icons.category),
            _stat('Pending offline', '${state.queue.length}', Icons.cloud_upload),
            _stat('Connectivity', state.online ? 'Online' : 'Offline', state.online ? Icons.wifi : Icons.wifi_off),
            _stat(
              'Last sync',
              state.lastSync?.toLocal().toString().substring(0, 16) ?? 'Not yet',
              Icons.schedule,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Card(
          child: ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Secure multi-platform application'),
            subtitle: Text(
              'Categories are cached for offline selection. Queued plans and reports use idempotency keys to prevent duplicates.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xff053aa7)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportForm extends StatefulWidget {
  const ReportForm({super.key, required this.state});
  final AppState state;

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  int step = 0;
  final title = TextEditingController();
  final venue = TextEditingController();
  final summary = TextEditingController();
  RevivalCategory? category;
  DateTime date = DateTime.now();
  int attendance = 0;
  int souls = 0;
  bool declaration = false;

  @override
  void dispose() {
    title.dispose();
    venue.dispose();
    summary.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (step < 4) {
      setState(() => step++);
      return;
    }
    if (category == null || title.text.trim().isEmpty || !declaration) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete the title, category and declaration.')),
      );
      return;
    }
    await widget.state.enqueue('report', {
      'title': title.text.trim(),
      'activity_category_id': category!.id,
      'activity_category_slug': category!.slug,
      'event_date': date.toIso8601String().split('T').first,
      'venue': venue.text.trim(),
      'attendance_total': attendance,
      'souls_saved': souls,
      'summary': summary.text.trim(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report queued and will synchronize safely.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      _details(),
      _participation(),
      _impact(),
      _narrative(),
      _review(),
    ];
    const titles = ['Activity', 'Participation', 'Impact', 'Narrative', 'Review'];

    return Stepper(
      currentStep: step,
      onStepContinue: _continue,
      onStepCancel: step == 0 ? null : () => setState(() => step--),
      steps: List.generate(
        content.length,
        (index) => Step(
          title: Text(titles[index]),
          isActive: index <= step,
          state: index < step ? StepState.complete : StepState.indexed,
          content: content[index],
        ),
      ),
    );
  }

  Widget _details() {
    return Column(
      children: [
        TextField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Report title *'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<RevivalCategory>(
          initialValue: category,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Activity category *'),
          items: widget.state.categories
              .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
              .toList(),
          onChanged: (value) => setState(() => category = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: venue,
          decoration: const InputDecoration(labelText: 'Venue'),
        ),
      ],
    );
  }

  Widget _participation() {
    return TextFormField(
      initialValue: '0',
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Total attendance'),
      onChanged: (value) => attendance = int.tryParse(value) ?? 0,
    );
  }

  Widget _impact() {
    return TextFormField(
      initialValue: '0',
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Souls saved'),
      onChanged: (value) => souls = int.tryParse(value) ?? 0,
    );
  }

  Widget _narrative() {
    return TextField(
      controller: summary,
      maxLines: 5,
      maxLength: 2000,
      decoration: const InputDecoration(labelText: 'Executive summary'),
    );
  }

  Widget _review() {
    return CheckboxListTile(
      value: declaration,
      onChanged: (value) => setState(() => declaration = value ?? false),
      title: const Text(
        'I confirm that this report is accurate and represents the activities conducted within the stated jurisdiction.',
      ),
    );
  }
}
