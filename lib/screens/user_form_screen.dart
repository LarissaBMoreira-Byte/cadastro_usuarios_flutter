import 'package:flutter/material.dart';
import '../models/user.dart';
import '../database/db_helper.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _db = DbHelper();

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: widget.user?.id,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );

      if (isEdit)
        await _db.updateUser(user);
      else
        await _db.insertUser(user);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'Usuário atualizado!' : 'Usuário cadastrado!',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final bool? confirm = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Deseja sair?'),
            content: const Text('As alterações não salvas serão perdidas.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sair'),
              ),
            ],
          ),
        );
        if (confirm == true) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Editar Usuário' : 'Cadastrar Usuário'),
          backgroundColor: isEdit ? Colors.orange : Colors.blueAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(_nameCtrl, 'Nome', Icons.badge),
                const SizedBox(height: 16),
                _buildField(
                  _emailCtrl,
                  'E-mail',
                  Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildField(
                  _phoneCtrl,
                  'Telefone',
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_alt),
                  label: Text(
                    isEdit ? 'Atualizar' : 'Incluir',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdit ? Colors.orange : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}
