part of 'farm_view.dart';

class AnimalDetailSheet extends StatefulWidget {
  final FarmAnimal animal;

  const AnimalDetailSheet({
    super.key,
    required this.animal,
  });

  @override
  State<AnimalDetailSheet> createState() => _AnimalDetailSheetState();
}

class _AnimalDetailSheetState extends State<AnimalDetailSheet> {
  
  final TextEditingController _nicknameController = TextEditingController();
  final FarmController _farmController = Get.find<FarmController>();

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.animal.nickname;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.85),
      decoration: AppContainerStyles.secondaryContainer(context),
      child: Column(
        children: [
          context.dynamicHeight(0.015).height,
          SheetDivider(),
          context.dynamicHeight(0.01).height,
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.dynamicWidth(0.05)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SheetHeader(farmController: _farmController, widget: widget),
                  context.dynamicHeight(0.024).height,
                  AnimalStatusBar(farmController: _farmController, widget: widget,),
                  context.dynamicHeight(0.02).height,
                  NicknameSection(context: context, nicknameController: _nicknameController, farmController: _farmController, widget: widget),
                  context.dynamicHeight(0.024).height,
                  _buildActionButtons(),
                  context.dynamicHeight(0.007).height,
                  AnimalDetail(farmController: _farmController, widget: widget, context: context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: context.dynamicHeight(0.015)),
        
        Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: context.dynamicWidth(0.03),
          mainAxisSpacing: context.dynamicHeight(0.015),
          childAspectRatio: 1.9,
          children: [
            _buildActionButton(
              title: 'Feed',
              userXpCost: '-20',
              gainAnimalXp: '+4',
              color: Colors.orange,
              imagePath: 'assets/images/actions/feed.png',
              imageHeight: 50,
              isLoading:  _farmController.feedingAnimalId.value == widget.animal.id,
              onTap: () => _farmController.feedAnimal(widget.animal.id)
            
            ),
            _buildActionButton(
              title: 'Love',
              userXpCost: '-10',
              gainAnimalXp: '+4',
              imagePath: 'assets/images/actions/love.png',
              imageHeight: 50,
              color: Colors.pink,
              isLoading: _farmController.lovingAnimalId.value == widget.animal.id,
              onTap: () => _farmController.loveAnimal(widget.animal.id)
            ),
            _buildActionButton(
              title: 'Play',
              userXpCost: '-30',
              gainAnimalXp: '+4',
              imagePath: 'assets/images/actions/gaming2.png',
              imageHeight: 50,
              color: Colors.blue,
              isLoading: _farmController.playingAnimalId.value == widget.animal.id,
              onTap: () => _farmController.playWithAnimal(widget.animal.id)
            ),
            _buildActionButton(
              title: 'Heal',
              userXpCost: '-50',
              gainAnimalXp: '+4',
              imagePath: 'assets/images/actions/heal.png',
              imageHeight: 50,
              color: Colors.green,
              isLoading: _farmController.healingAnimalId.value == widget.animal.id,
              onTap: () => _farmController.healAnimal(widget.animal.id)
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildActionButton(
    {
      required String title,
      required String userXpCost,
      required String gainAnimalXp,
      required String imagePath,
      required double imageHeight,
    // IconData icon,
      required Color color,
      required bool isLoading,
      required VoidCallback onTap,
    }
    
  ) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.02)),
      decoration: BoxDecoration(
        color: isLoading ? Colors.grey.shade300 : color.withAlpha(15),
        borderRadius: BorderRadius.circular(15),
        
      ),
      child: Row(
        children: [isLoading
            ? ActionLoadingIcon(context: context, color: color)
            : Image.asset(imagePath, height: imageHeight),
    
          context.dynamicWidth(0.03).width,
    
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLoading ? Colors.grey.shade600 : color,
            ),
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    gainAnimalXp,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLoading ? Colors.grey.shade600 : color,
                    ),
                  ),
                  Icon(Icons.pets, color: color, size: context.dynamicHeight(0.02))
    
                ],
              ),
              Row(
                children: [
                  Text(
                    userXpCost,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLoading ? Colors.grey.shade600 : color,
                    ),
                  ),
                  Image.asset(
                    'assets/images/xp_star.png',
                    width: context.dynamicWidth(0.055),
                    height: context.dynamicHeight(0.04),
                    color: color,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).onTap(isLoading ? null : onTap);
  }
}

