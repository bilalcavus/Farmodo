import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimalDetailSheet extends StatefulWidget {
  final FarmAnimal animal;

  const AnimalDetailSheet({
    super.key,
    required this.animal,
  });

  @override
  State<AnimalDetailSheet> createState() => _AnimalDetailSheetState();
}

class _AnimalDetailSheetState extends State<AnimalDetailSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _nicknameController = TextEditingController();
  final FarmController _farmController = Get.find<FarmController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _nicknameController.text = widget.animal.nickname;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
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
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.dynamicWidth(0.05)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hayvan resmi ve temel bilgiler
                      _buildAnimalHeader(),
                      
                      const SizedBox(height: 24),
                      
                      // Durum kartları
                      _buildStatusCards(),
                      
                      const SizedBox(height: 24),
                      
                      // Takma ad düzenleme
                      _buildNicknameSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Aksiyon butonları
                      _buildActionButtons(),
                      
                      const SizedBox(height: 24),
                      
                      // Detay bilgileri
                      _buildDetailInfo(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalHeader() {
    return Row(
      children: [
        // Hayvan resmi
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              widget.animal.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Hayvan bilgileri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.animal.nickname.isNotEmpty 
                          ? widget.animal.nickname 
                          : widget.animal.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _farmController.toggleAnimalFavorite(widget.animal.id),
                    child: Icon(
                      widget.animal.isFavorite 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                ],
              ),
              
              if (widget.animal.nickname.isNotEmpty)
                Text(
                  widget.animal.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Seviye ve deneyim
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Seviye ${widget.animal.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deneyim: ${widget.animal.experience} XP',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (widget.animal.experience % 100) / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durum',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: [
            _buildStatusCard(
              'Açlık',
              widget.animal.status.hunger,
              Colors.orange,
              Icons.restaurant,
            ),
            _buildStatusCard(
              'Sevgi',
              widget.animal.status.love,
              Colors.pink,
              Icons.favorite,
            ),
            _buildStatusCard(
              'Enerji',
              widget.animal.status.energy,
              Colors.blue,
              Icons.flash_on,
            ),
            _buildStatusCard(
              'Sağlık',
              widget.animal.status.health,
              Colors.green,
              Icons.health_and_safety,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
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
        const Text(
          'Takma Ad',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
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
            
            const SizedBox(width: 12),
            
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
        const Text(
          'Aksiyonlar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
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
        padding: const EdgeInsets.all(16),
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
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(icon, color: color, size: 20),
            
            const SizedBox(width: 12),
            
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detay Bilgileri',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              _buildDetailRow('Tür', widget.animal.name),
              _buildDetailRow('Açıklama', widget.animal.description),
              _buildDetailRow('Edinilme Tarihi', 
                '${widget.animal.acquiredAt.day}/${widget.animal.acquiredAt.month}/${widget.animal.acquiredAt.year}'),
              _buildDetailRow('Son Beslenme', 
                '${widget.animal.status.lastFed.hour}:${widget.animal.status.lastFed.minute.toString().padLeft(2, '0')}'),
              _buildDetailRow('Son Sevgi', 
                '${widget.animal.status.lastLoved.hour}:${widget.animal.status.lastLoved.minute.toString().padLeft(2, '0')}'),
              _buildDetailRow('Son Oyun', 
                '${widget.animal.status.lastPlayed.hour}:${widget.animal.status.lastPlayed.minute.toString().padLeft(2, '0')}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
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
