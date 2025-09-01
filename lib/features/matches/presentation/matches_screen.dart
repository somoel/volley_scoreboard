import 'package:flutter/material.dart';
import 'package:volley_scoreboard/utils/date_utils.dart';
import 'add_match_screen.dart';
import '../data/match_model.dart';
import '../data/match_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final service = MatchService();
  late Future<List<MatchModel>> matchesFuture;
  
  @override
  void initState() {
    super.initState();
    matchesFuture = service.fetchMatches();
  }

  Widget _buildMatchesList(List<MatchModel> matches) {
    return RefreshIndicator(
      onRefresh: () async {
        final updatedMatches = await service.fetchMatches();
        setState(() {
          matchesFuture = Future.value(updatedMatches);
        });
      },
      child: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return ListTile(
            title: Text(
                'Partido el ${DateUtilsES.fullDate.format(match.date)}'
            ),
            subtitle: Text(match.location ?? 'Ubicación desconocida'),

            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMatchScreen(
                        matchId: match.id,
                        initialDate: match.date,
                        initialLocation: match.location,
                        isEdit: true,
                      ),
                    ),
                  );
                  if (updated ?? false) {
                    setState(() {
                      matchesFuture = service.fetchMatches();
                    });
                  }
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar partido'),
                        content: const Text(
                            '¿Estás seguro de que quieres '
                                'eliminar este partido?'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      )
                  );
                  if (confirmed ?? false) {
                    await service.deleteMatch(match.id);
                    setState(() {
                      matchesFuture = service.fetchMatches();
                    });
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          );
        }
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Partidos"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isDesktop)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                setState(() {
                  matchesFuture = service.fetchMatches();
                });
              },
            )
        ],
      ),
      body: FutureBuilder<List<MatchModel>>(
        future: matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          }
          final matches = snapshot.data ?? [];
          if (matches.isEmpty) {
            return const Center(child: Text('No se encontraron partidos'));
          }

          return _buildMatchesList(matches);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
              context,
            MaterialPageRoute(builder: (_) => const AddMatchScreen()),
          );
          if (added ?? false) {
            setState(() {
              matchesFuture = service.fetchMatches();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}