import 'package:flutter/material.dart';

import '../../../../core/services/admin_profile_storage.dart';
import '../../../auth/data/models/admin_model.dart';
import '../../../auth/domain/entities/admin_entity.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _orange = Color(0xFFFF821D);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _textPrimary = Color(0xFF20212B);
  static const Color _textSecondary = Color(0xFF92939D);

  final AdminProfileStorage _profileStorage = AdminProfileStorage();

  AdminModel? _admin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final admin = await _profileStorage.get();

    if (!mounted) {
      return;
    }

    setState(() {
      _admin = admin;
      _isLoading = false;
    });
  }

  Future<void> _onEditProfile() async {
    final currentAdmin = _admin;

    if (currentAdmin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile data is not available yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updatedAdmin = await Navigator.of(context).push<AdminEntity>(
      MaterialPageRoute(builder: (_) => EditProfilePage(admin: currentAdmin)),
    );

    if (!mounted || updatedAdmin == null) {
      return;
    }

    final updatedAdminModel = AdminModel(
      id: updatedAdmin.id,
      name: updatedAdmin.name,
      email: updatedAdmin.email,
      phone: updatedAdmin.phone,
      nationalId: updatedAdmin.nationalId,
      businessName: updatedAdmin.businessName,
      address: updatedAdmin.address,
      latitude: updatedAdmin.latitude,
      longitude: updatedAdmin.longitude,
      commercialRegister: updatedAdmin.commercialRegister,
      taxCard: updatedAdmin.taxCard,
      picture: updatedAdmin.picture,
    );

    try {
      await _profileStorage.save(updatedAdminModel);

      if (!mounted) {
        return;
      }

      setState(() {
        _admin = updatedAdminModel;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your profile changes.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProductsPage()),
        (route) => false,
      );
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OrdersPage()),
        (route) => false,
      );
      return;
    }

    // index == 3: أنت بالفعل في ProfilePage.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _orange))
          : _admin == null
          ? _ProfileNotFoundView(onRetry: _loadProfile)
          : _buildProfileContent(_admin!),
      bottomNavigationBar: _ProfileBottomBar(
        selectedIndex: 3,
        onChanged: _onBottomNavigationChanged,
      ),
    );
  }

  Widget _buildProfileContent(AdminModel admin) {
    return SafeArea(
      child: Column(
        children: [
          _ProfileHeader(admin: admin),
          Expanded(
            child: RefreshIndicator(
              color: _orange,
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _ProfileSectionCard(
                    title: 'PERSONAL INFORMATION',
                    child: Column(
                      children: [
                        _ProfileInfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: _displayValue(admin.name),
                        ),
                        const SizedBox(height: 15),
                        _ProfileInfoRow(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email',
                          value: _displayValue(admin.email),
                        ),
                        const SizedBox(height: 15),
                        _ProfileInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: _displayValue(admin.phone),
                        ),
                        const SizedBox(height: 15),
                        _ProfileInfoRow(
                          icon: Icons.numbers_rounded,
                          label: 'National ID',
                          value: _displayValue(admin.nationalId),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProfileSectionCard(
                    title: 'BUSINESS INFORMATION',
                    child: Column(
                      children: [
                        _ProfileInfoRow(
                          label: 'Business Name',
                          value: _displayValue(admin.businessName),
                        ),
                        const SizedBox(height: 15),
                        _ProfileInfoRow(
                          label: 'Business Address',
                          value: _displayValue(admin.address),
                        ),
                        const SizedBox(height: 15),
                        _ProfileInfoRow(
                          label: 'Store Location',
                          value: _locationText(admin),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProfileSectionCard(
                    title: 'BUSINESS DOCUMENTS',
                    child: Column(
                      children: [
                        _DocumentStatusRow(
                          label: 'Commercial Register',
                          isUploaded: _hasValue(admin.commercialRegister),
                        ),
                        const SizedBox(height: 16),
                        _DocumentStatusRow(
                          label: 'Tax Card',
                          isUploaded: _hasValue(admin.taxCard),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String? value) {
    if (!_hasValue(value)) {
      return 'Not available';
    }

    return value!.trim();
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _locationText(AdminModel admin) {
    if (admin.latitude == null || admin.longitude == null) {
      return 'Not available';
    }

    return '${admin.latitude!.toStringAsFixed(5)}, '
        '${admin.longitude!.toStringAsFixed(5)}';
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.admin});

  final AdminModel admin;

  static const Color _orange = Color(0xFFFF821D);

  @override
  Widget build(BuildContext context) {
    final picture = admin.picture?.trim() ?? '';
    final hasPicture = picture.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      color: _orange,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileAvatar(
            imageUrl: hasPicture ? picture : null,
            name: admin.name,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _valueOrFallback(admin.name, 'Admin'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _valueOrFallback(admin.businessName, 'Merchant'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFE9D1),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _valueOrFallback(admin.email, 'No email available'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFE9D1),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'MERCHANT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _valueOrFallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    return value.trim();
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl == null
            ? _avatarFallback()
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _avatarFallback(),
              ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFFFFE0BE),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: Color(0xFFFF821D),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return 'AD';
    }

    if (words.length == 1) {
      final name = words.first;
      return name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF92939D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({this.icon, required this.label, required this.value});

  final IconData? icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: const Color(0xFF92939D)),
          const SizedBox(width: 9),
        ],
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF92939D),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF20212B),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentStatusRow extends StatelessWidget {
  const _DocumentStatusRow({required this.label, required this.isUploaded});

  final String label;
  final bool isUploaded;

  @override
  Widget build(BuildContext context) {
    final color = isUploaded
        ? const Color(0xFF13A978)
        : const Color(0xFF92939D);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF20212B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          isUploaded ? Icons.check_rounded : Icons.close_rounded,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 5),
        Text(
          isUploaded ? 'Uploaded' : 'Not uploaded',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProfileNotFoundView extends StatelessWidget {
  const _ProfileNotFoundView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 54,
              color: Color(0xFFFF821D),
            ),
            const SizedBox(height: 14),
            const Text(
              'Profile data is not available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF20212B),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign in again to load your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF92939D), fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF821D),
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

class _ProfileBottomBar extends StatelessWidget {
  const _ProfileBottomBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const Color _orange = Color(0xFFFF821D);
  static const Color _inactive = Color(0xFF9699A5);

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
                    color: selected ? _orange : _inactive,
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected ? _orange : _inactive,
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
                      color: _orange,
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
