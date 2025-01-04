class StudentModel {
  final String id;
  final String name;
  final String year;
  final String email;
  final String profilePic;
  final String phone;
  List? cases;
  StudentModel({
    required this.name,
    required this.id,
    required this.year,
    required this.email,
    required this.profilePic,
    required this.phone,
    this.cases,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      name: json['name'] ?? 'TEST',
      id: json['id'] ?? 'TEST',
      year: json['year'] ?? 'TEST',
      email: json['email'] ?? 'TEST',
      profilePic: json['profilePic'] ?? 'TEST',
      phone: json['phone'] ?? 'TEST',
      cases: json['cases'] ?? 'TEST',
    );
  }
}
