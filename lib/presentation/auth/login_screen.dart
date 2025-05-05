import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../widgets/logo/rokos_logo.dart';
import '../widgets/rounded_field.dart';
import '../widgets/primary_button.dart';
import '../routes/app_routes.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── controladores & clave de formulario ───────────────────────────────
    final emailCtrl = useTextEditingController();
    final passCtrl  = useTextEditingController();
    final hidePass  = useState(true);
    final formKey   = useMemoized(() => GlobalKey<FormState>());

    void submit() {
      if (formKey.currentState!.validate()) {
        // conexion con firebase, luego
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Validando credenciales…')),
        );
      }
    }

    const primary   = Color(0xFFC45525);
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
                const Text(                          // título
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
                      PrimaryButton(text: 'INICIAR SESIÓN', onPressed: submit, width: 216,),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'REGISTRARSE',
                        width: 216,
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.register),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.recover),
                        child: const Text(
                          'RECUPERAR CONTRASEÑA',

                          style: TextStyle(
                            color: primary,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFC45525),
                            decorationThickness: 1.5,

                          )

                          ,
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
