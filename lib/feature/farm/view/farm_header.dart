part of 'farm_view.dart';

class _FarmHeader extends StatelessWidget {
  const _FarmHeader({
    required this.context,
    required this.farmController,
  });

  final BuildContext context;
  final FarmController farmController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.05),
        vertical: context.dynamicWidth(0.03),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.025)),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.pets,
              color: Colors.green,
              size: context.dynamicHeight(0.03),
            ),
          ),
          
          context.dynamicWidth(0.04).width,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Çiftliğim',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${farmController.totalAnimals} hayvan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Son güncelleme: ${farmController.lastUpdateTimeString}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
          RefreshButton(
            farmController: farmController,
            onTap: () async => await farmController.syncPurchasedAnimalsToFarm(),
            icon: Icons.refresh,
            toolTip: 'Yenile',
          ),
          RefreshButton(
            farmController: farmController,
            icon: Icons.update,
            toolTip: 'Hayvan Durumlarını Güncelle',
            onTap:  () async {
              await farmController.updateAnimalStatusesOverTime();
              Get.snackbar(
                'Güncellendi!',
                'Hayvan durumları güncellendi',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          )
        ],
      ),
    );
  }
}

