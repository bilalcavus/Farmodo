part of 'farm_view.dart';
class _UserAnimalList extends StatelessWidget {
  const _UserAnimalList({
    required this.farmController,
    required this.context,
  });

  final FarmController farmController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (farmController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.02)),
              Text(
                'farm.loading_farm'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      
      if (farmController.animals.isEmpty) {
        return const FarmEmptyState();
      }
      
      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await farmController.syncPurchasedAnimalsToFarm();
          await farmController.updateAnimalStatusesOverTime();
        },
        child: GridView.builder(
          padding: EdgeInsets.all(context.dynamicWidth(0.06)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.dynamicWidth(0.04),
            mainAxisSpacing: context.dynamicWidth(0.04),
            childAspectRatio: 0.65,
          ),
          itemCount: farmController.animals.length,
          itemBuilder: (context, index) {
            final animal = farmController.animals[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimalCard(
                  animal: animal,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AnimalDetailSheet(animal: animal),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}


