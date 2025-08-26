part of 'farm_view.dart';

class _StatsCards extends StatelessWidget {
  _StatsCards();
  final FarmController farmController = Get.find<FarmController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
      height: context.dynamicHeight(0.12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            context,
            'Total',
            farmController.totalAnimals.toString(),
            Icons.pets,
          Colors.blue,
          ),
          _buildStatCard(
            context,
            'Favourite',
            farmController.totalFavorites.toString(),
            Icons.favorite,
            Colors.red,
          ),
          _buildStatCard(
            context,
            'Hunger',
            farmController.totalHungry.toString(),
            Icons.restaurant,
            Colors.orange,
          ),
          _buildStatCard(
            context,
            'Love',
            farmController.totalNeedingLove.toString(),
            Icons.favorite_border,
            Colors.pink,
          ),
          _buildStatCard(
            context,
            'Tired',
            farmController.totalTired.toString(),
            Icons.bedtime,
            Colors.purple,
          ),
          _buildStatCard(
            context,
            'Sick',
            farmController.totalSick.toString(),
            Icons.healing,
            Colors.red,
          ),
          _buildStatCard(
            context,
            'Happy',
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
              color: color
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


