import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/not_to_do_provider.dart';
import 'add_not_to_do_screen.dart';
import '../../services/database_service.dart';
import '../../models/milestone.dart';

class NotToDoScreen extends StatefulWidget {
  @override
  _NotToDoScreenState createState() => _NotToDoScreenState();
}

class _NotToDoScreenState extends State<NotToDoScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<NotToDoProvider>(context, listen: false).loadNotToDoItems();
  }

  @override
  Widget build(BuildContext context) {
    final notToDoProvider = Provider.of<NotToDoProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Not to Do')),
      body: notToDoProvider.notToDoItems.isEmpty
          ? Center(child: Text('No habits to avoid'))
          : ListView.builder(
              itemCount: notToDoProvider.notToDoItems.length,
              itemBuilder: (context, index) {
                final item = notToDoProvider.notToDoItems[index];
                return FutureBuilder<List<Milestone>>(
                  future: DatabaseService().getMilestonesByNotToDoId(item.id!),
                  builder: (context, snapshot) {
                    final milestones = snapshot.data ?? [];
                    final progress = item.goalDays != null ? item.currentStreak / item.goalDays! : 0.0;
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Streak: ${item.currentStreak} days'),
                            if (item.goalDays != null)
                              LinearProgressIndicator(value: progress > 1.0 ? 1.0 : progress),
                            if (milestones.isNotEmpty)
                              Text('Milestones: ${milestones.where((m) => m.achievedAt != null).map((m) => m.milestoneDays).join(', ')} days'),
                          ],
                        ),
                        leading: Checkbox(
                          value: item.lastCheckedDate != null &&
                              DateTime(item.lastCheckedDate!.year, item.lastCheckedDate!.month, item.lastCheckedDate!.day)
                                  .isAtSameMomentAs(DateTime.now()),
                          onChanged: (value) async {
                            if (value == true) {
                              await notToDoProvider.checkNotToDo(item.id!);
                            }
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await notToDoProvider.deleteNotToDo(item.id!);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddNotToDoScreen())),
        child: Icon(Icons.add),
      ),
    );
  }
}