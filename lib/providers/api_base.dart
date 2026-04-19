import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';

final apiBaseUrlProvider = Provider<String>((ref) => apiBaseUrl());
