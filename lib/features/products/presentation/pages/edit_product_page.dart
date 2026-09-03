import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/injection_container.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/update_product_params.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';

class EditProductPage extends StatelessWidget {
  const EditProductPage({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CategoriesCubit>()..getCategories()),
        BlocProvider(create: (_) => sl<ProductsCubit>()),
      ],
      child: _EditProductView(product: product),
    );
  }
}

class _EditProductView extends StatefulWidget {
  const _EditProductView({required this.product});

  final ProductEntity product;

  @override
  State<_EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<_EditProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  static const orange = Color(0xFFFF821D);
  static const dark = Color(0xFF20212B);
  static const grey = Color(0xFF92939D);
  static const background = Color(0xFFF7F8FA);

  bool _visible = true;
  int? _selectedCategoryId;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toStringAsFixed(0);
    _quantityController.text = widget.product.quantity.toString();
    _descriptionController.text = widget.product.description ?? '';
    _visible = widget.product.visible;
    _selectedCategoryId = widget.product.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;

      setState(() => _selectedImage = image);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pick this image.')),
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Wrap(
              children: [
                const Center(
                  child: Text(
                    'Change product image',
                    style: TextStyle(
                      color: dark,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: orange,
                  ),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: orange),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final categoryId = _selectedCategoryId;
    final price = double.tryParse(_priceController.text.trim());
    final quantity = int.tryParse(_quantityController.text.trim());

    if (categoryId == null || price == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    context.read<ProductsCubit>().updateProduct(
      UpdateProductParams(
        slug: widget.product.slug,
        name: _nameController.text.trim(),
        price: price,
        quantity: quantity,
        categoryId: categoryId,
        visible: _visible,
        description: _descriptionController.text.trim(),
        imagePath: _selectedImage?.path,
      ),
    );
  }

  void _onNavigationChanged(int index) {
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
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
    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductUpdated) {
          Navigator.of(context).pop(true);
          return;
        }

        if (state is ProductUpdateFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          final isUpdating = state is ProductUpdating;

          return Scaffold(
            backgroundColor: background,
            appBar: AppBar(
              backgroundColor: background,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                onPressed: isUpdating
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: dark,
              ),
              title: const Text(
                'Edit Product',
                style: TextStyle(
                  color: dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ImageBox(
                        product: widget.product,
                        selectedImage: _selectedImage,
                        onTap: _showImageSourceSheet,
                      ),
                      const SizedBox(height: 18),
                      const _FieldLabel('Product Name'),
                      const SizedBox(height: 7),
                      _InputField(
                        controller: _nameController,
                        hint: 'Product name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const _FieldLabel('Category'),
                      const SizedBox(height: 7),
                      BlocBuilder<CategoriesCubit, CategoriesState>(
                        builder: (context, state) {
                          if (state is CategoriesLoading ||
                              state is CategoriesInitial) {
                            return const _CategoryLoadingField();
                          }

                          if (state is CategoriesFailure) {
                            return _CategoryFailureField(
                              message: state.message,
                              onRetry: () => context
                                  .read<CategoriesCubit>()
                                  .getCategories(),
                            );
                          }

                          if (state is CategoriesLoaded) {
                            return _CategoryDropdown(
                              categories: state.categories,
                              selectedCategoryId: _selectedCategoryId,
                              onChanged: (value) {
                                setState(() => _selectedCategoryId = value);
                              },
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Price'),
                                const SizedBox(height: 7),
                                _InputField(
                                  controller: _priceController,
                                  hint: '0.00',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (value) {
                                    final price = double.tryParse(
                                      value?.trim() ?? '',
                                    );
                                    if (price == null || price < 0) {
                                      return 'Invalid price';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Quantity'),
                                const SizedBox(height: 7),
                                _InputField(
                                  controller: _quantityController,
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    final quantity = int.tryParse(
                                      value?.trim() ?? '',
                                    );
                                    if (quantity == null || quantity < 0) {
                                      return 'Invalid quantity';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _FieldLabel('Description', optional: true),
                      const SizedBox(height: 7),
                      _InputField(
                        controller: _descriptionController,
                        hint: 'Optional product description...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Visible to customers',
                                    style: TextStyle(
                                      color: dark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Show this product in your store',
                                    style: TextStyle(color: grey, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _visible,
                              activeThumbColor: orange,
                              onChanged: isUpdating
                                  ? null
                                  : (value) {
                                      setState(() => _visible = value);
                                    },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isUpdating ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: orange,
                            disabledBackgroundColor: const Color(0xFFF8BC88),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: _BottomBar(
              selectedIndex: 1,
              onChanged: isUpdating ? (_) {} : _onNavigationChanged,
            ),
          );
        },
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  const _ImageBox({
    required this.product,
    required this.selectedImage,
    required this.onTap,
  });

  final ProductEntity product;
  final XFile? selectedImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasNewImage = selectedImage != null;
    final hasOldImage = product.imageUrl.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 141,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EFF4),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFD6D5DD)),
        ),
        child: hasNewImage
            ? Image.file(File(selectedImage!.path), fit: BoxFit.cover)
            : hasOldImage
            ? Image.network(product.imageUrl, fit: BoxFit.cover)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: _EditProductViewState.grey,
                    size: 26,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Add product image (optional)',
                    style: TextStyle(
                      color: _EditProductViewState.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final List<CategoryEntity> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: categories.any((item) => item.id == selectedCategoryId)
          ? selectedCategoryId
          : null,
      decoration: _inputDecoration('Select category'),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      isExpanded: true,
      items: categories
          .map(
            (category) => DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select category' : null,
    );
  }
}

class _CategoryLoadingField extends StatelessWidget {
  const _CategoryLoadingField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0F5),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _EditProductViewState.orange,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading categories...',
            style: TextStyle(color: _EditProductViewState.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CategoryFailureField extends StatelessWidget {
  const _CategoryFailureField({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFFD2D2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _EditProductViewState.dark,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _EditProductViewState.dark,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        children: optional
            ? const [
                TextSpan(
                  text: ' (Optional)',
                  style: TextStyle(
                    color: _EditProductViewState.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(hint),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _EditProductViewState.grey, fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF1F0F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide.none,
    ),
    errorStyle: const TextStyle(fontSize: 11),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selectedIndex, required this.onChanged});

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
                        ? _EditProductViewState.orange
                        : const Color(0xFF9699A5),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected
                          ? _EditProductViewState.orange
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
                      color: _EditProductViewState.orange,
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
