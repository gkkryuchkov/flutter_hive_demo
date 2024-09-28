import 'package:hive/hive.dart';

part 'animal.g.dart';

@HiveType(typeId: 1)
class Animal extends HiveObject {
  @HiveField(0)
  String breed;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  double weight;

  Animal({
    required this.breed,
    required this.name,
    required this.age,
    required this.weight,
  });
}
