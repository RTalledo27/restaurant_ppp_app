import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../widgets/logo/rokos_logo.dart';
import '../widgets/rounded_field.dart';
import '../widgets/primary_button.dart';

class RecoverScreen extends HookWidget {
  const RecoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controlador de email y clave de formulario
    final emailCtrl = useTextEditingController();
    final formKey   = useMemoized(() => GlobalKey<FormState>());

    // Colores
    const primary   = Color(0xFFC45525);
    const fieldFill = Color(0xFFE7B092);

    void sendCode() {
      if (formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enviando código…')),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo adaptado a fondo blanco
                const RokosLogo(
                  cutColor: Colors.white,
                  rTextColor: primary,
                  rokosTextColor: primary,
                ),
                const SizedBox(height:0),

                // Título
                const Text(
                  'RECUPERAR CUENTA',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 20,
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 0.1),

                // Formulario para capturar email
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      // Correo electrónico
                      RoundedField(
                        controller: emailCtrl,
                        hint: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        fill: fieldFill,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+\$')
                              .hasMatch(v)) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Botón de envío
                      PrimaryButton(
                        text: 'ENVIAR CÓDIGO',
                        width: 256,
                        onPressed: sendCode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
