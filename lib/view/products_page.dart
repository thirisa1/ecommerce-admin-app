import 'dart:async';
import 'package:flutter/material.dart';
import '../model/product.dart';
import '../backend/product_service.dart';
import '../theme/colors.dart';
import 'add_product_page.dart';

// ─────────────────────────────────────────────
// Page Produits — recherche Firestore en temps réel
// ─────────────────────────────────────────────
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // ── État ──
  List<Product> _allProducts   = [];   // tous les produits chargés
  List<Product> _filtered      = [];   // résultat affiché
  bool          _isLoading     = true;
  String        _searchQuery   = '';
  ProductCategory? _filterCategory;

  // Debounce pour ne pas rechercher à chaque frappe
  Timer? _debounce;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Chargement initial depuis Firestore ──
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await ProductService.fetchProducts();
    if (mounted) {
      setState(() {
        _allProducts = products;
        _isLoading   = false;
        _applyFilters();
      });
    }
  }

  // ── Filtrage local (nom, catégorie) ──
  void _applyFilters() {
    var list = List<Product>.from(_allProducts);

    // Filtre catégorie
    if (_filterCategory != null) {
      list = list.where((p) => p.category == _filterCategory).toList();
    }

    // Filtre texte (nom ou catégorie)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.category.label.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q);
      }).toList();
    }

    setState(() => _filtered = list);
  }

  // ── Recherche avec debounce 400ms ──
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _searchQuery = value);
      _applyFilters();
    });
  }

  // ── Effacer la recherche ──
  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _searchQuery = '');
    _applyFilters();
  }

  // ── Callback après ajout d'un produit ──
  void _onProductAdded(Product p) {
    setState(() {
      _allProducts.insert(0, p);
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_allProducts.isNotEmpty) _buildCategoryFilter(),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
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
                offset: const Offset(0, 4)),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Produits',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17)),
              const Text('Catalogue médico-dentaire',
                  style: TextStyle(
                      color: Color(0xAAFFFFFF), fontSize: 10)),
            ],
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_allProducts.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Barre de recherche ──
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Rechercher par nom ou catégorie...',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.accent, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: AppColors.textHint, size: 18),
                    onPressed: _clearSearch,
                  )
                : null,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // ── Chips filtre catégorie ──
  Widget _buildCategoryFilter() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 38,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          children: [
            _FilterChip(
              label: 'Tous',
              isSelected: _filterCategory == null,
              onTap: () {
                setState(() => _filterCategory = null);
                _applyFilters();
              },
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            // Affiche uniquement les catégories présentes dans les produits
            ..._presentCategories().map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: cat.label,
                    isSelected: _filterCategory == cat,
                    onTap: () {
                      setState(() => _filterCategory =
                          _filterCategory == cat ? null : cat);
                      _applyFilters();
                    },
                    color: AppColors.accent,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Retourne uniquement les catégories qui ont au moins un produit
  List<ProductCategory> _presentCategories() {
    final set = _allProducts.map((p) => p.category).toSet().toList();
    set.sort((a, b) => a.label.compareTo(b.label));
    return set;
  }

  // ── Contenu principal ──
  Widget _buildContent() {
    // Chargement
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Chargement du catalogue...',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    // Catalogue vide
    if (_allProducts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Aucun produit',
        subtitle:
            'Le catalogue est vide.\nCliquez sur « Ajouter un produit » pour commencer.',
        showRefresh: false,
      );
    }

    // Aucun résultat pour la recherche
    if (_filtered.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Aucun résultat',
        subtitle:
            'Aucun produit ne correspond\nà "${_searchQuery.isNotEmpty ? _searchQuery : _filterCategory?.label ?? ''}".',
        showRefresh: true,
        onRefresh: () {
          _clearSearch();
          setState(() => _filterCategory = null);
          _applyFilters();
        },
      );
    }

    // Liste des résultats
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _filtered.length,
        itemBuilder: (context, index) =>
            _ProductCard(product: _filtered[index], index: index),
      ),
    );
  }

  // ── État vide ──
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showRefresh = false,
    VoidCallback? onRefresh,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.6)),
            if (showRefresh && onRefresh != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réinitialiser les filtres'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Bouton Ajouter en bas ──
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowDeep,
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddProductPage(onProductAdded: _onProductAdded),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 20),
              SizedBox(width: 10),
              Text('Ajouter un produit',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Chip filtre catégorie
// ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.textHint.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Carte produit avec animation
// ─────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product, required this.index});

  final Product product;
  final int index;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(Duration(milliseconds: widget.index * 50),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              splashColor: AppColors.accentLight,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // ── Image ou icône ──
                    _buildProductImage(p),
                    const SizedBox(width: 14),
                    // ── Infos ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(p.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${p.price.toStringAsFixed(0)} DA',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(p.brand,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // Badge catégorie
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(p.category.label,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Quantité
                              Icon(Icons.layers_outlined,
                                  size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              Text('Qté: ${p.quantity}',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Affiche la photo Cloudinary si disponible, sinon icône
  Widget _buildProductImage(Product p) {
    if (p.imagePath != null && p.imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          p.imagePath!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconFallback(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    }
    return _iconFallback();
  }

  Widget _iconFallback() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.appBarGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.medical_services_outlined,
          color: Colors.white, size: 26),
    );
  }
}