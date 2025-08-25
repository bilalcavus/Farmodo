part of 'farm_view.dart';

class _StatsCards extends StatelessWidget {
  _StatsCards({
    required this.farmController
  });
  FarmController farmController = getIt<FarmController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
      height: context.dynamicHeight(0.12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            context,
            'Toplam',
            farmController.totalAnimals.toString(),
            Icons.pets,
          Colors.blue,
          ),
          _buildStatCard(
            context,
            'Favori',
            farmController.totalFavorites.toString(),
            Icons.favorite,
            Colors.red,
          ),
          _buildStatCard(
            context,
            'Aç',
            farmController.totalHungry.toString(),
            Icons.restaurant,
            Colors.orange,
          ),
          _buildStatCard(
            context,
            'Sevgi',
            farmController.totalNeedingLove.toString(),
            Icons.favorite_border,
            Colors.pink,
          ),
          _buildStatCard(
            context,
            'Yorgun',
            farmController.totalTired.toString(),
            Icons.bedtime,
            Colors.purple,
          ),
          _buildStatCard(
            context,
            'Hasta',
            farmController.totalSick.toString(),
            Icons.healing,
            Colors.red,
          ),
          _buildStatCard(
            context,
            'Mutlu',
            farmController.totalHappy.toString(),
            Icons.sentiment_satisfied,
            Colors.green,
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: context.dynamicWidth(0.22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: context.dynamicHeight(0.03),
          ),
          SizedBox(height: context.dynamicHeight(0.005)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


