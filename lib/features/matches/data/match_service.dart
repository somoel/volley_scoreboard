import 'package:volley_scoreboard/supabase_client.dart';
import 'match_model.dart';

class MatchService {
  final _client = SupabaseConfig.client;

  Future<List<MatchModel>> fetchMatches() async {
    final response = await _client.from('matches').select().order('date');
    final data = response as List<dynamic>;
    return data.map((item) => MatchModel.fromMap(item as Map<String, dynamic>)).toList();
  }

  Future<void> addMatch({
    required DateTime date,
    String? location,
  }) async {
    await _client.from('matches').insert({
      'date': date.toIso8601String(),
      'location': location,
    });
  }

  Future<void> updateMatch({
    required String id,
    required DateTime date,
    String? location,
  }) async {
    await _client.from('matches').update({
      'date': date.toIso8601String(),
      'location': location,
    }).eq('id', id);
  }

  Future<void> deleteMatch(String id) async {
    await _client.from('matches').delete().eq('id', id);
  }
}
