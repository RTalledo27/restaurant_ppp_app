import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_providers.dart';
import '../../domain/entities/order.dart';

// Providers para filtros
final reportDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
final reportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.all);

enum ReportPeriod { all, today, week, month }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderListStreamProvider);
    final selectedPeriod = ref.watch(reportPeriodProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, ref),
      body: ordersAsync.when(
        data: (orders) {
          final filteredOrders = _filterOrdersByPeriod(orders, selectedPeriod);
          final analytics = _calculateRealAnalytics(filteredOrders);

          // ✅ Envolvemos todo en un SingleChildScrollView para evitar overflow
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildPeriodFilter(context, ref),
                _buildTabBar(),
                // ✅ Usamos Container con altura específica para TabBarView
                SizedBox(
                  height: MediaQuery.of(context).size.height - 280, // Altura dinámica
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(analytics, filteredOrders),
                      _buildDetailedTab(filteredOrders),
                      _buildTimeAnalysisTab(filteredOrders),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(),
        error: (e, _) => _buildErrorState(e.toString()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
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
        'Reportes de Pedidos',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue[600]),
            onPressed: () {
              ref.invalidate(orderListStreamProvider);
            },
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(reportPeriodProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Agregado para evitar overflow
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.blue[600]),
              const SizedBox(width: 12),
              const Text(
                'Período de Análisis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ Usamos Wrap en lugar de Row para evitar overflow horizontal
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPeriodButton('Todos', ReportPeriod.all, selectedPeriod, ref),
              _buildPeriodButton('Hoy', ReportPeriod.today, selectedPeriod, ref),
              _buildPeriodButton('7 Días', ReportPeriod.week, selectedPeriod, ref),
              _buildPeriodButton('30 Días', ReportPeriod.month, selectedPeriod, ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, ReportPeriod period, ReportPeriod selected, WidgetRef ref) {
    final isSelected = period == selected;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[600] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: () {
          ref.read(reportPeriodProvider.notifier).state = period;
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // ✅ Padding ajustado
          minimumSize: Size.zero,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), // ✅ Tamaño reducido
        tabs: const [
          Tab(text: 'Resumen'),
          Tab(text: 'Pedidos'),
          Tab(text: 'Análisis'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(RealOrderAnalytics analytics, List<Order> orders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Métricas principales
          _buildMetricsGrid(analytics),

          const SizedBox(height: 20), // ✅ Espaciado reducido

          // Estado de pedidos
          _buildStatusBreakdown(analytics),

          const SizedBox(height: 20),

          // Ingresos por estado
          _buildRevenueBreakdown(analytics),

          const SizedBox(height: 20),

          // Estadísticas adicionales
          _buildAdditionalStats(analytics),

          const SizedBox(height: 20), // ✅ Espacio final para scroll
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(RealOrderAnalytics analytics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3, // ✅ Ratio ajustado para menos altura
      children: [
        _buildMetricCard(
          'Total Pedidos',
          analytics.totalOrders.toString(),
          Icons.receipt_long,
          Colors.blue,
        ),
        _buildMetricCard(
          'Ingresos Totales',
          '\$${analytics.totalRevenue.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildMetricCard(
          'Promedio/Pedido',
          '\$${analytics.averageOrderValue.toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildMetricCard(
          'Tasa Éxito',
          '${analytics.completionRate.toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ Padding reducido
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ Distribución uniforme
        children: [
          Container(
            padding: const EdgeInsets.all(6), // ✅ Padding reducido
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18), // ✅ Icono más pequeño
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18, // ✅ Tamaño reducido
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11, // ✅ Tamaño reducido
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(RealOrderAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(16), // ✅ Padding reducido
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado de Pedidos',
            style: TextStyle(
              fontSize: 16, // ✅ Tamaño reducido
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusItem('Pendientes', analytics.pendingOrders, analytics.totalOrders, Colors.orange),
          _buildStatusItem('En Progreso', analytics.inProgressOrders, analytics.totalOrders, Colors.blue),
          _buildStatusItem('Completados', analytics.completedOrders, analytics.totalOrders, Colors.green),
          _buildStatusItem('Cancelados', analytics.cancelledOrders, analytics.totalOrders, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // ✅ Padding reducido
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10, // ✅ Tamaño reducido
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13, // ✅ Tamaño reducido
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 13, // ✅ Tamaño reducido
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${(percentage * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 11, // ✅ Tamaño reducido
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4, // ✅ Altura reducida
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown(RealOrderAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análisis de Ingresos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildRevenueItem('Ingresos Confirmados', analytics.completedRevenue, Colors.green),
          _buildRevenueItem('Ingresos Pendientes', analytics.pendingRevenue, Colors.orange),
          _buildRevenueItem('Ingresos en Proceso', analytics.inProgressRevenue, Colors.blue),
          const Divider(height: 24), // ✅ Altura reducida
          Row(
            children: [
              const Text(
                'Total General:',
                style: TextStyle(
                  fontSize: 15, // ✅ Tamaño reducido
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '\$${analytics.totalRevenue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16, // ✅ Tamaño reducido
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // ✅ Padding reducido
      child: Row(
        children: [
          Container(
            width: 6, // ✅ Tamaño reducido
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13, // ✅ Tamaño reducido
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13, // ✅ Tamaño reducido
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalStats(RealOrderAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas Adicionales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Pedido más alto:', '\$${analytics.highestOrderValue.toStringAsFixed(2)}'),
          _buildStatRow('Pedido más bajo:', '\$${analytics.lowestOrderValue.toStringAsFixed(2)}'),
          _buildStatRow('Mediana de pedidos:', '\$${analytics.medianOrderValue.toStringAsFixed(2)}'),
          if (analytics.firstOrderDate != null)
            _buildStatRow('Primer pedido:', _formatDate(analytics.firstOrderDate!)),
          if (analytics.lastOrderDate != null)
            _buildStatRow('Último pedido:', _formatDate(analytics.lastOrderDate!)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // ✅ Padding reducido
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13, // ✅ Tamaño reducido
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13, // ✅ Tamaño reducido
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTab(List<Order> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState('No hay pedidos en este período');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, index);
      },
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 10), // ✅ Margen reducido
      child: Container(
        padding: const EdgeInsets.all(14), // ✅ Padding reducido
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // ✅ Padding reducido
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 11, // ✅ Tamaño reducido
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15, // ✅ Tamaño reducido
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6), // ✅ Espaciado reducido
            Text(
              'Pedido #${order.id}',
              style: const TextStyle(
                fontSize: 15, // ✅ Tamaño reducido
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]), // ✅ Icono más pequeño
                const SizedBox(width: 4),
                Text(
                  order.createdAt != null
                      ? _formatDateTime(order.createdAt!)
                      : 'Fecha no disponible',
                  style: TextStyle(
                    fontSize: 12, // ✅ Tamaño reducido
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAnalysisTab(List<Order> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState('No hay datos para análisis temporal');
    }

    final timeAnalysis = _analyzeOrdersByTime(orders);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDailyAnalysis(timeAnalysis.dailyOrders),
          const SizedBox(height: 20), // ✅ Espaciado reducido
          _buildHourlyAnalysis(timeAnalysis.hourlyOrders),
          const SizedBox(height: 20),
          _buildWeekdayAnalysis(timeAnalysis.weekdayOrders),
          const SizedBox(height: 20), // ✅ Espacio final
        ],
      ),
    );
  }

  Widget _buildDailyAnalysis(Map<String, int> dailyOrders) {
    final sortedDays = dailyOrders.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(16), // ✅ Padding reducido
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pedidos por Día',
            style: TextStyle(
              fontSize: 16, // ✅ Tamaño reducido
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedDays.take(10).map((entry) => _buildTimeAnalysisItem( // ✅ Limitamos a 10 items
            entry.key,
            entry.value,
            sortedDays.map((e) => e.value).reduce((a, b) => a > b ? a : b),
            Colors.blue,
          )),
        ],
      ),
    );
  }

  Widget _buildHourlyAnalysis(Map<int, int> hourlyOrders) {
    final sortedHours = hourlyOrders.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pedidos por Hora',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedHours.map((entry) => _buildTimeAnalysisItem(
            '${entry.key}:00',
            entry.value,
            sortedHours.map((e) => e.value).reduce((a, b) => a > b ? a : b),
            Colors.green,
          )),
        ],
      ),
    );
  }

  Widget _buildWeekdayAnalysis(Map<String, int> weekdayOrders) {
    final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final maxValue = weekdayOrders.values.isNotEmpty
        ? weekdayOrders.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pedidos por Día de la Semana',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...weekdays.map((day) => _buildTimeAnalysisItem(
            day,
            weekdayOrders[day] ?? 0,
            maxValue,
            Colors.purple,
          )),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysisItem(String label, int count, int maxValue, Color color) {
    final percentage = maxValue > 0 ? count / maxValue : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // ✅ Padding reducido
      child: Row(
        children: [
          SizedBox(
            width: 70, // ✅ Ancho reducido
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12, // ✅ Tamaño reducido
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 6, // ✅ Altura reducida
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 25, // ✅ Ancho reducido
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12, // ✅ Tamaño reducido
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, // ✅ Tamaño reducido
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 50, // ✅ Tamaño reducido
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 16, // ✅ Tamaño reducido
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando reportes...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar reportes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods con null safety (sin cambios)
  List<Order> _filterOrdersByPeriod(List<Order> orders, ReportPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case ReportPeriod.today:
        final today = DateTime(now.year, now.month, now.day);
        return orders.where((order) =>
        order.createdAt != null &&
            order.createdAt!.isAfter(today) &&
            order.createdAt!.isBefore(today.add(const Duration(days: 1)))
        ).toList();

      case ReportPeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return orders.where((order) =>
        order.createdAt != null && order.createdAt!.isAfter(weekAgo)
        ).toList();

      case ReportPeriod.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        return orders.where((order) =>
        order.createdAt != null && order.createdAt!.isAfter(monthAgo)
        ).toList();

      case ReportPeriod.all:
      default:
        return orders;
    }
  }

  RealOrderAnalytics _calculateRealAnalytics(List<Order> orders) {
    if (orders.isEmpty) {
      return RealOrderAnalytics.empty();
    }

    final total = orders.length;
    final pending = orders.where((o) => o.status == 'pending').length;
    final inProgress = orders.where((o) => o.status == 'in_progress').length;
    final completed = orders.where((o) => o.status == 'completed').length;
    final cancelled = orders.where((o) => o.status == 'cancelled').length;

    final completedRevenue = orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.total);

    final pendingRevenue = orders
        .where((o) => o.status == 'pending')
        .fold(0.0, (sum, order) => sum + order.total);

    final inProgressRevenue = orders
        .where((o) => o.status == 'in_progress')
        .fold(0.0, (sum, order) => sum + order.total);

    final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.total);

    final orderValues = orders.map((o) => o.total).toList()..sort();
    final averageOrderValue = totalRevenue / total;
    final medianOrderValue = orderValues.length % 2 == 0
        ? (orderValues[orderValues.length ~/ 2 - 1] + orderValues[orderValues.length ~/ 2]) / 2
        : orderValues[orderValues.length ~/ 2];

    final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

    final ordersWithDates = orders.where((o) => o.createdAt != null).toList();
    final sortedByDate = ordersWithDates.toList()
      ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    return RealOrderAnalytics(
      totalOrders: total,
      pendingOrders: pending,
      inProgressOrders: inProgress,
      completedOrders: completed,
      cancelledOrders: cancelled,
      totalRevenue: totalRevenue,
      completedRevenue: completedRevenue,
      pendingRevenue: pendingRevenue,
      inProgressRevenue: inProgressRevenue,
      averageOrderValue: averageOrderValue,
      medianOrderValue: medianOrderValue,
      highestOrderValue: orderValues.isNotEmpty ? orderValues.last : 0.0,
      lowestOrderValue: orderValues.isNotEmpty ? orderValues.first : 0.0,
      completionRate: completionRate,
      firstOrderDate: sortedByDate.isNotEmpty ? sortedByDate.first.createdAt : null,
      lastOrderDate: sortedByDate.isNotEmpty ? sortedByDate.last.createdAt : null,
    );
  }

  TimeAnalysis _analyzeOrdersByTime(List<Order> orders) {
    final Map<String, int> dailyOrders = {};
    final Map<int, int> hourlyOrders = {};
    final Map<String, int> weekdayOrders = {};

    final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

    for (final order in orders) {
      if (order.createdAt == null) continue;

      final dayKey = _formatDate(order.createdAt!);
      dailyOrders[dayKey] = (dailyOrders[dayKey] ?? 0) + 1;

      final hour = order.createdAt!.hour;
      hourlyOrders[hour] = (hourlyOrders[hour] ?? 0) + 1;

      final weekday = weekdays[order.createdAt!.weekday - 1];
      weekdayOrders[weekday] = (weekdayOrders[weekday] ?? 0) + 1;
    }

    return TimeAnalysis(
      dailyOrders: dailyOrders,
      hourlyOrders: hourlyOrders,
      weekdayOrders: weekdayOrders,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'in_progress': return 'En Progreso';
      case 'completed': return 'Completado';
      case 'cancelled': return 'Cancelado';
      default: return 'Desconocido';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Data classes (sin cambios)
class RealOrderAnalytics {
  final int totalOrders;
  final int pendingOrders;
  final int inProgressOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double completedRevenue;
  final double pendingRevenue;
  final double inProgressRevenue;
  final double averageOrderValue;
  final double medianOrderValue;
  final double highestOrderValue;
  final double lowestOrderValue;
  final double completionRate;
  final DateTime? firstOrderDate;
  final DateTime? lastOrderDate;

  RealOrderAnalytics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.inProgressOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.completedRevenue,
    required this.pendingRevenue,
    required this.inProgressRevenue,
    required this.averageOrderValue,
    required this.medianOrderValue,
    required this.highestOrderValue,
    required this.lowestOrderValue,
    required this.completionRate,
    this.firstOrderDate,
    this.lastOrderDate,
  });

  factory RealOrderAnalytics.empty() {
    return RealOrderAnalytics(
      totalOrders: 0,
      pendingOrders: 0,
      inProgressOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
      totalRevenue: 0.0,
      completedRevenue: 0.0,
      pendingRevenue: 0.0,
      inProgressRevenue: 0.0,
      averageOrderValue: 0.0,
      medianOrderValue: 0.0,
      highestOrderValue: 0.0,
      lowestOrderValue: 0.0,
      completionRate: 0.0,
    );
  }
}

class TimeAnalysis {
  final Map<String, int> dailyOrders;
  final Map<int, int> hourlyOrders;
  final Map<String, int> weekdayOrders;

  TimeAnalysis({
    required this.dailyOrders,
    required this.hourlyOrders,
    required this.weekdayOrders,
  });
}
