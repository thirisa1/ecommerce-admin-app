import 'package:flutter/material.dart';
import '../restrictions/validators.dart';
import '../theme/colors.dart';
import '../theme/theme_provider.dart';
import 'widgets/app_text_field.dart';
import 'widgets/settings_item.dart';

// ─────────────────────────────────────────────
// Modèle des informations du comptoir
// ─────────────────────────────────────────────
class ComptorInfo {
  String name;
  String address;
  String phone;
  String email;

  ComptorInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });
}

// Instance globale (à remplacer par Provider/Riverpod/BLoC selon votre archi)
final comptorInfo = ComptorInfo(
  name: 'MTS Médico-Dentaire',
  address: 'Béjaïa, Algérie',
  phone: '+213 XX XX XX XX',
  email: 'admin@mts-dentaire.dz',
);

// ─────────────────────────────────────────────
// Fonction pour ouvrir le panneau
// ─────────────────────────────────────────────
void openSettingsPanel(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Settings',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => const SettingsPanel(),
    transitionBuilder: (context, animation, _, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
  );
}

// ─────────────────────────────────────────────
// Panneau latéral Paramètres
// ─────────────────────────────────────────────
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Animation<double> _itemAnim(int index) {
    final start = (index * 0.18).clamp(0.0, 1.0);
    final end = (start + 0.55).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Widget _animated({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _itemAnim(index),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.25, 0),
          end: Offset.zero,
        ).animate(_itemAnim(index)),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder reconstruit le panneau quand themeProvider change,
    // même depuis l'overlay de showGeneralDialog
    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, _) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadowDeep,
                      blurRadius: 40,
                      offset: const Offset(-8, 0)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _animated(index: 0, child: _buildProfileCard()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      child: Divider(
                          color: AppColors.background, thickness: 1.5),
                    ),
                    _animated(
                      index: 1,
                      child: SettingsItem(
                        icon: Icons.storefront_outlined,
                        iconColor: AppColors.accent,
                        iconBg: AppColors.accentLight,
                        title: 'Modifier informations',
                        subtitle: 'Adresse, téléphone, email',
                        onTap: () => _openEditSheet(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _animated(
                      index: 2,
                      child: _buildThemeToggle(),
                    ),
                    const Spacer(),
                    _animated(index: 3, child: _buildLogoutButton(context)),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── En-tête ──
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.appBarGradient,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28)),
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paramètres',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              SizedBox(height: 3),
              Text('MTS Médico-Dentaire',
                  style:
                      TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte profil ──
  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.background, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.appBarGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('MTS',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comptorInfo.name,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comptorInfo.email,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Super Admin',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Toggle Light / Dark ──
  // AnimatedBuilder écoute themeProvider directement →
  // le switch se met à jour même depuis un overlay séparé
  Widget _buildThemeToggle() {
    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, _) {
        final isDark = themeProvider.isDark;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.background, width: 1.5),
            ),
            child: Row(
              children: [
                // Icône animée
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x1AFAFAFA)
                        : const Color(0x1AFFCC00),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: isDark
                        ? const Color(0xFFB0BED9)
                        : const Color(0xFFFFAA00),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apparence',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDark ? 'Mode sombre activé' : 'Mode clair activé',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Switch animé
                GestureDetector(
                  onTap: () => themeProvider.toggleTheme(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 52,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isDark ? AppColors.primary : AppColors.textHint,
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: isDark ? 26 : 2,
                          top: 2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny_rounded,
                              size: 14,
                              color: isDark
                                  ? AppColors.primary
                                  : const Color(0xFFFFAA00),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ── Bouton Déconnexion ──
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _showLogoutConfirm(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  color: Color(0xFFD32F2F), size: 20),
              SizedBox(width: 10),
              Text('Se déconnecter',
                  style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Ouvrir le bottom sheet d'édition ──
  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditInfoSheet(
        onSave: (name, address, phone, email) {
          setState(() {
            comptorInfo.name    = name;
            comptorInfo.address = address;
            comptorInfo.phone   = phone;
            comptorInfo.email   = email;
          });
        },
      ),
    );
  }

  // ── Dialog déconnexion ──
  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
            SizedBox(width: 10),
            Text('Déconnexion',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text('Voulez-vous vraiment vous déconnecter ?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // TODO: rediriger vers l'écran de login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Se déconnecter',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom sheet — Modifier informations
// ─────────────────────────────────────────────
class EditInfoSheet extends StatefulWidget {
  const EditInfoSheet({super.key, required this.onSave});

  final void Function(
      String name, String address, String phone, String email) onSave;

  @override
  State<EditInfoSheet> createState() => _EditInfoSheetState();
}

class _EditInfoSheetState extends State<EditInfoSheet> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _addressCtrl = TextEditingController(text: comptorInfo.address);
    _phoneCtrl   = TextEditingController(text: comptorInfo.phone);
    _emailCtrl   = TextEditingController(text: comptorInfo.email);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final address = _addressCtrl.text.trim();
    final phone   = _phoneCtrl.text.trim();
    final email   = _emailCtrl.text.trim();

    final addressError = AppValidators.address(address);
    if (addressError != null) { _showError(addressError); return; }

    final phoneError = AppValidators.phone(phone);
    if (phoneError != null) { _showError(phoneError); return; }

    final emailError = AppValidators.email(email);
    if (emailError != null) { _showError(emailError); return; }

    widget.onSave(comptorInfo.name, address, phone, email);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Informations mises à jour !'),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Informations du comptoir',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Les modifications seront appliquées immédiatement.',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _addressCtrl,
            label: 'Adresse',
            icon: Icons.location_on_outlined,
            inputFormatters: AppFormatters.address,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _phoneCtrl,
            label: 'Téléphone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: AppFormatters.phone,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _emailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: AppFormatters.email,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: AppColors.textHint),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Annuler',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Sauvegarder',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}