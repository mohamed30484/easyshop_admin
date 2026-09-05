import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/injection_container.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import 'add_category_page.dart';
import 'edit_category_page.dart';

class ManageCategoriesPage extends StatelessWidget {
  const ManageCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoriesCubit>()..getCategories(),
      child: const _ManageCategoriesView(),
    );
  }
}

class _ManageCategoriesView extends StatefulWidget {
  const _ManageCategoriesView();

  @override
  State<_ManageCategoriesView> createState() => _ManageCategoriesViewState();
}

class _ManageCategoriesViewState extends State<_ManageCategoriesView> {
  static const orange = Color(0xFFFF821D);
  static const dark = Color(0xFF20212B);
  static const grey = Color(0xFF92939D);
  static const background = Color(0xFFF7F8FA);

  int _selectedIndex = 1;

  Future<void> _openAddCategoryPage() async {
    final categoriesCubit = context.read<CategoriesCubit>();

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: categoriesCubit,
          child: const AddCategoryPage(),
        ),
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    await context.read<CategoriesCubit>().getCategories();
  }

  Future<void> _openEditCategoryPage(CategoryEntity category) async {
    final categoriesCubit = context.read<CategoriesCubit>();

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: categoriesCubit,
          child: EditCategoryPage(category: category),
        ),
      ),
    );

    if (!mounted || changed != true) {
      return;
    }

    await context.read<CategoriesCubit>().getCategories();
  }

  void _onBottomNavigationChanged(int index) {
    if (index == 0) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      return;
    }

    if (index == 1) {
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This page will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _CategoriesHeader(
              onBack: () => Navigator.of(context).pop(),
              onAdd: _openAddCategoryPage,
            ),
            const SizedBox(height: 22),
            Expanded(
              child: BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: orange),
                    );
                  }

                  if (state is CategoriesFailure) {
                    return _CategoriesErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<CategoriesCubit>().getCategories();
                      },
                    );
                  }

                  if (state is CategoriesLoaded) {
                    if (state.categories.isEmpty) {
                      return const _CategoriesEmptyView();
                    }

                    return RefreshIndicator(
                      color: orange,
                      onRefresh: () async {
                        await context.read<CategoriesCubit>().getCategories();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        itemCount: state.categories.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final category = state.categories[index];

                          return _CategoryCard(
                            category: category,
                            onEdit: () => _openEditCategoryPage(category),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CategoriesBottomBar(
        selectedIndex: _selectedIndex,
        onChanged: _onBottomNavigationChanged,
      ),
    );
  }
}

class _CategoriesHeader extends StatelessWidget {
  const _CategoriesHeader({required this.onBack, required this.onAdd});

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _ManageCategoriesViewState.dark,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ManageCategoriesViewState.dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: _ManageCategoriesViewState.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onEdit});

  final CategoryEntity category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final description = category.description.trim().isEmpty
        ? 'No description'
        : category.description;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17)),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF5EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sell_outlined,
                color: _ManageCategoriesViewState.orange,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ManageCategoriesViewState.dark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ManageCategoriesViewState.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              splashRadius: 21,
              tooltip: 'Edit category',
              icon: const Icon(
                Icons.edit_outlined,
                color: _ManageCategoriesViewState.grey,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesEmptyView extends StatelessWidget {
  const _CategoriesEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sell_outlined,
              color: _ManageCategoriesViewState.orange,
              size: 52,
            ),
            SizedBox(height: 14),
            Text(
              'No categories yet',
              style: TextStyle(
                color: _ManageCategoriesViewState.dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the plus button to add your first category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ManageCategoriesViewState.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesErrorView extends StatelessWidget {
  const _CategoriesErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ManageCategoriesViewState.dark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ManageCategoriesViewState.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesBottomBar extends StatelessWidget {
  const _CategoriesBottomBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products'),
      (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = selectedIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? item.$2 : item.$1,
                    color: selected
                        ? _ManageCategoriesViewState.orange
                        : const Color(0xFF9699A5),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected
                          ? _ManageCategoriesViewState.orange
                          : const Color(0xFF9699A5),
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 28 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _ManageCategoriesViewState.orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
