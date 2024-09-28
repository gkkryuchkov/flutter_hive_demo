import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/animal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Регистрация адаптера
  Hive.registerAdapter(AnimalAdapter());

  // Открытие коробки
  await Hive.openBox<Animal>('animals');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final String title = 'Hive Animal Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: AnimalHomePage(title: title),
    );
  }
}

class AnimalHomePage extends StatefulWidget {
  final String title;

  const AnimalHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _AnimalHomePageState createState() => _AnimalHomePageState();
}

class _AnimalHomePageState extends State<AnimalHomePage> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей формы
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  Box<Animal> animalBox = Hive.box<Animal>('animals');

  @override
  void dispose() {
    _breedController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _addAnimal() {
    if (_formKey.currentState!.validate()) {
      final animal = Animal(
        breed: _breedController.text,
        name: _nameController.text,
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
      );

      animalBox.add(animal);

      _clearForm();
      setState(() {}); // Обновление интерфейса
    }
  }

  void _editAnimal(int index, Animal animal) {
    // Заполняем форму текущими данными животного
    _breedController.text = animal.breed;
    _nameController.text = animal.name;
    _ageController.text = animal.age.toString();
    _weightController.text = animal.weight.toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Редактировать животное'),
        content: Form(
          key: _formKey,
          child: _buildFormFields(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final updatedAnimal = Animal(
                  breed: _breedController.text,
                  name: _nameController.text,
                  age: int.parse(_ageController.text),
                  weight: double.parse(_weightController.text),
                );

                animalBox.putAt(index, updatedAnimal);
                Navigator.of(context).pop();
                _clearForm();
                setState(() {});
              }
            },
            child: const Text('Сохранить'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _deleteAnimal(int index) {
    animalBox.deleteAt(index);
    setState(() {}); // Обновление интерфейса
  }

  void _clearForm() {
    _breedController.clear();
    _nameController.clear();
    _ageController.clear();
    _weightController.clear();
  }

  Widget _buildFormFields() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            controller: _breedController,
            decoration: const InputDecoration(labelText: 'Порода'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите породу';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Кличка'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите кличку';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: 'Возраст'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите возраст';
              }
              if (int.tryParse(value) == null) {
                return 'Пожалуйста, введите целое число';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Вес (кг)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите вес';
              }
              if (double.tryParse(value) == null) {
                return 'Пожалуйста, введите число';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animals = animalBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Форма для добавления/редактирования животного
            Form(
              key: _formKey,
              child: _buildFormFields(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addAnimal,
              child: const Text('Добавить животное'),
            ),
            const SizedBox(height: 20),
            // Список животных
            Expanded(
              child: animals.isEmpty
                  ? const Center(child: Text('Список животных пуст'))
                  : ListView.builder(
                      itemCount: animals.length,
                      itemBuilder: (context, index) {
                        final animal = animals[index];
                        return Card(
                          child: ListTile(
                            title: Text(animal.name),
                            subtitle: Text(
                              'Порода: ${animal.breed}\n'
                              'Возраст: ${animal.age} лет\n'
                              'Вес: ${animal.weight} кг',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editAnimal(index, animal),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteAnimal(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
