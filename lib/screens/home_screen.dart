import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_list_item.dart';
import '../widgets/category_filter.dart';
import '../widgets/stats_card.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Tasks'),
            Tab(text: 'Today'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Card
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: StatsCard(),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    return IconButton(
                      icon: Icon(
                        provider.showCompleted
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: provider.toggleShowCompleted,
                    );
                  },
                ),
              ),
              onChanged: (value) {
                context.read<TaskProvider>().setSearchQuery(value);
              },
            ),
          ),

          // Category Filter
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CategoryFilter(),
          ),

          // Task List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList((provider) => provider.tasks),
                _buildTaskList((provider) => provider.todayTasks),
                _buildTaskList((provider) => provider.completedTasks),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> Function(TaskProvider) taskSelector) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasks = taskSelector(provider);

        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tasks found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskListItem(task: tasks[index]);
          },
        );
      },
    );
  }
}