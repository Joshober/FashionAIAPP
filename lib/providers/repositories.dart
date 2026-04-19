import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/chat_repository.dart';
import '../repositories/garments_repository.dart';
import '../repositories/health_repository.dart';
import '../repositories/mirror_repository.dart';
import '../repositories/outfits_repository.dart';
import '../repositories/preferences_repository.dart';
import 'dio_client.dart';

final healthRepositoryProvider = Provider((ref) => HealthRepository(ref.watch(dioProvider)));
final garmentsRepositoryProvider = Provider((ref) => GarmentsRepository(ref.watch(dioProvider)));
final outfitsRepositoryProvider = Provider((ref) => OutfitsRepository(ref.watch(dioProvider)));
final preferencesRepositoryProvider =
    Provider((ref) => PreferencesRepository(ref.watch(dioProvider)));
final chatRepositoryProvider = Provider((ref) => ChatRepository(ref.watch(dioProvider)));
final mirrorRepositoryProvider = Provider((ref) => MirrorRepository(ref.watch(dioProvider)));
