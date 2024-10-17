class SearchModal {
  late String name, usl, logo;

  SearchModal({
    required this.name,
    required this.usl,
    required this.logo,
  });

  factory SearchModal.fromMap(Map m1) {
    return SearchModal(
      name: m1['name'],
      usl: m1['usl'],
      logo: m1['logo'],
    );
  }
}
