import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/tribe.dart';

class TribeScreen extends StatefulWidget {
  const TribeScreen({super.key});
  @override
  State<TribeScreen> createState() => _TribeScreenState();
}

class _TribeScreenState extends State<TribeScreen> {
  final _nameCtrl = TextEditingController();
  List<Tribe> _tribes = [];

  @override
  void initState() {
    super.initState();
    _loadTribes();
  }

  Future<void> _loadTribes() async {
    final data = await SupabaseService.client.from('tribes').select();
    setState(() {
      _tribes = (data as List).map((e) => Tribe.fromMap(e)).toList();
    });
  }

  void _create() async {
    final tribe = await SupabaseService.createTribe(_nameCtrl.text, SupabaseService.currentUser!.id);
    _loadTribes();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tribe ${tribe.name} created!')));
  }

  void _join(String tribeId) async {
    await SupabaseService.joinTribe(SupabaseService.currentUser!.id, tribeId);
    _loadTribes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tribes')),
      body: Column(
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Tribe name')),
          ElevatedButton(onPressed: _create, child: const Text('Create Tribe')),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _tribes.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(_tribes[i].name),
                trailing: ElevatedButton(onPressed: () => _join(_tribes[i].id), child: const Text('Join')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}