class ProfileFormData {
  const ProfileFormData({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
  });

  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String activityLevel;
}
