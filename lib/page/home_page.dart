import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../data/moor_database.dart';
import '../widget/new_task_input_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Tasks'),
          actions: <Widget>[
            _buildCompletedOnlySwitch(),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: _buildTaskList(context)),
            NewTaskInput(),
          ],
        ));
  }

  Row _buildCompletedOnlySwitch() {
    return Row(
      children: <Widget>[
        Text('Completed only'),
        Switch(
          value: showCompleted,
          activeColor: Colors.white,
          onChanged: (newValue) {
            setState(() {
              showCompleted = newValue;
            });
          },
        ),
      ],
    );
  }

  StreamBuilder<List<Task>> _buildTaskList(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);
    return StreamBuilder(
      //provide the stream of database
      stream: dao.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        final tasks = snapshot.data ?? List();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final itemTask = tasks[index];
            //fetch the one task
            //use this one task and display using component
            //we also need to provide database because we want to delete the data
            return _buildListItem(itemTask, dao);
          },
        );
      },
    );
  }

  Widget _buildListItem(Task itemTask, TaskDao dao) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      //logic to delete the data
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => dao.deleteTask(itemTask),
        )
      ],
      child: CheckboxListTile(
        title: Text(itemTask.name),
        subtitle: Text(itemTask.dueDate?.toString() ?? 'No date'),
        value: itemTask.completed,
        //when user press the checkbox then update the value
        onChanged: (newValue) {
          //get the old task and copy with new updated Value of completed
          //means change only completed value
          dao.updateTask(itemTask.copyWith(completed: newValue));
        },
      ),
    );
  }
}
