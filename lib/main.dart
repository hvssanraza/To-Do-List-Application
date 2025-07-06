import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProToDoApp());
}

class ProToDoApp extends StatelessWidget {
  const ProToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
        textTheme: CupertinoTextThemeData(
          textStyle: const TextStyle(
            fontFamily: '.SF Pro',
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        barBackgroundColor: CupertinoColors.extraLightBackgroundGray,
        scaffoldBackgroundColor: CupertinoColors.extraLightBackgroundGray,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _isLoading = false;
    });
  }

  void _login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    setState(() => _isAuthenticated = true);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    setState(() => _isAuthenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator(radius: 16)),
      );
    }
    
    return _isAuthenticated
        ? HomeScreen(logout: _logout)
        : const AuthScreen();
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _navigateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => HomeScreen(logout: () {})),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        border: null,
        middle: Text('Pro To‑Do'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 80,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Pro To‑Do',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Organize your tasks with elegance',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
              const Spacer(flex: 2),
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: _currentPage == 0
                            ? CupertinoColors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        onPressed: () => _navigateToPage(0),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _currentPage == 0
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: _currentPage == 1
                            ? CupertinoColors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        onPressed: () => _navigateToPage(1),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _currentPage == 1
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                flex: 5,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildLoginForm(),
                    _buildSignupForm(),
                  ],
                ),
              ),
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _handleAuth,
                child: _isLoading
                    ? const CupertinoActivityIndicator()
                    : Text(_currentPage == 0 ? 'Sign In' : 'Create Account'),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: _isLoading ? null : _handleAuth,
                child: const Text('Continue as Guest'),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'Email Address',
          prefix: const Icon(CupertinoIcons.mail, size: 20),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            border: Border.all(color: CupertinoColors.lightBackgroundGray),
            borderRadius: BorderRadius.circular(10),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _passwordController,
          placeholder: 'Password',
          prefix: const Icon(CupertinoIcons.lock, size: 20),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            border: Border.all(color: CupertinoColors.lightBackgroundGray),
            borderRadius: BorderRadius.circular(10),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        CupertinoTextField(
          controller: _nameController,
          placeholder: 'Full Name',
          prefix: const Icon(CupertinoIcons.person, size: 20),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            border: Border.all(color: CupertinoColors.lightBackgroundGray),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'Email Address',
          prefix: const Icon(CupertinoIcons.mail, size: 20),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            border: Border.all(color: CupertinoColors.lightBackgroundGray),
            borderRadius: BorderRadius.circular(10),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _passwordController,
          placeholder: 'Password',
          prefix: const Icon(CupertinoIcons.lock, size: 20),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            border: Border.all(color: CupertinoColors.lightBackgroundGray),
            borderRadius: BorderRadius.circular(10),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          placeholder: 'Confirm Password',
          prefix: const Icon(CupertinoIcons.lock, size: 20),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            border: Border.all(color: CupertinoColors.lightBackgroundGray),
            borderRadius: BorderRadius.circular(10),
          ),
          obscureText: true,
        ),
      ],
    );
  }
}

class Task {
  final int id;
  String text, category;
  bool done;
  DateTime created;
  DateTime? completed;

  Task({
    required this.id,
    required this.text,
    required this.category,
    this.done = false,
    DateTime? created,
  }) : created = created ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'category': category,
        'done': done,
        'created': created.toIso8601String(),
        'completed': completed?.toIso8601String(),
      };

  static Task fromJson(Map<String, dynamic> j) => Task(
        id: j['id'],
        text: j['text'],
        category: j['category'],
        done: j['done'],
        created: DateTime.parse(j['created']),
      )..completed = j['completed'] != null ? DateTime.parse(j['completed']) : null;
}

class HomeScreen extends StatefulWidget {
  final VoidCallback logout;

