import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/update_category_params.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';

class EditCategoryPage extends StatefulWidget {
  const EditCategoryPage({super.key, required this.category});

  final CategoryEntity category;

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  static const orange = Color(0xFFFF821D);
  static const dark = Color(0xFF20212B);
  static const grey = Color(0xFF92939D);
  static const background = Color(0xFFF7F8FA);
  static const fieldBackground = Color(0xFFF0EFF5);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(
      text: widget.category.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<CategoriesCubit>().updateCategory(
      UpdateCategoryParams(
        slug: widget.category.slug,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  void _onBottomNavigationChanged(int index) {
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
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
    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is CategoriesUpdated) {
          Navigator.of(context).pop(true);
          return;
        }

        if (state is CategoriesFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          final isSaving = state is CategoriesUpdating;

          return Scaffold(
            backgroundColor: background,
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _EditCategoryHeader(
                      onBack: isSaving
                          ? () {}
                          : () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 26),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category Name',
                              style: TextStyle(
                                color: dark,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 9),
                            TextFormField(
                              controller: _nameController,
                              enabled: !isSaving,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                color: dark,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDecoration(
                                hintText: 'e.g. Electronics',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Category name is required.';
                                }

                                if (value.trim().length < 2) {
                                  return 'Category name must be at least 2 characters.';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 19),
                            const Row(
                              children: [
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    color: dark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '(Optional)',
                                  style: TextStyle(color: grey, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            TextFormField(
                              controller: _descriptionController,
                              enabled: !isSaving,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              style: const TextStyle(
                                color: dark,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDecoration(
                                hintText: 'Brief description...',
                              ),
                              onFieldSubmitted: (_) {
                                if (!isSaving) {
                                  _saveChanges();
                                }
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: orange,
                                  disabledBackgroundColor: const Color(
                                    0xFFFFC18D,
                                  ),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _EditCategoryBottomBar(
              selectedIndex: 1,
              onChanged: isSaving ? (_) {} : _onBottomNavigationChanged,
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: grey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: fieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      errorStyle: const TextStyle(fontSize: 11, height: 1.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: orange, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }
}

class _EditCategoryHeader extends StatelessWidget {
  const _EditCategoryHeader({required this.onBack});

  final VoidCallback onBack;

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
              color: _EditCategoryPageState.dark,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Category',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _EditCategoryPageState.dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _EditCategoryBottomBar extends StatelessWidget {
  const _EditCategoryBottomBar({
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
                        ? _EditCategoryPageState.orange
                        : const Color(0xFF9699A5),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected
                          ? _EditCategoryPageState.orange
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
                      color: _EditCategoryPageState.orange,
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
