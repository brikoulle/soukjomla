import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../config/design_system.dart';
import '../utils/error_handler.dart';

class ProductsListScreen extends StatefulWidget {
  final int? sellerId;
  final String? category;
  final String? searchQuery;

  const ProductsListScreen({
    Key? key,
    this.sellerId,
    this.category,
    this.searchQuery,
  }) : super(key: key);

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  late PagingController<int, Product> _pagingController;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final productService = context.read<ProductService>();
      final newItems = await productService.getProducts(
        page: pageKey,
        pageSize: _pageSize,
        sellerId: widget.sellerId,
        category: widget.category,
        search: widget.searchQuery,
      );

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Product>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Product>(
        itemBuilder: (context, product, index) => _ProductCard(product: product),
        firstPageErrorIndicatorBuilder: (context) => _ErrorWidget(
          error: _pagingController.error,
          onRetry: () => _pagingController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) => _ErrorWidget(
          error: _pagingController.error,
          onRetry: () => _pagingController.retryLastFailedRequest(),
        ),
        noItemsFoundIndicatorBuilder: (context) => const _EmptyStateWidget(),
        firstPageProgressIndicatorBuilder: (context) => const _LoadingWidget(),
        newPageProgressIndicatorBuilder: (context) => const _LoadingWidget(),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: product.coverImageUrl != null
            ? Image.network(
                product.coverImageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            : Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported,
                    color: Colors.grey.shade400),
              ),
        title: Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${product.price.toStringAsFixed(2)} MAD',
              style: TextStyle(
                color: DesignSystem.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'البائع: ${product.sellerName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey.shade400),
        onTap: () {
          // Navigate to product detail
          Navigator.of(context).pushNamed('/product/${product.id}');
        },
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(DesignSystem.primaryColor),
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorHandler.getUserFriendlyMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: DesignSystem.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة محاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
