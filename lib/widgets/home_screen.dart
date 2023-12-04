import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stream_adaptive_app/services/firebase_services.dart';
import 'package:stream_adaptive_app/widgets/contact.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  List<Assignments> assignments = List.empty(growable: true);
  final StreamController<Assignments> _assignmentsController =
      StreamController<Assignments>();

  int selectedIndex = -1;
  @override
  void initState() {
    super.initState();

    _assignmentsController.stream.listen((assignment) {
      if (assignment != null) {
        assignments.add(assignment);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _assignmentsController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de tareas"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
                hintText: 'Nombre de la tarea',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ))),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
                hintText: 'Estado de la tarea (Completado o no completado)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ))),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: ()  async{
                    String title = titleController.text.trim();
                    String descripcion = descController.text.trim();
                    if (title.isNotEmpty && descripcion.isNotEmpty) {
                      setState(() {
                        titleController.text = '';
                        descController.text = '';
                        assignments.add(Assignments(
                          title: title,
                          descripcion: descripcion,
                        ));
                      });
                      await guardarTarea(titleController.text, descController.text).then((value) {
                      Navigator.pop(context);
                    });
                    }
                  },
                  child: const Text('Guardar')),
              ElevatedButton(
                  onPressed: () async {
                    String title = titleController.text.trim();
                    String descripcion = descController.text.trim();
                    if (title.isNotEmpty && descripcion.isNotEmpty) {
                      setState(() {
                        titleController.text = '';
                        descController.text = '';
                        assignments[selectedIndex].title = title;
                        assignments[selectedIndex].descripcion = descripcion;
                        selectedIndex = -1;
                      });
                    }
                    await guardarTarea(titleController.text, descController.text).then((value) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text('Actualizar')),
            ],
          ),
          const SizedBox(height: 10),
          assignments.isEmpty
              ? const Text(
                  'No hay tareas guardadas',
                  style: TextStyle(fontSize: 22),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (context, index) =>
                        getRow(assignments[index], index),
                  ),
                )
        ]),
      ),
    );
  }

  Widget getRow(Assignments assignment, int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: assignment.title.length % 2 == 0
              ? Colors.deepPurple
              : Colors.lightBlue,
          foregroundColor: Colors.white,
          child: Text(
            assignment.title[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assignment.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(assignment.descripcion)
          ],
        ),
        trailing: SizedBox(
          width: 70,
          child: Row(children: [
            InkWell(
              onTap: () {
                titleController.text = assignments[index].title;
                descController.text = assignments[index].descripcion;
                setState(() {
                  selectedIndex = index;
                });
              },
              child: const Icon(Icons.edit),
            ),
            InkWell(
              onTap: () {
                assignments.removeAt(index);
                _assignmentsController.sink.add(Assignments(
                    title: assignment.title,
                    descripcion: assignment.descripcion));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tarea eliminada'),
                  ),
                );
                setState(() {});
              },
              child: const Icon(Icons.delete),
            ),
          ]),
        ),
      ),
    );
  }
}
