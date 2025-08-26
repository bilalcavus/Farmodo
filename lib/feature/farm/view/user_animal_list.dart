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
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (farmController.animals.isEmpty) {
        return const FarmEmptyState();
      }
      
      return RefreshIndicator(
        onRefresh: () async {
          // await rewardController.getUserPurchasedRewards();
          await farmController.syncPurchasedAnimalsToFarm();
          await farmController.updateAnimalStatusesOverTime();
        },
        child: GridView.builder(
          padding: EdgeInsets.all(context.dynamicWidth(0.05)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.dynamicWidth(0.03),
            mainAxisSpacing: context.dynamicWidth(0.02),
            childAspectRatio: 0.65,
          ),
          itemCount: farmController.animals.length,
          itemBuilder: (context, index) {
            final animal = farmController.animals[index];
            return AnimalCard(
              animal: animal,
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AnimalDetailSheet(animal: animal),
              ),
            );
          },
        ),
      );
    });
  }
}


