import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference pokemonsCollection = FirebaseFirestore.instance
      .collection('Pokemons');

  Map<String, int> getPokemonIdMap() {
    return {
      'Bulbasaur': 1,
      'Ivysaur': 2,
      'Venusaur': 3,
      'Charmander': 4,
      'Charmeleon': 5,
      'Charizard': 6,
      'Squirtle': 7,
      'Wartortle': 8,
      'Blastoise': 9,
      'Pikachu': 25,
      'Eevee': 133,
      'Vaporeon': 134,
      'Jolteon': 135,
      'Flareon': 136,
      'Gengar': 94,
      'Sylveon': 700,
    };
  }

  Map<String, int> getTypeIdMap() {
    return {
      'Normal': 1,
      'Fighting': 2,
      'Flying': 3,
      'Poison': 4,
      'Ground': 5,
      'Rock': 6,
      'Bug': 7,
      'Ghost': 8,
      'Steel': 9,
      'Fire': 10,
      'Water': 11,
      'Grass': 12,
      'Electric': 13,
      'Psychic': 14,
      'Ice': 15,
      'Dragon': 16,
      'Dark': 17,
      'Fairy': 18,
      'Voador': 3,
      'Fogo': 10,
      'Água': 11,
      'Planta': 12,
      'Elétrico': 13,
      'Psíquico': 14,
      'Gelo': 15,
      'Dragão': 16,
      'Sombrio': 17,
      'Fada': 18,
      'Fantasma': 8,
      'Venenoso': 4,
      'Inseto': 7,
      'Pedra': 6,
      'Terra': 5,
      'Aço': 9,
      'Lutador': 2,
    };
  }

  List<int> convertTypesToIds(List<String> typeNames) {
    final typeMap = getTypeIdMap();
    final List<int> typeIds = [];

    for (String typeName in typeNames) {
      String normalizedName = typeName.trim();
      normalizedName = normalizedName.replaceAll(RegExp(r'\s+'), ' ');

      if (typeMap.containsKey(normalizedName)) {
        typeIds.add(typeMap[normalizedName]!);
      } else {
        typeIds.add(1);
      }
    }

    return typeIds;
  }

  int getCorrectPokemonId(String name, int originalSpriteId) {
    final pokemonMap = getPokemonIdMap();
    final normalizedName = name.trim();

    if (pokemonMap.containsKey(normalizedName)) {
      return pokemonMap[normalizedName]!;
    }

    return originalSpriteId;
  }

  int extractLevel(Map<String, dynamic> data) {
    List<String> possibleKeys = [
      'level',
      'level ',
      ' level',
      ' level ',
      'Level',
      'LEVEL',
    ];

    for (String key in possibleKeys) {
      if (data.containsKey(key)) {
        final levelValue = data[key];
        
        if (levelValue != null) {
          if (levelValue is int) {
            return levelValue;
          } else if (levelValue is double) {
            return levelValue.toInt();
          } else if (levelValue is String) {
            final parsed = int.tryParse(levelValue);
            if (parsed != null) return parsed;
          } else if (levelValue is num) {
            return levelValue.toInt();
          }
        }
      }
    }

    for (String key in data.keys) {
      if (key.toLowerCase().contains('level')) {
        final levelValue = data[key];
        if (levelValue is int) return levelValue;
        if (levelValue is double) return levelValue.toInt();
        if (levelValue is String) {
          final parsed = int.tryParse(levelValue);
          if (parsed != null) return parsed;
        }
      }
    }

    return 1;
  }

  Future<void> _deletePokemon(String docId, String pokemonName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Pokémon'),
        content: Text('Tem certeza que deseja remover $pokemonName da sua Pokédex?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await pokemonsCollection.doc(docId).delete();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$pokemonName foi removido da Pokédex'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao remover $pokemonName: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 138, 7, 61),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: pokemonsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar Pokémons: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 138, 7, 61),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum Pokémon encontrado',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final docId = doc.id;
                      final data = doc.data() as Map<String, dynamic>;

                      String name = 'Desconhecido';
                      List<String> possibleNameKeys = [
                        'name',
                        'name ',
                        ' name',
                        ' Name',
                        'NAME',
                      ];
                      for (String key in possibleNameKeys) {
                        if (data.containsKey(key)) {
                          name = data[key]?.toString().trim() ?? 'Desconhecido';
                          break;
                        }
                      }

                      int originalSpriteId = 0;
                      List<String> possibleSpriteKeys = [
                        'spriteId',
                        'spriteId ',
                        ' spriteId',
                        'spriteid',
                        'SpriteId',
                      ];
                      for (String key in possibleSpriteKeys) {
                        if (data.containsKey(key)) {
                          final spriteValue = data[key];
                          if (spriteValue is int) {
                            originalSpriteId = spriteValue;
                          } else if (spriteValue is String) {
                            originalSpriteId = int.tryParse(spriteValue) ?? 0;
                          } else if (spriteValue is num) {
                            originalSpriteId = (spriteValue as num).toInt();
                          }
                    
                          break;
                        }
                      }

                      final int level = extractLevel(data);
                    
                      List<int> typeIds = [];
                      List<String> possibleTypesKeys = [
                        'types',
                        'types ',
                        ' types',
                        'Types',
                        'TYPES',
                      ];
                      List<dynamic> typesData = [];
                      for (String key in possibleTypesKeys) {
                        if (data.containsKey(key)) {
                          typesData = data[key] ?? [];
                          break;
                        }
                      }

                      if (typesData.isNotEmpty) {
                        if (typesData.first is String) {
                          final List<String> typeNames = typesData
                              .map((e) => e.toString().trim())
                              .toList();
                          typeIds = convertTypesToIds(typeNames);
                        } else if (typesData.first is int) {
                          typeIds = typesData.map((e) => e as int).toList();
                        }
                      }

                      int correctSpriteId = getCorrectPokemonId(
                        name,
                        originalSpriteId,
                      );

                      final pokemon = Pokemon(
                        name: name,
                        spriteId: correctSpriteId,
                        typeIds: typeIds,
                        level: level,
                        moves: [],
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color.fromARGB(
                              255,
                              245,
                              177,
                              209,
                            ),
                            radius: 30,
                            child: ClipOval(
                              child: Image.network(
                                pokemon.spriteUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: const Color.fromARGB(
                                              255,
                                              138,
                                              7,
                                              61,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.catching_pokemon,
                                        color: Color.fromARGB(255, 138, 7, 61),
                                        size: 30,
                                      ),
                                      Text(
                                        '${pokemon.spriteId}',
                                        style: const TextStyle(fontSize: 8),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 138, 7, 61),
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    245,
                                    177,
                                    209,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      138,
                                      7,
                                      61,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 10,
                                      color: Color.fromARGB(255, 138, 7, 61),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Nível $level',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 138, 7, 61),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...pokemon.tipoNomes.map((tipoNome) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    tipoNome,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color.fromARGB(255, 137, 29, 92),
                                  size: 24,
                                ),
                                onPressed: () => _deletePokemon(docId, name),
                                tooltip: 'Remover Pokémon',
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () async {
                            final novoNivel = await Navigator.push<int>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PokemonScreen(
                                  pokemon: pokemon,
                                  docId: docId,
                                ),
                              ),
                            );
                            if (novoNivel != null) {
                              setState(() {
                                pokemon.level = novoNivel;
                              });
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}