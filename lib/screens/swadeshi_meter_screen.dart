import 'package:flutter/material.dart';
import 'package:expense_manager/utils/theme.dart';
import 'dart:math' as math;

class SwadeshiMeterScreen extends StatefulWidget {
  const SwadeshiMeterScreen({super.key});

  @override
  State<SwadeshiMeterScreen> createState() => _SwadeshiMeterScreenState();
}

class _SwadeshiMeterScreenState extends State<SwadeshiMeterScreen>
    with TickerProviderStateMixin {
  late AnimationController _gaugeController;
  late AnimationController _sparklineController;
  late Animation<double> _gaugeAnimation;
  late Animation<double> _sparklineAnimation;

  final double swadeshiScore = 72.0;
  final double indianSpend = 12450.0;
  final double foreignSpend = 4800.0;
  final int totalTransactions = 46;

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _sparklineController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _gaugeAnimation = Tween<double>(begin: 0, end: swadeshiScore / 100)
        .animate(CurvedAnimation(parent: _gaugeController, curve: Curves.easeOutCubic));
    _sparklineAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _sparklineController, curve: Curves.easeOut));

    _gaugeController.forward();
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    _sparklineController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score < 40) return AppColors.error;
    if (score < 70) return Colors.amber;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSpend = indianSpend + foreignSpend;
    final indianPercentage = (indianSpend / totalSpend * 100).round();
    final foreignPercentage = (foreignSpend / totalSpend * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(theme),
              const SizedBox(height: 12),

              // Swadeshi Score Card
              _buildSwadeshiCard(theme),
              const SizedBox(height: 24),

              // Stacked Bar Chart
              _buildStackedBar(theme, indianPercentage, foreignPercentage),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(theme),
              const SizedBox(height: 24),

              // Merchant List
              _buildMerchantList(theme),
              const SizedBox(height: 24), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              'FinTrix',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSwadeshiCard(ThemeData theme) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: _buildSwadeshiGauge(theme),
          ),
          const SizedBox(height: 16),
          _buildNumericSummary(theme),
        ],
      ),
    );
  }

  Widget _buildSwadeshiGauge(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showTrendTooltip(theme),
      child: AnimatedBuilder(
        animation: _gaugeAnimation,
        builder: (context, child) {
          return SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              size: const Size(180, 180),
              painter: SwadeshiGaugePainter(
                progress: _gaugeAnimation.value,
                score: swadeshiScore,
                color: _getScoreColor(swadeshiScore),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumericSummary(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${swadeshiScore.toInt()}%',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getScoreColor(swadeshiScore),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Swadeshi Score\n(last 30 days)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoChip('Indian Spend', '₹${indianSpend.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
        const SizedBox(height: 8),
        _buildInfoChip('Foreign/Imported', '₹${foreignSpend.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
        const SizedBox(height: 8),
        _buildInfoChip('Total Transactions', '$totalTransactions'),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedBar(ThemeData theme, int indianPercentage, int foreignPercentage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.background,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: indianPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$indianPercentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: foreignPercentage,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$foreignPercentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showLocalAlternatives(theme),
              icon: const Icon(Icons.store, size: 18),
              label: const Text('See Local Alternatives'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCalculationModal(theme),
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('How it\'s calculated'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
                side: BorderSide(color: AppColors.primaryLight),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantList(ThemeData theme) {
    final indianMerchants = [
      {'name': 'Campus Canteen', 'amount': 3200, 'category': 'Food & Dining'},
      {'name': 'Local Bookstore', 'amount': 2200, 'category': 'Education & Learning'},
      {'name': 'Indian Pharmacy', 'amount': 1800, 'category': 'Healthcare'},
    ];

    final foreignMerchants = [
      {'name': 'Imported Shoes Co.', 'amount': 1600, 'category': 'Fashion & Apparel'},
      {'name': 'Global Electronics', 'amount': 3200, 'category': 'Electronics'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Origin',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Indian Origin Section
          _buildOriginSection(
            '🇮🇳 Indian Origin',
            indianMerchants,
            AppColors.success,
            theme,
          ),
          const SizedBox(height: 16),

          // Foreign Origin Section
          _buildOriginSection(
            '🌐 Foreign/Imported',
            foreignMerchants,
            Colors.orange,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildOriginSection(String title, List<Map<String, dynamic>> merchants, Color accentColor, ThemeData theme) {
    final totalAmount = merchants.fold<double>(0, (sum, merchant) => sum + merchant['amount']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: merchants.map((merchant) => _buildMerchantRow(merchant, theme, accentColor)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantRow(Map<String, dynamic> merchant, ThemeData theme, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  merchant['category'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${merchant['amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showTrendTooltip(ThemeData theme) {
    _sparklineController.forward();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('3-Month Trend'),
        content: SizedBox(
          width: 200,
          height: 100,
          child: AnimatedBuilder(
            animation: _sparklineAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: SparklinePainter(_sparklineAnimation.value),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLocalAlternatives(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local Alternatives',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Switch to Indian brands and save money',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Alternatives List
              _buildAlternativeCard(
                'Nike → Bata',
                'Fashion & Apparel',
                'Save ₹800/month',
                'Quality Indian footwear with better pricing',
                Icons.shopping_bag,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildAlternativeCard(
                'McDonald\'s → Haldiram\'s',
                'Food & Dining',
                'Save ₹400/month',
                'Authentic Indian flavors at great prices',
                Icons.restaurant,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildAlternativeCard(
                'Starbucks → Local Coffee',
                'Beverages',
                'Save ₹600/month',
                'Support local coffee culture and save',
                Icons.local_cafe,
                Colors.brown,
              ),

              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Explore Alternatives'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeCard(
      String product,
      String category,
      String savings,
      String description,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                savings,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCalculationModal(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How the Swadeshi Score works'),
        content: const Text(
          'Swadeshi Score = (Sum of spend at Indian-origin merchants ÷ Total spend) × 100\n\n'
              'Merchants are labeled by origin via GST/vendor data + user tagging. '
              'Bonus weighting for made-in-India manufacturing purchases.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class SwadeshiGaugePainter extends CustomPainter {
  final double progress;
  final double score;
  final Color color;

  SwadeshiGaugePainter({
    required this.progress,
    required this.score,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.orange, Colors.white, Colors.green],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Score text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${score.toInt()}%',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SparklinePainter extends CustomPainter {
  final double animationValue;

  SparklinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final points = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.72];

    for (int i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height * (1 - points[i] * animationValue);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}