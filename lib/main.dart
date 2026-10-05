import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Compras',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
      ),
      home: const TelaLista(),
    );
  }
}

// Modelo Item
class Item {
  String nome;
  int quantidade;
  bool comprado;

  Item({
    required this.nome,
    required this.quantidade,
    this.comprado = false,
  });
}

// Tela principal
class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  // Lista de itens
  final List<Item> _itens = [];

  // Abre a tela de adicionar item
  Future<void> abrirTelaAdicionar() async {
    final Item? novoItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => const TelaAdicionarItem(),
      ),
    );

    if (novoItem != null) {
      setState(() {
        _itens.add(novoItem);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${novoItem.nome} adicionado à lista'),
          ),
        );
      }
    }
  }

  // Remove um item
  void removerItem(int indice) {
    final Item itemRemovido = _itens[indice];

    setState(() {
      _itens.removeAt(indice);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${itemRemovido.nome} removido da lista'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int itensComprados =
        _itens.where((item) => item.comprado).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '$itensComprados de ${_itens.length} comprados',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),

      // Lista de compras
      body: _itens.isEmpty
          ? const Center(
              child: Text(
                'Nenhum item na lista.\nAdicione seu primeiro item!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _itens.length,
              itemBuilder: (context, indice) {
                final Item item = _itens[indice];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.comprado,
                      onChanged: (valor) {
                        setState(() {
                          item.comprado = valor ?? false;
                        });
                      },
                    ),
                    title: Text(
                      item.nome,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        decoration: item.comprado
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      'Quantidade: ${item.quantidade}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Remover',
                      onPressed: () {
                        removerItem(indice);
                      },
                    ),
                  ),
                );
              },
            ),

      // Botão adicionar
      floatingActionButton: FloatingActionButton(
        onPressed: abrirTelaAdicionar,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tela de cadastro
class TelaAdicionarItem extends StatefulWidget {
  const TelaAdicionarItem({super.key});

  @override
  State<TelaAdicionarItem> createState() =>
      _TelaAdicionarItemState();
}

class _TelaAdicionarItemState extends State<TelaAdicionarItem> {
  // Controllers
  final TextEditingController _nomeController =
      TextEditingController();

  final TextEditingController _quantidadeController =
      TextEditingController();

  // Salva o item
  void salvar() {
    final String nome = _nomeController.text.trim();
    final int quantidade =
        int.tryParse(_quantidadeController.text.trim()) ?? 1;

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome do item'),
        ),
      );

      return;
    }

    final Item novoItem = Item(
      nome: nome,
      quantidade: quantidade,
    );

    Navigator.pop(context, novoItem);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nome
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome do item',
                hintText: 'Ex: Arroz',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_cart),
              ),
            ),

            const SizedBox(height: 16),

            // Quantidade
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                hintText: 'Ex: 2',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),

            const SizedBox(height: 24),

            // Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvar,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}