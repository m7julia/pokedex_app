import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pokemon.dart';

class PokemonScreen extends StatefulWidget {
  final Pokemon pokemon;
  final String docId; 
  
  const PokemonScreen({super.key, required this.pokemon, required this.docId});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  int hp = 100;
  int xp = 0;
  late int level;

  @override
  void initState() {
    super.initState();
    level = widget.pokemon.level;
  }

  Color get hpColor {
    if (hp > 60) return Colors.green;
    if (hp > 30) return Colors.orange;
    return Colors.red;
  }

  String get statusMessage {
    if (hp == 0) return '${widget.pokemon.name} desmaiou!';
    if (hp <= 30) return 'HP crítico!';
    return '';
  }

  void _atacar() {
    setState(() {
      hp = (hp - 20).clamp(0, 100);
      xp = xp + 10;
      if (xp >= 100) {
        level++;
        xp = xp - 100;
      }
    });
  }

  void _usarPocao() {
    setState(() {
      hp = (hp + 30).clamp(0, 100);
    });
  }

  Future<void> _encerrarBatalha() async {
    try {
      await FirebaseFirestore.instance
          .collection('Pokemons') 
          .doc(widget.docId)
          .update({'level': level});
      Navigator.pop(context, level);
    } catch (e) {
      Navigator.pop(context, level);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 177, 209),
      appBar: AppBar(
        title: Text(widget.pokemon.name),
        backgroundColor: const Color.fromARGB(255, 138, 7, 61),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PokemonCard(
              name: widget.pokemon.name,
              tipos: widget.pokemon.tipoNomes,
              level: level,
              imageUrl: widget.pokemon.spriteUrl,
            ),
            const SizedBox(height: 16),
            BattlePanel(
              hp: hp,
              xp: xp,
              level: level,
              hpColor: hpColor,
              statusMessage: statusMessage,
              onAtacar: _atacar,
              onUsarPocao: _usarPocao,
              onEncerrarBatalha: _encerrarBatalha, 
            ),
            const SizedBox(height: 16),
            MoveList(moves: widget.pokemon.moves),
          ],
        ),
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final String name;
  final List<String> tipos;
  final int level;
  final String imageUrl;

  const PokemonCard({
    super.key,
    required this.name,
    required this.tipos,
    required this.level,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 177, 209),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.catching_pokemon,
                      color: Color.fromARGB(255, 138, 7, 61),
                      size: 50,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 138, 7, 61),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: tipos.map((tipo) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 245, 177, 209),
                          border: Border.all(
                            color: const Color.fromARGB(255, 138, 7, 61),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tipo,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 138, 7, 61),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 177, 209),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 138, 7, 61),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color.fromARGB(255, 138, 7, 61),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Nível $level',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 138, 7, 61),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BattlePanel extends StatelessWidget {
  final int hp;
  final int xp;
  final int level;
  final Color hpColor;
  final String statusMessage;
  final VoidCallback onAtacar;
  final VoidCallback onUsarPocao;
  final VoidCallback onEncerrarBatalha;

  const BattlePanel({
    super.key,
    required this.hp,
    required this.xp,
    required this.level,
    required this.hpColor,
    required this.statusMessage,
    required this.onAtacar,
    required this.onUsarPocao,
    required this.onEncerrarBatalha,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Nível $level',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 138, 7, 61),
              ),
            ),
            const SizedBox(height: 12),
            _StatBar(label: 'HP', value: hp, maxValue: 100, color: hpColor),
            _StatBar(label: 'XP', value: xp, maxValue: 100, color: const Color.fromARGB(255, 138, 7, 61)),
            if (statusMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                statusMessage,
                style: TextStyle(
                  color: hp == 0 ? Colors.black87 : Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: hp > 0 ? onAtacar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 138, 7, 61),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Atacar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hp < 100 ? onUsarPocao : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 177, 209),
                      foregroundColor: const Color.fromARGB(255, 138, 7, 61),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Usar Poção'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onEncerrarBatalha,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Encerrar Batalha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoveList extends StatelessWidget {
  final List<String> moves;

  const MoveList({super.key, required this.moves});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Golpes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 138, 7, 61),
              ),
            ),
            const SizedBox(height: 12),
            ...moves.map((move) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 245, 177, 209),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromARGB(255, 138, 7, 61),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flash_on,
                      color: Color.fromARGB(255, 138, 7, 61),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      move,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 138, 7, 61),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;

  const _StatBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $value / $maxValue',
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 10,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 245, 177, 209),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  widthFactor: percentage,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
