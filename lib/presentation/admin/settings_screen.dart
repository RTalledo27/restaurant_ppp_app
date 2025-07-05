import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'Configuración',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuración del Sistema',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personaliza tu experiencia',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'En Desarrollo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.settings,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuraciones Disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // General Settings
          _buildSettingsGroup(
            'General',
            [
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                subtitle: 'Configurar alertas y notificaciones',
                color: Colors.blue,
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: 'Idioma',
                subtitle: 'Cambiar idioma de la aplicación',
                color: Colors.green,
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: 'Tema',
                subtitle: 'Modo claro u oscuro',
                color: Colors.purple,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Business Settings
          _buildSettingsGroup(
            'Negocio',
            [
              _buildSettingItem(
                icon: Icons.store_outlined,
                title: 'Información del Restaurante',
                subtitle: 'Nombre, logo, información de contacto',
                color: Colors.orange,
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingItem(
                icon: Icons.schedule_outlined,
                title: 'Horarios de Operación',
                subtitle: 'Configurar horarios de atención',
                color: Colors.teal,
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingItem(
                icon: Icons.local_shipping_outlined,
                title: 'Configuración de Delivery',
                subtitle: 'Zonas de entrega y tarifas',
                color: Colors.red,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // System Settings
          _buildSettingsGroup(
            'Sistema',
            [
              _buildSettingItem(
                icon: Icons.backup_outlined,
                title: 'Respaldo de Datos',
                subtitle: 'Configurar copias de seguridad',
                color: Colors.indigo,
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingItem(
                icon: Icons.security_outlined,
                title: 'Seguridad',
                subtitle: 'Configuraciones de seguridad',
                color: Colors.red,
                onTap: () => _showComingSoon(context),
              ),
              _buildSettingItem(
                icon: Icons.update_outlined,
                title: 'Actualizaciones',
                subtitle: 'Verificar actualizaciones disponibles',
                color: Colors.blue,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Coming Soon Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.construction,
                  size: 48,
                  color: Colors.amber[600],
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Próximamente!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estamos trabajando en estas configuraciones para mejorar tu experiencia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.construction, color: Colors.amber[600]),
            const SizedBox(width: 8),
            const Text('Próximamente'),
          ],
        ),
        content: const Text(
          'Esta funcionalidad estará disponible en una próxima actualización.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}