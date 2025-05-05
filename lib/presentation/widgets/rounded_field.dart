import 'package:flutter/material.dart';

/// Campo de formulario redondeado con validación y estilo de error.
class RoundedField extends StatelessWidget {
  const RoundedField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.fill,
    this.visiblePassword = false,
    this.validator,
    this.suffix,
    this.colorHint = Colors.white
  });

  /// Controlador del texto.
  final TextEditingController controller;
  /// Texto de hint que aparece cuando está vacío.
  final String hint;
  /// Icono principal a la izquierda.
  final IconData icon;
  /// Color de relleno del campo.
  final Color fill;
  /// Indica si oculta el texto.
  final bool visiblePassword;
  /// Función de validación que devuelve un mensaje o null.
  final String? Function(String?)? validator;
  /// Widget secundario al final, p.ej. icono para mostrar/ocultar.
  final Widget? suffix;
  //COLOR DE HINT:
  final Color colorHint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: visiblePassword,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        hintText: hint,
        hintStyle: TextStyle(
            color: colorHint,
            fontFamily: 'Cinzel',
            fontSize: 10,
            fontWeight: FontWeight.w700,

        ),
        prefixIcon: Icon(icon, size: 20, color: Colors.black),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        // Estilo de error
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        // Estilo cuando el campo está enfocado y válido
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: fill.withOpacity(0.8), width: 2),
        ),
      ),
    );
  }
}
