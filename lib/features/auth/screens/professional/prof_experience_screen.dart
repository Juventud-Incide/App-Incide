import 'package:flutter/material.dart';

class ProfExperienceScreen extends StatefulWidget {
  const ProfExperienceScreen({super.key});

  @override
  State<ProfExperienceScreen> createState() => _ProfExperienceScreenState();
}

class _ProfExperienceScreenState extends State<ProfExperienceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Experiencia Profesional')),
      body: const Center(
        child: Text('Aquí puedes agregar tu experiencia profesional.'),
      ),
    );
  }
}
