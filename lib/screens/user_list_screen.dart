import 'package:flutter/material.dart';
import '../models/user.dart';
import '../database/db_helper.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DbHelper _db = DbHelper();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await _db.getUsers();
    setState(() {
      _users = data;
      _filteredUsers = data;
    });
  }

  Future<void> _deleteUser(User user) async {
    await _db.deleteUser(user.id!);
    _loadUsers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} excluido com sucesso!')),
      );
    }
  }

  void _filter() {
    final term = _searchCtrl.text.toLowerCase();

    setState(() {
      _filteredUsers = _users.where((u) {
        return u.name.toLowerCase().contains(term) ||
            u.email.toLowerCase().contains(term);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Usuarios'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Gestão de Usuarios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _filter(),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou e-mail...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum usuario encontrado.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (ctx, i) {
                      final user = _filteredUsers[i];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent.withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              color: Colors.blueAccent,
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(user.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _iconButton(
                                Icons.edit,
                                Colors.orange,
                                () => _openForm(user),
                              ),
                              const SizedBox(width: 8),
                              _iconButton(
                                Icons.delete,
                                Colors.redAccent,
                                () => _showDeleteDialog(user),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(null),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Novo Usuario'),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(icon: Icon(icon, color: color), onPressed: onPressed);
  }

  void _openForm(User? user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(user: user),
      ),
    );
    _loadUsers();
  }

  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