  const HomeScreen({super.key, required this.logout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  final categories = ['Personal', 'Work', 'Shopping', 'Health'];
  int _selectedCategoryIndex = 0;
  bool _isLoading = false;
  bool _showCompleted = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('tasks_list') ?? [];
    setState(() {
      _tasks = list.map((s) => Task.fromJson(jsonDecode(s))).toList();
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('tasks_list', list);
  }

  void _addOrEdit({Task? existing}) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) {
      return AddTaskScreen(
        categories: categories,
        task: existing,
        onSave: (task) {
          setState(() {
            if (existing != null) {
              final i = _tasks.indexWhere((t) => t.id == existing.id);
              _tasks[i] = task;
            } else {
              _tasks.insert(0, task);
            }
          });
          _saveTasks();
        },
      );
    }));
  }

  void _toggle(int i) {
    setState(() {
      _tasks[i].done = !_tasks[i].done;
      if (_tasks[i].done) {
        _tasks[i].completed = DateTime.now();
      } else {
        _tasks[i].completed = null;
      }
    });
    _saveTasks();
  }

  void _delete(int i) {
    final t = _tasks.removeAt(i);
    _saveTasks();
    final undo = () {
      setState(() => _tasks.insert(i, t));
      _saveTasks();
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${t.text}"'),
        action: SnackBarAction(label: 'Undo', onPressed: undo),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _tasks.where((t) {
      final categoryMatch = t.category == categories[_selectedCategoryIndex];
      return categoryMatch && (_showCompleted || !t.done);
    }).toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('My Tasks'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.logout,
          child: const Icon(CupertinoIcons.arrow_right_circle),
        ),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                placeholder: 'Search tasks...',
                onChanged: (value) {},
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: _selectedCategoryIndex == index
                          ? CupertinoColors.activeBlue.withOpacity(0.2)
                          : CupertinoColors.tertiarySystemFill,
                      borderRadius: BorderRadius.circular(20),
                      onPressed: () {
                        setState(() => _selectedCategoryIndex = index);
                      },
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: _selectedCategoryIndex == index
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.secondaryLabel,
                          fontWeight: _selectedCategoryIndex == index
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'SHOW COMPLETED',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                  const Spacer(),
                  CupertinoSwitch(
                    value: _showCompleted,
                    onChanged: (value) => setState(() => _showCompleted = value),
                    activeColor: CupertinoColors.activeBlue,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator(radius: 16))
                  : filteredTasks.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.check_mark_circled,
                              size: 80,
                              color: CupertinoColors.tertiaryLabel,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks yet',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.label.resolveFrom(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first task to get started',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context),
                              ),
                            ),
                          ],
                        )
                      : CupertinoScrollbar(
                          child: ListView.builder(
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return Dismissible(
                                key: Key(task.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: CupertinoColors.destructiveRed,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    CupertinoIcons.delete,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                                onDismissed: (_) => _delete(index),
                                child: CupertinoListTile(
                                  leading: CupertinoCheckbox(
                                    value: task.done,
                                    onChanged: (_) => _toggle(index),
                                    activeColor: CupertinoColors.activeBlue,
                                  ),
                                  title: Text(
                                    task.text,
                                    style: TextStyle(
                                      fontSize: 17,
                                      decoration: task.done
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: task.done
                                          ? CupertinoColors.secondaryLabel
                                          : CupertinoColors.label,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.category,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: CupertinoColors.secondaryLabel,
                                        ),
                                      ),
                                      if (task.completed != null)
                                        Text(
                                          'Completed ${_formatDate(task.completed!)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: CupertinoColors.systemGreen,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 18,
                                    color: CupertinoColors.tertiaryLabel,
                                  ),
                                  onTap: () => _addOrEdit(existing: task),
                                ),
                              );
                            },
                          ),
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => _addOrEdit(),
                  child: const Text('Add New Task'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  final List<String> categories;
  final Task? task;
  final void Function(Task) onSave;

  const AddTaskScreen({
    super.key,
    required this.categories,
    this.task,
    required this.onSave,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final TextEditingController _textController =
      TextEditingController(text: widget.task?.text);
  late int _categoryIndex = widget.task != null
      ? widget.categories.indexOf(widget.task!.category)
      : 0;

  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch,
      text: text,
      category: widget.categories[_categoryIndex],
      done: widget.task?.done ?? false,
    );
    widget.onSave(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoTextField(
              controller: _textController,
              placeholder: 'Task name',
              padding: const EdgeInsets.all(16),
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                border: Border.all(color: CupertinoColors.lightBackgroundGray),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _categoryIndex,
              padding: const EdgeInsets.all(4),
              children: {
                for (int i = 0; i < widget.categories.length; i++)
                  i: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      widget.categories[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _categoryIndex == i
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.secondaryLabel,
                      ),
                    ),
                  )
              },
              onValueChanged: (i) => setState(() => _categoryIndex = i!),
            ),
            if (widget.task != null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'CREATED',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${widget.task!.created.day}/${widget.task!.created.month}/${widget.task!.created.year}',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}