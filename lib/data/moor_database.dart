import 'package:moor/moor.dart';
import 'package:moor_flutter/moor_flutter.dart';

// Moor works by source gen. This file will all the generated code.
part 'moor_database.g.dart';

class Tasks extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get tagName=>text().nullable().customConstraint('NULL REFERENCES tags(name)')();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(Constant(false))();
}

class Tags extends Table{
  TextColumn get name=>text().withLength(min:1,max:10)();
  IntColumn get color=>integer()();

  //set manual primary key
  @override
  Set<Column> get primaryKey =>{name};
}

@UseMoor(tables: [Tasks,Tags], daos: [TaskDao,TagDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super((FlutterQueryExecutor.inDatabaseFolder(
          path: 'db.sqlite',
          logStatements: true,
        )));

  @override
  int get schemaVersion => 2;


  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Runs if the database has already been opened on the device with a lower version
    onUpgrade: (migrator, from, to) async {
      if (from == 1) {
        await migrator.addColumn(tasks, tasks.tagName);
        await migrator.createTable(tags);
      }
    },
  );



  /*


  // All tables have getters in the generated class - we can select the tasks table
  Future<List<Task>> getAllTasks() => select(tasks).get();

  // Moor supports Streams which emit elements when the watched data changes
  Stream<List<Task>> watchAllTasks() => select(tasks).watch();

  Future insertTask(Task task) => into(tasks).insert(task);

  // Updates a Task with a matching primary key
  Future updateTask(Task task) => update(tasks).replace(task);

  Future deleteTask(Task task) => delete(tasks).delete(task);
  */
  
}


@UseDao(
  tables: [Tasks],
  queries: {
    'completedTasksGenerated':'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;'
  }
)
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  final AppDatabase db;

  // Called by the AppDatabase class
  TaskDao(this.db) : super(db);

  Future<List<Task>> getAllTasks() => select(tasks).get();
  Stream<List<Task>> watchAllTasks(){
    return (select(tasks)..orderBy([
      (t)=>OrderingTerm(
        expression: t.dueDate,
        mode: OrderingMode.desc
      ),
       (t)=>OrderingTerm(
        expression: t.name,
        mode: OrderingMode.asc
      ),
    ]))
    .watch();
    
  }


  Stream<List<Task>> watchCompletedTasks(){
    return (select(tasks)..orderBy([
      (t)=>OrderingTerm(
        expression: t.dueDate,
        mode: OrderingMode.desc
      ),
       (t)=>OrderingTerm(
        expression: t.name,
        mode: OrderingMode.asc
      ),
    ])
    ..where((tbl) => tbl.completed.equals(true))
    )
    .watch();
  }

  
  Stream<List<Task>> watchCompletedTasksCustom() {
    return customSelectStream(
      'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;',
      // The Stream will emit new values when the data inside the Tasks table changes
      readsFrom: {tasks},
    )
        // customSelect or customSelectStream gives us QueryRow list
        // This runs each time the Stream emits a new value.
        .map((rows) {
      // Turning the data of a row into a Task object
      return rows.map((row) => Task.fromData(row.data, db)).toList();
    });
  }

  Future insertTask(Insertable<Task> task) => into(tasks).insert(task);
  Future updateTask(Insertable<Task> task) => update(tasks).replace(task);
  Future deleteTask(Insertable<Task> task) => delete(tasks).delete(task);
}


@UseDao(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  final AppDatabase db;

  TagDao(this.db) : super(db);

  Stream<List<Tag>> watchTags() => select(tags).watch();
  Future insertTag(Insertable<Tag> tag) => into(tags).insert(tag);
}