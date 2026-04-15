import 'product.dart';

// ─────────────────────────────────────────────
// Modèle Client
// ─────────────────────────────────────────────
class Client {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final BuyerType type;
  final String address;
  final bool isValidated;

  const Client({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.type,
    required this.address,
    required this.isValidated,
  });
}

// ─────────────────────────────────────────────
// Liste des clients (vide — données réelles via API)
// ─────────────────────────────────────────────
List<Client> kClients = [];