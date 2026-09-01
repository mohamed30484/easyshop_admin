class AdminEntity {
  const AdminEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String businessName;
}
