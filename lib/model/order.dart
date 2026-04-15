import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ─────────────────────────────────────────────
// Enum statut de commande
// ─────────────────────────────────────────────
enum OrderStatus { enAttente, validee, enCours, livree }

extension OrderStatusStyle on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.enAttente: return 'En attente';
      case OrderStatus.validee:   return 'Validée';
      case OrderStatus.enCours:   return 'En cours';
      case OrderStatus.livree:    return 'Livrée';
    }
  }

  Color get badgeColor {
    switch (this) {
      case OrderStatus.enAttente: return AppColors.statusEnAttente;
      case OrderStatus.validee:   return AppColors.statusValidee;
      case OrderStatus.enCours:   return AppColors.statusEnCours;
      case OrderStatus.livree:    return AppColors.statusLivree;
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.enAttente: return AppColors.statusEnAttenteText;
      default:                    return AppColors.textOnDark;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.enAttente: return Icons.access_time_rounded;
      case OrderStatus.validee:   return Icons.check_circle_outline_rounded;
      case OrderStatus.enCours:   return Icons.local_shipping_outlined;
      case OrderStatus.livree:    return Icons.done_all_rounded;
    }
  }
}

// ─────────────────────────────────────────────
// Modèle Order
// ─────────────────────────────────────────────
class Order {
  final String id;
  final String clientName;
  final String date;
  final double amount;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.clientName,
    required this.date,
    required this.amount,
    required this.status,
  });
}

// ─────────────────────────────────────────────
// Données fictives
// ─────────────────────────────────────────────
const List<Order> kSampleOrders = [
  Order(id: 'CMD-001', clientName: 'Jean Dupont',    date: '31/03/2026', amount: 250,  status: OrderStatus.enAttente),
  Order(id: 'CMD-002', clientName: 'Marie Martin',   date: '31/03/2026', amount: 180,  status: OrderStatus.validee),
  Order(id: 'CMD-003', clientName: 'Pierre Durand',  date: '30/03/2026', amount: 320,  status: OrderStatus.enCours),
  Order(id: 'CMD-004', clientName: 'Sophie Laurent', date: '30/03/2026', amount: 95,   status: OrderStatus.livree),
  Order(id: 'CMD-005', clientName: 'Lucas Bernard',  date: '29/03/2026', amount: 410,  status: OrderStatus.enAttente),
  Order(id: 'CMD-006', clientName: 'Emma Leblanc',   date: '29/03/2026', amount: 760,  status: OrderStatus.enCours),
];