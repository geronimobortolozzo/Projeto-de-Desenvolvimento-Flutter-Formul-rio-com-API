import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro com MockAPI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ========== TELA INICIAL ==========
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FormPage()),
                  ),
              child: const Text('Cadastrar Novo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListaDadosPage(),
                    ),
                  ),
              child: const Text('Ver Cadastros'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== TELA DE CADASTRO ==========
class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // URL DA API - SUBSTITUA PELA SUA URL DO MOCKAPI
  static const String apiUrl =
      'https://6807d288942707d722dc8a5b.mockapi.io/usuarios';

  Future<void> _enviarDados() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
          }),
        );

        debugPrint('Status: ${response.statusCode}');
        debugPrint('Resposta: ${response.body}');

        if (response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cadastro realizado!'),
              duration: Duration(seconds: 2),
            ),
          );
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
        } else {
          throw Exception('Erro ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  if (!value.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _enviarDados,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SALVAR CADASTRO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== TELA DE LISTAGEM ==========
class ListaDadosPage extends StatefulWidget {
  const ListaDadosPage({super.key});

  @override
  State<ListaDadosPage> createState() => _ListaDadosPageState();
}

class _ListaDadosPageState extends State<ListaDadosPage> {
  List<dynamic> _dados = [];
  bool _isLoading = true;
  bool _error = false;

  // Use a mesma URL da página de cadastro
  final String apiUrl = _FormPageState.apiUrl;

  Future<void> _carregarDados() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Resposta: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _dados = jsonDecode(response.body);
          _isLoading = false;
          _error = false;
        });
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao carregar: $e');
      setState(() {
        _isLoading = false;
        _error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastros Salvos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Falha ao carregar dados'),
                    ElevatedButton(
                      onPressed: _carregarDados,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
              : _dados.isEmpty
              ? const Center(child: Text('Nenhum cadastro encontrado'))
              : RefreshIndicator(
                onRefresh: _carregarDados,
                child: ListView.builder(
                  itemCount: _dados.length,
                  itemBuilder: (context, index) {
                    final item = _dados[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(item['name'] ?? 'Sem nome'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['email'] ?? 'Sem e-mail'),
                            Text(item['phone'] ?? 'Sem telefone'),
                          ],
                        ),
                        trailing: Text('ID: ${item['id']}'),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
