import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../model/product.dart';
import '../theme/colors.dart';
import '../backend/product_service.dart';

// ─────────────────────────────────────────────
// Page Ajouter un produit
// ─────────────────────────────────────────────
class AddProductPage extends StatefulWidget {
  final void Function(Product) onProductAdded;

  const AddProductPage({super.key, required this.onProductAdded});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _nomCtrl = TextEditingController();
  final _marqueCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _quantiteCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Sélections
  ProductCategory? _selectedCategory;
  final Set<BuyerType> _selectedBuyers = {};

  // Image
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _marqueCtrl.dispose();
    _prixCtrl.dispose();
    _quantiteCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // ── Sélectionner une image depuis la galerie ──
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  // ── Soumettre le formulaire ──
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showError('Veuillez sélectionner une catégorie.');
      return;
    }
    if (_selectedBuyers.isEmpty) {
      _showError('Veuillez sélectionner au moins un type d\'acheteur.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = await ProductService.addProduct(
        nom: _nomCtrl.text.trim(),
        marque: _marqueCtrl.text.trim(),
        category: _selectedCategory!,
        prix: double.parse(_prixCtrl.text.trim()),
        quantite: int.parse(_quantiteCtrl.text.trim()),
        description: _descriptionCtrl.text.trim(),
        acheteurs: _selectedBuyers.toList(),
        imageFile: _imageFile,
      );

      kProducts.add(product);
      widget.onProductAdded(product);

      if (mounted) {
        _showSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produit ajouté avec succès !'),
        backgroundColor: Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 20),
                    _buildSection('Informations générales', [
                      _buildTextField(
                        controller: _nomCtrl,
                        label: 'Nom du produit',
                        icon: Icons.label_outline,
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Champ requis'
                                    : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _marqueCtrl,
                        label: 'Marque',
                        icon: Icons.business_outlined,
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Champ requis'
                                    : null,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Prix & Quantité', [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _prixCtrl,
                              label: 'Prix (DA)',
                              icon: Icons.attach_money_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requis';
                                if (double.tryParse(v) == null)
                                  return 'Invalide';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _quantiteCtrl,
                              label: 'Quantité',
                              icon: Icons.layers_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requis';
                                if (int.tryParse(v) == null) return 'Invalide';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Catégorie', [_buildCategoryDropdown()]),
                    const SizedBox(height: 16),
                    _buildSection('Acheteurs autorisés', [_buildBuyerChips()]),
                    const SizedBox(height: 16),
                    _buildSection('Description', [
                      _buildTextField(
                        controller: _descriptionCtrl,
                        label: 'Description du produit',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        validator: null,
                      ),
                    ]),
                  ],
                ),
              ),
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
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
                'Ajouter au catalogue',
                style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  // ── Image picker ──
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child:
            _imageFile != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_imageFile!, fit: BoxFit.cover),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : Column(
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
                    const SizedBox(height: 10),
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
                      'Optionnel — appuyez pour sélectionner',
                      style: TextStyle(color: AppColors.textHint, fontSize: 11),
                    ),
                  ],
                ),
      ),
    );
  }

  // ── Section wrapper ──
  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ── TextField générique ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 18),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  // ── Dropdown catégorie ──
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<ProductCategory>(
      value: _selectedCategory,
      hint: Text(
        'Sélectionner une catégorie',
        style: TextStyle(color: AppColors.textHint, fontSize: 13),
      ),
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: AppColors.accent,
          size: 18,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      items:
          ProductCategory.values
              .map(
                (cat) => DropdownMenuItem(value: cat, child: Text(cat.label)),
              )
              .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
    );
  }

  // ── Chips acheteurs autorisés ──
  Widget _buildBuyerChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          BuyerType.values.map((buyer) {
            final isSelected = _selectedBuyers.contains(buyer);
            return GestureDetector(
              onTap:
                  () => setState(() {
                    isSelected
                        ? _selectedBuyers.remove(buyer)
                        : _selectedBuyers.add(buyer);
                  }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primary
                            : AppColors.textHint.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 15,
                      color: isSelected ? Colors.white : AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      buyer.label,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  // ── Bouton bas ──
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
            offset: const Offset(0, -4),
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
                      Icon(Icons.cloud_upload_outlined, size: 20),
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
