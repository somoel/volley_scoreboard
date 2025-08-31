import 'package:flutter/material.dart';
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partidos"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return ListTile(
                title: Text(
                    'Partido el ${match.date
                        .toLocal()
                        .toString()
                        .split(' ')[0]}'
                ),
                subtitle: Text(match.location ?? 'Ubicación desconocida'),
              );
            },
          );
        },
      ),
    );
  }
}