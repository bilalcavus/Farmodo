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
          'Takma Ad',
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
                  hintText: 'Takma ad girin...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              child: const Text('Kaydet'),
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
          'Aksiyonlar',
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
          childAspectRatio: 3,
          children: [
            _buildActionButton(
              'Besle',
              Icons.restaurant,
              Colors.orange,
              _farmController.feedingAnimalId.value == widget.animal.id,
              () => _farmController.feedAnimal(widget.animal.id),
            ),
            _buildActionButton(
              'Sev',
              Icons.favorite,
              Colors.pink,
              _farmController.lovingAnimalId.value == widget.animal.id,
              () => _farmController.loveAnimal(widget.animal.id),
            ),
            _buildActionButton(
              'Oyna',
              Icons.sports_esports,
              Colors.blue,
              _farmController.playingAnimalId.value == widget.animal.id,
              () => _farmController.playWithAnimal(widget.animal.id),
            ),
            _buildActionButton(
              'İyileştir',
              Icons.healing,
              Colors.green,
              _farmController.healingAnimalId.value == widget.animal.id,
              () => _farmController.healAnimal(widget.animal.id),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    bool isLoading,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.shade300 : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isLoading ? Colors.grey.shade400 : color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            isLoading
                ? SizedBox(
                    width: context.dynamicWidth(0.05),
                    height: context.dynamicHeight(0.025),
                    child: CircularProgressIndicator(
                      strokeWidth: context.dynamicWidth(0.005),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(icon, color: color, size: context.dynamicHeight(0.025)),
            
            SizedBox(width: context.dynamicWidth(0.03)),
            
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLoading ? Colors.grey.shade600 : color,
                ),
              ),
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
            'Detay Bilgileri',
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
                _buildDetailRow('Tür', updatedAnimal.name),
                _buildDetailRow('Açıklama', updatedAnimal.description),
                _buildDetailRow('Edinilme Tarihi', 
                  '${updatedAnimal.acquiredAt.day}/${updatedAnimal.acquiredAt.month}/${updatedAnimal.acquiredAt.year}'),
                _buildDetailRow('Son Beslenme', 
                  '${updatedAnimal.status.lastFed.hour}:${updatedAnimal.status.lastFed.minute.toString().padLeft(2, '0')}'),
                _buildDetailRow('Son Sevgi', 
                  '${updatedAnimal.status.lastLoved.hour}:${updatedAnimal.status.lastLoved.minute.toString().padLeft(2, '0')}'),
                _buildDetailRow('Son Oyun', 
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



