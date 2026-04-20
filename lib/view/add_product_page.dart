import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/product.dart';
import '../restrictions/validators.dart';
import '../theme/colors.dart';
import 'widgets/app_text_field.dart';

// ─────────────────────────────────────────────
// Page Ajouter un produit
// ─────────────────────────────────────────────
class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, required this.onProductAdded});

  final void Function(Product product) onProductAdded;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  ProductCategory? _selectedCategory;
  final Set<BuyerType> _selectedBuyers = {};
  XFile? _pickedImage; // image sélectionnée
  final _picker = ImagePicker(); // instance du picker
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // ── Validation et soumission ──
  void _submit() {
    final name = _nameCtrl.text.trim();
    final brand = _brandCtrl.text.trim();
    final quantityStr = _quantityCtrl.text.trim();
    final priceStr = _priceCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();

    // Validations
    final nameError = AppValidators.name(name);
    if (nameError != null) {
      _showError(nameError);
      return;
    }

    final brandError = AppValidators.name(brand);
    if (brandError != null) {
      _showError('Marque : $brandError');
      return;
    }

    if (_selectedCategory == null) {
      _showError('Veuillez sélectionner une catégorie.');
      return;
    }

    final quantity = int.tryParse(quantityStr);
    if (quantityStr.isEmpty || quantity == null || quantity < 0) {
      _showError('Quantité invalide.');
      return;
    }

    final price = double.tryParse(priceStr.replaceAll(',', '.'));
    if (priceStr.isEmpty || price == null || price <= 0) {
      _showError('Prix invalide.');
      return;
    }

    if (_selectedBuyers.isEmpty) {
      _showError('Sélectionnez au moins un type d\'acheteur autorisé.');
      return;
    }

    setState(() => _isLoading = true);

    // Simule une sauvegarde asynchrone
    Future.delayed(const Duration(milliseconds: 600), () {
      final newProduct = Product(
        id: 'PRD-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        brand: brand,
        category: _selectedCategory!,
        quantity: quantity,
        price: price,
        description: description,
        allowedBuyers: _selectedBuyers.toList(),
      );

      kProducts.add(newProduct);
      widget.onProductAdded(newProduct);

      setState(() => _isLoading = false);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(child: Text('« $name » ajouté au catalogue !')),
            ],
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nouveau produit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              Text(
                'Remplir les informations',
                style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  // ── Body ──
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo du produit ──
          _sectionTitle('Photo du produit', Icons.photo_camera_outlined),
          const SizedBox(height: 14),
          _buildImagePicker(),
          const SizedBox(height: 24),

          // ── Section Informations générales ──
          _sectionTitle('Informations générales', Icons.info_outline_rounded),
          const SizedBox(height: 14),
          AppTextField(
            controller: _nameCtrl,
            label: 'Nom du produit *',
            icon: Icons.inventory_2_outlined,
            inputFormatters: AppFormatters.name,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _brandCtrl,
            label: 'Marque *',
            icon: Icons.branding_watermark_outlined,
            inputFormatters: AppFormatters.name,
          ),
          const SizedBox(height: 14),

          // ── Catégorie ──
          _sectionTitle('Catégorie *', Icons.category_outlined),
          const SizedBox(height: 10),
          _buildCategoryGrid(),
          const SizedBox(height: 24),

          // ── Stock & Prix ──
          _sectionTitle('Stock & Prix', Icons.monetization_on_outlined),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _quantityCtrl,
                  label: 'Quantité *',
                  icon: Icons.layers_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: AppFormatters.digitsOnly,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppTextField(
                  controller: _priceCtrl,
                  label: 'Prix (DA) *',
                  icon: Icons.sell_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Description ──
          _sectionTitle('Description', Icons.description_outlined),
          const SizedBox(height: 14),
          _buildDescriptionField(),
          const SizedBox(height: 24),

          // ── Acheteurs autorisés ──
          _sectionTitle('Acheteurs autorisés *', Icons.people_outline_rounded),
          const SizedBox(height: 4),
          Text(
            'Qui a le droit d\'acheter ce produit ?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _buildBuyerSelection(),
        ],
      ),
    );
  }

  // ── Titre de section ──
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ── Sélecteur de photo ──
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked != null) setState(() => _pickedImage = picked);
    } catch (_) {
      _showError('Impossible daccéder à la galerie/caméra.');
    }
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _pickedImage != null
                    ? AppColors.accent
                    : AppColors.textHint.withOpacity(0.4),
            width: _pickedImage != null ? 2 : 1.5,
            style: _pickedImage != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child:
            _pickedImage != null
                ? _buildImagePreview()
                : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.accent,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ajouter une photo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Appuyez pour choisir depuis la galerie ou la caméra',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child:
              kIsWeb
                  ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                  : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
        ),
        // Overlay sombre en bas
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Photo sélectionnée',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Bouton changer
                GestureDetector(
                  onTap: () => _showImageSourceDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Changer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bouton supprimer
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _pickedImage = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choisir une photo',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Galerie
                _imageSourceOption(
                  icon: Icons.photo_library_outlined,
                  iconColor: AppColors.accent,
                  iconBg: AppColors.accentLight,
                  label: 'Choisir depuis la galerie',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
                // Caméra
                _imageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  iconColor: AppColors.green,
                  iconBg: const Color(0x1539B54A),
                  label: 'Prendre une photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.textHint.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── Dropdown catégorie ──
  Widget _buildCategoryGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selectedCategory != null
                  ? AppColors.accent
                  : AppColors.textHint.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProductCategory>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.accent,
            size: 22,
          ),
          hint: Text(
            'Sélectionner une catégorie',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
          ),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          onChanged: (cat) => setState(() => _selectedCategory = cat),
          items:
              ProductCategory.values.map((cat) {
                return DropdownMenuItem<ProductCategory>(
                  value: cat,
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // ── Champ description multi-lignes ──
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _descriptionCtrl,
        maxLines: 4,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Description du produit (optionnel)...',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Sélection acheteurs ──
  Widget _buildBuyerSelection() {
    return Row(
      children:
          BuyerType.values.map((type) {
            final isSelected = _selectedBuyers.contains(type);
            final color = _buyerColor(type);
            return Expanded(
              child: GestureDetector(
                onTap:
                    () => setState(() {
                      if (isSelected) {
                        _selectedBuyers.remove(type);
                      } else {
                        _selectedBuyers.add(type);
                      }
                    }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: type != BuyerType.values.last ? 10 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? color.withOpacity(0.12)
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : AppColors.background,
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: color.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                            : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _buyerIcon(type),
                        color: isSelected ? color : AppColors.textHint,
                        size: 26,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? color : AppColors.textHint,
                            width: 1.5,
                          ),
                        ),
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 13,
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Color _buyerColor(BuyerType type) {
    switch (type) {
      case BuyerType.professionnel:
        return AppColors.accent;
      case BuyerType.autre:
        return AppColors.green;
    }
  }

  IconData _buyerIcon(BuyerType type) {
    switch (type) {
      case BuyerType.professionnel:
        return Icons.medical_services_outlined;
      case BuyerType.autre:
        return Icons.person_outline_rounded;
    }
  }

  // ── Barre du bas avec bouton Ajouter ──
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDeep,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                  : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Ajouter au catalogue',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
