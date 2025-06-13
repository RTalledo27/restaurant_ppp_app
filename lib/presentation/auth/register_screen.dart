import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final isLoading = useState(false);
    final formValid = useState(false); // Nuevo estado para validación

    const primaryColor = Color(0xFFC45525);
    const fieldFill    = Colors.white;

    // Función para validar el formulario en tiempo real
    void validateForm() {
      final isValid = formKey.currentState?.validate() ?? false;
      formValid.value = isValid;
    }

    // Agregar listeners a los controladores para validación en tiempo real
    useEffect(() {
      void listener() => validateForm();

      nameCtrl.addListener(listener);
      idCtrl.addListener(listener);
      phoneCtrl.addListener(listener);
      emailCtrl.addListener(listener);
      passCtrl.addListener(listener);

      return () {
        nameCtrl.removeListener(listener);
        idCtrl.removeListener(listener);
        phoneCtrl.removeListener(listener);
        emailCtrl.removeListener(listener);
        passCtrl.removeListener(listener);
      };
    }, []);

    Future<void> submit() async {
      if (!formValid.value || isLoading.value) return;

      isLoading.value = true;

      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );

        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'fullName': nameCtrl.text.trim(),
          'idNumber': idCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user', // Aquí se asigna el rol
        });

        if (context.mounted) {
          await Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.homeUser,
                (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Error al registrar';

        switch (e.code) {
          case 'weak-password':
            errorMessage = 'La contraseña es muy débil';
            break;
          case 'email-already-in-use':
            errorMessage = 'El correo ya está registrado';
            break;
          case 'invalid-email':
            errorMessage = 'Correo inválido';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Operación no permitida';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
            break;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        isLoading.value = false;
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
                  onChanged: () => validateForm(), // Validación automática
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
                          if (!RegExp(r"^[0-9]{7,8}$").hasMatch(v)) {
                            return 'Debe ser numérico (7-08 dígitos)';
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
                        onPressed: formValid.value ? submit : null, // Usar formValid
                        isLoading: isLoading.value,
                      ),
                      const SizedBox(height: 15),
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