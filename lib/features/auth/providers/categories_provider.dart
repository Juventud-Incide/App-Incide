import 'package:app_incide/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final servicesCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // Simulamos el delay de internet
  await Future.delayed(const Duration(seconds: 1));
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getServicesCatalog();
});

final categoriesCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getCategoriesCatalog();
});
