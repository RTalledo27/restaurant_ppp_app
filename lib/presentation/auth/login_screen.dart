import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/logo/rokos_logo.dart';
import '../widgets/rounded_field.dart';
import '../widgets/primary_button.dart';
import '../routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = useTextEditingController();
    final passCtrl = useTextEditingController();
    final hidePass = useState(true);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final lastAttemptTime = useState<DateTime?>(null);
    final attemptCount = useState(0);
    final isCooldown = useState(false);
    final firestore = FirebaseFirestore.instance;

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      // Verificar enfriamiento
      if (isCooldown.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor espera antes de intentar nuevamente')),
        );
        return;
      }

      // Verificar límite de intentos
      if (attemptCount.value >= 3) {
        isCooldown.value = true;
        Future.delayed(
            const Duration(minutes: 1), () => isCooldown.value = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Demasiados intentos. Por favor espera 1 minuto')),
        );
        return;
      }

      isLoading.value = true;
      attemptCount.value++;

      try {
        // Autenticar usuario
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );

        // Obtener rol del usuario desde Firestore
        final userDoc = await firestore.collection('users').doc(userCredential.user!.uid).get();
        final userRole = userDoc.data()?['role'] as String? ?? 'user';

        // Reiniciar contadores al éxito
        attemptCount.value = 0;
        lastAttemptTime.value = null;
        isCooldown.value = false;

        // Navegar a la pantalla correspondiente según el rol
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            userRole == 'admin' ? Routes.homeAdmin : Routes.homeUser,
                (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        String errorMessage = 'Error al iniciar sesión';

        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Correo electrónico inválido';
            break;
          case 'user-disabled':
            errorMessage = 'Usuario deshabilitado';
            break;
          case 'user-not-found':
            errorMessage = 'Usuario no encontrado';
            break;
          case 'wrong-password':
            errorMessage = 'Contraseña incorrecta';
            break;
          case 'too-many-requests':
            errorMessage = 'Demasiados intentos. Intente más tarde';
            isCooldown.value = true;
            Future.delayed(
                const Duration(minutes: 1), () => isCooldown.value = false);
            break;
          case 'network-request-failed':
            errorMessage = 'Error de red. Verifica tu conexión a internet';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Operación no permitida';
            break;
          case 'invalid-credential':
            errorMessage = 'Credenciales inválidas';
            break;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e, stack) {
        isLoading.value = false;
        debugPrint('Error inesperado: $e');
        debugPrint('Stack trace: $stack');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error interno: ${e.toString()}')),
          );
        }
      }
    }

    const primary = Color(0xFFC45525);
    const fieldFill = Color(0xFFE2AD8C);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RokosLogo(
                  cutColor: Color(0xFFFFFFFF),
                  rTextColor: Color(0xFFC45225),
                  rokosTextColor: Color(0xFFC45225),
                ),
                const SizedBox(height: 0),
                const Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 20,
                    color: Color(0xFFC45225),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      RoundedField(
                        controller: emailCtrl,
                        hint: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        fill: fieldFill,
                        validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Correo inválido' : null,
                      ),
                      const SizedBox(height: 14),
                      RoundedField(
                        controller: passCtrl,
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        fill: fieldFill,
                        visiblePassword: hidePass.value,
                        suffix: IconButton(
                          icon: Icon(
                            hidePass.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 18,
                          ),
                          onPressed: () => hidePass.value = !hidePass.value,
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 26),
                      PrimaryButton(
                        text: 'INICIAR SESIÓN',
                        onPressed: isLoading.value || isCooldown.value ? null : submit,
                        width: 216,
                        isLoading: isLoading.value,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'REGISTRARSE',
                        width: 216,
                        onPressed: isLoading.value
                            ? null
                            : () => Navigator.pushNamed(context, Routes.register),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: isLoading.value
                            ? null
                            : () => Navigator.pushNamed(context, Routes.recover),
                        child: const Text(
                          'RECUPERAR CONTRASEÑA',
                          style: TextStyle(
                            color: primary,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFC45525),
                            decorationThickness: 1.5,
                          ),
                        ),
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