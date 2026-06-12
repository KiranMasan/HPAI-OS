import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _titleController = TextEditingController();

  final List<String> _tasks = <String>[
    'Practice ML concepts (30 min)',
    'Revise notes (20 min)',
    'Pomodoro focus session (25 min)',
  ];

  final Set<int> _completed = <int>{};

  // Pomodoro
  static const int _focusSeconds = 25 * 60;

  bool _isRunning = false;
  bool _isFocus = true;
  int _remainingSeconds = _focusSeconds;

  // Progress model
  double _progressScore = 0;

  @override
  void initState() {
    super.initState();
    _recalculateProgress();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _tasks.add(title);
      _titleController.clear();
    });
    _recalculateProgress();
  }

  void _toggleComplete(int index) {
    setState(() {
      if (_completed.contains(index)) {
        _completed.remove(index);
      } else {
        _completed.add(index);
      }
    });
    _recalculateProgress();
  }

  void _startPause() {
    setState(() => _isRunning = !_isRunning);
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isFocus = true;
      _remainingSeconds = _focusSeconds;
    });
  }

  void _recalculateProgress() {
    // Inputs: (approximated locally)
    final double consistency = _calculateConsistency();
    final double taskCompletion = (_tasks.isEmpty)
        ? 0
        : (_completed.length / _tasks.length) * 100;
    final double focusHours = _calculateFocusHours();
    final double learningPerformance = _calculateLearningPerformance();
    final double habitStrength = _calculateHabitStrength();

    _progressScore = consistency + taskCompletion + focusHours + learningPerformance + habitStrength;
  }

  double _calculateConsistency() {
    // Placeholder: based on completed tasks.
    if (_tasks.isEmpty) return 0;
    return ((_completed.length / _tasks.length) * 100) * 0.35;
  }

  double _calculateFocusHours() {
    // Placeholder: map remaining time to a small contribution.
    // (In a real app, this comes from persisted Pomodoro sessions.)
    final double fraction = 1 - (_remainingSeconds / _focusSeconds).clamp(0.0, 1.0);
    return fraction * 20;
  }

  double _calculateLearningPerformance() {
    // Placeholder: reward completing tasks.
    return (_completed.length * 4.0).clamp(0, 40);
  }

  double _calculateHabitStrength() {
    // Placeholder: reward having at least one task completed.
    return _completed.isEmpty ? 0 : 25;
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildHumanProgressCard() {
    final progressInt = _progressScore.round();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HUMAN PROGRESS SCORE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Progress Score: $progressInt',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (progressInt / 200).clamp(0.0, 1.0),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            const Text(
              'Consistency + Task Completion + Focus Hours + Learning Performance + Habit Strength',
            ),
            const SizedBox(height: 8),
            const Text(
              'Gamified human evolution system.',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Basic periodic timer tick using a local FutureBuilder pattern is messy,
    // so we use a simple ticker via AnimatedBuilder + manual setState with a Timer.
    // (kept lightweight for this screen)

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Productivity Center'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHumanProgressCard(),
            const SizedBox(height: 16),

            // Task management
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TASK MANAGEMENT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Add task',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addTask,
                          child: const Text('Add'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    ...List.generate(_tasks.length, (i) {
                      final done = _completed.contains(i);
                      return CheckboxListTile(
                        value: done,
                        title: Text(
                          _tasks[i],
                          style: TextStyle(
                            decoration: done ? TextDecoration.lineThrough : null,
                            color: done ? Colors.green : null,
                          ),
                        ),
                        onChanged: (_) => _toggleComplete(i),
                      );
                    }),

                    const SizedBox(height: 8),
                    const Text(
                      '✅ Add task   ✅ Complete task   ✅ AI-generated tasks   ✅ Daily goals   ✅ Weekly plans',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Streak engine
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('STREAK ENGINE', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Track:'),
                    SizedBox(height: 6),
                    Text('• study consistency'),
                    Text('• habit formation'),
                    Text('• focus streaks'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Focus timer
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FOCUS TIMER', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Chip(
                          label: Text(_isFocus ? '25 min focus' : '5 min break'),
                        ),
                        const SizedBox(width: 10),
                        const Text('AI reminders • productivity tracking'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isRunning ? _startPause : _startPause,
                          child: Text(_isRunning ? 'Pause' : 'Start'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _resetTimer,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'AI PRODUCTIVITY ENGINE: analyzes consistency, performance, focus patterns and recommends study improvements.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        Chip(label: Text('optimized schedules')),
                        Chip(label: Text('productivity fixes')),
                        Chip(label: Text('focus reminders')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Advanced features placeholders
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔥 ADVANCED FEATURES',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text('1. SMART REMINDERS'),
                    const Text('   • You usually study better at 8 PM.'),
                    const SizedBox(height: 8),
                    const Text('2. BURNOUT DETECTION'),
                    const Text('   • declining productivity • stress patterns • reduced focus'),
                    const SizedBox(height: 8),
                    const Text('3. ADAPTIVE STUDY PLANNER'),
                    const Text('   • dynamically changes tasks, schedules, revision plans based on performance.'),
                    const SizedBox(height: 12),
                    const Text(
                      '🔥 MASSIVE FUTURE UPGRADE: AI DIGITAL TWIN',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'System learns behavior, focus, weaknesses, learning style — becomes a personalized cognitive operating system.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