class NicknameSection extends StatelessWidget {
  const NicknameSection({
    super.key,
    required this.context,
    required TextEditingController nicknameController,
    required FarmController farmController,
    required this.widget,
  }) : _nicknameController = nicknameController, _farmController = farmController;

  final BuildContext context;
  final TextEditingController _nicknameController;
  final FarmController _farmController;
  final AnimalDetailSheet widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nickname',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: context.dynamicHeight(0.015)),
        
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: 'Enter nickname...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: context.dynamicWidth(0.03)),
            
            ElevatedButton(
              onPressed: () {
                if (_nicknameController.text.trim().isNotEmpty) {
                  _farmController.updateAnimalNickname(
                    widget.animal.id,
                    _nicknameController.text.trim(),
                  );
                  SnackMessages().showAnimalAction('Nickname updated!', Colors.green);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}


class AnimalDetail extends StatelessWidget {
  const AnimalDetail({
    super.key,
    required FarmController farmController,
    required this.widget,
    required this.context,
  }) : _farmController = farmController;

  final FarmController _farmController;
  final AnimalDetailSheet widget;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get the updated animal from the controller
      final updatedAnimal = _farmController.animals.firstWhere(
        (animal) => animal.id == widget.animal.id,
        orElse: () => widget.animal,
      );
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Info',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: context.dynamicHeight(0.015)),
          
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.04)),
            decoration: AppContainerStyles.primaryContainer(context),
            child: Column(
              children: [
                AnimalDetailInfo(label: 'Name', value: updatedAnimal.name, context: context),
                AnimalDetailInfo(label: 'Descriptipn', value: updatedAnimal.description, context: context),
                AnimalDetailInfo(label: 'Level', value: '${updatedAnimal.level}', context: context),
                AnimalDetailInfo(label: 'Experience Point ',value: '${updatedAnimal.experience} XP', context: context),
                AnimalDetailInfo(label: 'Acquire At', value:
                  '${updatedAnimal.acquiredAt.day}/${updatedAnimal.acquiredAt.month}/${updatedAnimal.acquiredAt.year}', context: context),
                AnimalDetailInfo(label: 'Last Feeding', value:
                  '${updatedAnimal.status.lastFed.hour}:${updatedAnimal.status.lastFed.minute.toString().padLeft(2, '0')}', context: context),
                AnimalDetailInfo(label: 'Last Loving', value:
                  '${updatedAnimal.status.lastLoved.hour}:${updatedAnimal.status.lastLoved.minute.toString().padLeft(2, '0')}', context: context),
                AnimalDetailInfo(label: 'Last Gaming', value:
                  '${updatedAnimal.status.lastPlayed.hour}:${updatedAnimal.status.lastPlayed.minute.toString().padLeft(2, '0')}', context: context),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class ActionLoadingIcon extends StatelessWidget {
  const ActionLoadingIcon({
    super.key,
    required this.context,
    required this.color,
  });

  final BuildContext context;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: context.dynamicWidth(0.05),
        height: context.dynamicHeight(0.025),
        child: CircularProgressIndicator(
          strokeWidth: context.dynamicWidth(0.005),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
  }
}


class AnimalDetailInfo extends StatelessWidget {
  const AnimalDetailInfo({
    super.key,
    required this.context,
    required this.label,
    required this.value,
  });

  final BuildContext context;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.005)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.dynamicWidth(0.25),
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
