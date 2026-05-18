import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class TokenDisplay extends StatefulWidget {
  const TokenDisplay({super.key});
  @override
  State<TokenDisplay> createState() => _TokenDisplayState();
}

class _TokenDisplayState extends State<TokenDisplay> {
  Map<String, int> _balances = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await SupabaseService.getTokenBalances(SupabaseService.currentUser!.id);
    setState(() { _balances = b; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tokens')),
      body: ListView(
        children: [
          _tokenTile('🏛️ Sovereignty', _balances['sovereignty'] ?? 0),
          _tokenTile('💚 Care', _balances['care'] ?? 0),
          _tokenTile('🎨 Art', _balances['art'] ?? 0),
          _tokenTile('🤝 Community', _balances['community'] ?? 0),
        ],
      ),
    );
  }

  Widget _tokenTile(String label, int amount) {
    return ListTile(title: Text(label), trailing: Text('$amount'));
  }
}