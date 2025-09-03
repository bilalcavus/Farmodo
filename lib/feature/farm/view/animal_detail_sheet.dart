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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
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
                  SheetAnimalStatus(farmController: _farmController, widget: widget),
                  context.dynamicHeight(0.01).height,
                  _buildNicknameSection(),
                  context.dynamicHeight(0.024).height,
                  _buildActionButtons(),
                  context.dynamicHeight(0.007).height,
                  _buildDetailInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameSection() {
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10)
                ),
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
              onTap: () {
                _farmController.feedAnimal(widget.animal.id);
                SnackMessages().showAnimalAction('Hayvan beslediniz!', Colors.green);
              }
            ),
            _buildActionButton(
              title: 'Love',
              userXpCost: '-10',
              gainAnimalXp: '+4',
              imagePath: 'assets/images/actions/love.png',
              imageHeight: 50,
              color: Colors.pink,
              isLoading: _farmController.lovingAnimalId.value == widget.animal.id,
              onTap: ()  {
                _farmController.loveAnimal(widget.animal.id);
                SnackMessages().showAnimalAction('Hayvana sevgi gösterdiniz!', Colors.pink);
              }
            ),
            _buildActionButton(
              title: 'Play',
              userXpCost: '-30',
              gainAnimalXp: '+4',
              imagePath: 'assets/images/actions/gaming2.png',
              imageHeight: 50,
              color: Colors.blue,
              isLoading: _farmController.playingAnimalId.value == widget.animal.id,
              onTap: () {
                _farmController.playWithAnimal(widget.animal.id);
                SnackMessages().showAnimalAction('Hayvanla oynadınız!', Colors.blue);
              } 
            ),
            _buildActionButton(
              title: 'Heal',
              userXpCost: '-50',
              gainAnimalXp: '+4',
              imagePath: 'assets/images/actions/heal.png',
              imageHeight: 50,
              color: Colors.green,
              isLoading: _farmController.healingAnimalId.value == widget.animal.id,
              onTap: () {
                _farmController.healAnimal(widget.animal.id);
                SnackMessages().showAnimalAction('Hayvanı iyileştirdiniz!', Colors.green);
              } 
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
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildDetailInfo() {
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
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildDetailRow('Name', updatedAnimal.name),
                _buildDetailRow('Descriptipn', updatedAnimal.description),
                _buildDetailRow('Level', '${updatedAnimal.level}'),
                _buildDetailRow('Experience Point ', '${updatedAnimal.experience} XP'),
                _buildDetailRow('Acquire At', 
                  '${updatedAnimal.acquiredAt.day}/${updatedAnimal.acquiredAt.month}/${updatedAnimal.acquiredAt.year}'),
                _buildDetailRow('Last Feeding', 
                  '${updatedAnimal.status.lastFed.hour}:${updatedAnimal.status.lastFed.minute.toString().padLeft(2, '0')}'),
                _buildDetailRow('Last Loving', 
                  '${updatedAnimal.status.lastLoved.hour}:${updatedAnimal.status.lastLoved.minute.toString().padLeft(2, '0')}'),
                _buildDetailRow('Last Gaming', 
                  '${updatedAnimal.status.lastPlayed.hour}:${updatedAnimal.status.lastPlayed.minute.toString().padLeft(2, '0')}'),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
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
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
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



