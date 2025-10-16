import 'package:supabase_flutter/supabase_flutter.dart';

class TaskSubjectService {
  Future addSubject(String name, String color) async {
    try {
      return await Supabase.instance.client.from('subject').insert({
        'name': name,
        'color': color,
      });
    } catch (e) {
      throw Exception('Failed to add subject: $e');
    }
  }

  PostgrestTransformBuilder<PostgrestList> fetchSubjects() {
    return Supabase.instance.client
        .from('subject')
        .select()
        .order('name', ascending: true);
  }

  PostgrestFilterBuilder deleteSubject(int id) {
    return Supabase.instance.client.from('subject').delete().eq('id', id);
  }

  Future addTask({
    required String title,
    required int subject,
    required String dueDate,
  }) async {
    try {
      return await Supabase.instance.client.from('tasks').insert({
        'title': title,
        'subject': subject,
        'dueDate': dueDate,
        'status': 'In Progress',
        'created_at': DateTime.now().toIso8601String().split('T')[0],
      });
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  PostgrestTransformBuilder<PostgrestList> fetchTasks() {
    return Supabase.instance.client
        .from('tasks')
        .select()
        .order('created_at', ascending: false);
  }

  PostgrestFilterBuilder deleteTask(int id) {
    return Supabase.instance.client.from('tasks').delete().eq('id', id);
  }

  PostgrestFilterBuilder updateTaskStatus(int id, String status) {
    return Supabase.instance.client
        .from('tasks')
        .update({'status': status}).eq('id', id);
  }

  Future updateTask({
    required int id,
    required String title,
    required int subject,
    required String dueDate,
  }) async {
    try {
      return await Supabase.instance.client.from('tasks').update({
        'title': title,
        'subject': subject,
        'dueDate': dueDate,
      }).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
