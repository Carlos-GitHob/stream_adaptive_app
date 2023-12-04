import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> listar() async {
  List tareas = [];
  CollectionReference collectionReferencePersonas = db.collection('tareas');
  QuerySnapshot queryPersonas = await collectionReferencePersonas.get();
  queryPersonas.docs.forEach((documento) {
    tareas.add(documento.data());
  });
  return tareas;
}

Future<void> guardarTarea(String title, String descripcion) async {
  Map<String, dynamic> data = {
    "title": title,
    "descripcion": descripcion,
  };
  String json = jsonEncode(data);
  await db.collection('tareas').add(jsonDecode(json));
}