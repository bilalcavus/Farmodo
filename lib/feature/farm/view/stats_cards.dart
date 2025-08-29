part of 'farm_view.dart';

class _StatsCards extends StatelessWidget {
  _StatsCards();
  final FarmController farmController = Get.find<FarmController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      constraints: BoxConstraints(
        maxHeight: context.dynamicHeight(0.6),
        maxWidth: context.dynamicWidth(0.9),
      ),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: context.dynamicWidth(0.02),
        mainAxisSpacing: context.dynamicHeight(0.02),
        childAspectRatio: 0.9,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: context.dynamicHeight(0.04),
        ),
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
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


