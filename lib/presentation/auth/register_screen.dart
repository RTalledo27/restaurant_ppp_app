import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../widgets/logo/rokos_logo.dart';
import '../widgets/rounded_field.dart';
import '../widgets/primary_button.dart';
import '../routes/app_routes.dart';

class RegisterScreen extends HookWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl  = useTextEditingController();
    final idCtrl    = useTextEditingController();
    final phoneCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final passCtrl  = useTextEditingController();
    final hidePass  = useState(true);
    final formKey   = useMemoized(() => GlobalKey<FormState>());

    const primaryColor = Color(0xFFC45525);
    const fieldFill    = Colors.white;

    void submit() {
      if (formKey.currentState!.validate()) {
        // TODO: implementar lógica de registro
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrando usuario…')),
        );
      }
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RokosLogo(
                  cutColor: primaryColor,
                  rTextColor: Colors.white,
                  rokosTextColor: Colors.white,
                ),
                const SizedBox(height: 1),
                const Text(
                  'REGISTRARSE',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      // Nombre completo
                      RoundedField(
                        controller: nameCtrl,
                        hint: 'Nombre completo',
                        icon: Icons.person_outline,
                        fill: fieldFill,
                        colorHint: Color(0xFFC45225),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Campo obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      // Número de identidad
                      RoundedField(
                        controller: idCtrl,
                        hint: 'Número de identidad',
                        icon: Icons.credit_card_outlined,
                        fill: fieldFill,
                        colorHint: Color(0xFFC45225),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          if (!RegExp(r"^[0-9]{6,10}$").hasMatch(v)) {
                            return 'Debe ser numérico';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      // Celular
                      RoundedField(
                        controller: phoneCtrl,
                        hint: '+51 Celular',
                        icon: Icons.phone_android_outlined,
                        fill: fieldFill,
                        colorHint: Color(0xFFC45225),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          if (!RegExp(r"^\+?[0-9]{7,15}$").hasMatch(v)) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      // Correo electrónico
                      RoundedField(
                        controller: emailCtrl,
                        hint: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        fill: fieldFill,
                        colorHint: Color(0xFFC45225),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(v)) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      // Contraseña
                      RoundedField(
                        controller: passCtrl,
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        fill: fieldFill,
                        visiblePassword: hidePass.value,
                        colorHint: Color(0xFFC45225),
                        suffix: IconButton(
                          icon: Icon(
                            hidePass.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black54,
                            size: 18,
                          ),
                          onPressed: () => hidePass.value = !hidePass.value,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      PrimaryButton(
                        text: 'REGISTRARSE',
                        width: 216,
                        colorButton: Color(0xFFE2AD8C),
                        onPressed: submit,
                      ),
                      const SizedBox(height: 15,),
                      PrimaryButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, Routes.login),
                          text: 'INICIAR SESIÓN',
                          width: 216,
                          colorButton: Colors.white,
                          textColor: Color(0xFFC45225),
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
