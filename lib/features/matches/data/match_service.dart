import 'package:volley_scoreboard/supabase_client.dart';
import 'match_model.dart';

class MatchService {
  final _client = SupabaseConfig.client;

  Future<List<MatchModel>> fetchMatches() async {
    final response = await _client.from('matches').select().order('date');
    final data = response as List<dynamic>;
    return data.map((item) => MatchModel.fromMap(item as Map<String, dynamic>)).toList();
  }
}
