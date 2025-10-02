import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/account/widget/user_avatar.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ProfileDetailView extends StatefulWidget {
  const ProfileDetailView({super.key});

  @override
  State<ProfileDetailView> createState() => _ProfileDetailViewState();
}

class _ProfileDetailViewState extends State<ProfileDetailView> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final GamificationController _gamificationController = getIt<GamificationController>();
  
  bool isLoadingStats = true;
  int tasksCompleted = 0;
  int totalXp = 0;
  int daysActive = 0;
  String joinedYearText = '';
  String handleText = '@guest';
  bool isEditing = false;
  
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    if (_authService.isLoggedIn) {
      await _gamificationController.loadAllData();
    }
  }

  Future<void> _loadProfileData() async {
    if (!_authService.isLoggedIn) {
      setState(() {
        totalXp = 0;
        tasksCompleted = 0;
        daysActive = 0;
        joinedYearText = '';
        handleText = '@guest';
        isLoadingStats = false;
      });
      return;
    }

    await _authService.fetchAndSetCurrentUser();
    final user = _authService.currentUser;

    // Load completed tasks
    int computedTasks = 0;
    bool first = true;
    while (true) {
      final items = await _firestoreService.getCompletedTask(loadMore: !first);
      computedTasks += items.length;
      first = false;
      if (items.length < 10) break;
    }

    final createdAt = user?.createdAt;
    final joinedYear = createdAt != null ? createdAt.year.toString() : '';
    final computedDays = createdAt != null
        ? DateTime.now().difference(createdAt).inDays.clamp(0, 100000)
        : 0;

    setState(() {
      totalXp = user?.xp ?? 0;
      tasksCompleted = computedTasks;
      daysActive = computedDays;
      joinedYearText = joinedYear;
      handleText = '@${_authService.firebaseUser?.email?.split('@').first ?? 'guest'}';
      isLoadingStats = false;
      
      // Set form controllers
      _displayNameController.text = user?.displayName ?? '';
      _emailController.text = _authService.firebaseUser?.email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          'Profile Detail',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.dynamicHeight(0.022),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(context),
            context.dynamicHeight(0.03).height,
            
            // Statistics Section
            _buildStatisticsSection(context),
            context.dynamicHeight(0.03).height,
            
            // Profile Information Section
            _buildProfileInfoSection(context),
            context.dynamicHeight(0.03).height,
            
            // Achievements Section (if any)
            _buildAchievementsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final user = _authService.firebaseUser;
    final displayName = _authService.currentUser?.displayName.isNotEmpty == true
        ? _authService.currentUser!.displayName
        : (user?.displayName ?? 'Guest User');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.dynamicHeight(0.025)),
      child: Column(
        children: [
          Center(
            child: UserAvatar(
              user: user,
              fontSize: 20,
              radius: context.dynamicHeight(0.06),
            ),
          ),
          context.dynamicHeight(0.02).height,
          Text(
            displayName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.dynamicHeight(0.028),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          context.dynamicHeight(0.008).height,
          Text(
            handleText,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.dynamicHeight(0.016),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (joinedYearText.isNotEmpty) ...[
            context.dynamicHeight(0.008).height,
            Text(
              'Joined $joinedYearText',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.dynamicHeight(0.014),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.dynamicHeight(0.025)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.dynamicHeight(0.02),
              fontWeight: FontWeight.w600,
            ),
          ),
          context.dynamicHeight(0.02).height,
          if (isLoadingStats)
            Center(child: CircularProgressIndicator(color: AppColors.primary))
          else ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Tasks Completed',
                    value: tasksCompleted.toString(),
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                  ),
                ),
                context.dynamicWidth(0.02).width,
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Total XP',
                    value: totalXp.toString(),
                    icon: HugeIcons.strokeRoundedStar,
                  ),
                ),
              ],
            ),
            context.dynamicHeight(0.015).height,
            _buildStatCard(
              context: context,
              title: 'Days Active',
              value: daysActive.toString(),
              icon: HugeIcons.strokeRoundedCalendar01,
              isWide: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    bool isWide = false,
  }) {
    return Container(
      padding: EdgeInsets.all(context.dynamicHeight(0.02)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
        border: Border.all(color: AppColors.border),
      ),
      child: isWide
          ? Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: context.dynamicHeight(0.025),
                ),
                context.dynamicWidth(0.03).width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: context.dynamicHeight(0.022),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.dynamicHeight(0.014),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: context.dynamicHeight(0.025),
                ),
                context.dynamicHeight(0.01).height,
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.dynamicHeight(0.022),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                context.dynamicHeight(0.005).height,
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.dynamicHeight(0.012),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildProfileInfoSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.dynamicHeight(0.025)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.dynamicHeight(0.02),
              fontWeight: FontWeight.w600,
            ),
          ),
          context.dynamicHeight(0.02).height,
          
          // Display Name Field
          _buildInfoField(
            context: context,
            label: 'Display Name',
            controller: _displayNameController,
            icon: HugeIcons.strokeRoundedUser,
            isEditable: isEditing,
          ),
          context.dynamicHeight(0.015).height,
          
          // Email Field
          _buildInfoField(
            context: context,
            label: 'Email',
            controller: _emailController,
            icon: HugeIcons.strokeRoundedAiMail,
            isEditable: false, // Email cannot be changed
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: context.dynamicHeight(0.014),
            fontWeight: FontWeight.w500,
          ),
        ),
        context.dynamicHeight(0.008).height,
        Container(
          decoration: BoxDecoration(
            color: isEditable ? AppColors.background : AppColors.background.withAlpha(100),
            borderRadius: BorderRadius.circular(context.dynamicHeight(0.01)),
            border: Border.all(
              color: isEditable ? AppColors.primary : AppColors.border,
              width: isEditable ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: isEditable,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.dynamicHeight(0.016),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColors.textSecondary,
                size: context.dynamicHeight(0.02),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.04),
                vertical: context.dynamicHeight(0.015),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.dynamicHeight(0.025)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.dynamicHeight(0.02),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(() => Text(
                '${_gamificationController.totalUnlockedAchievements}/${_gamificationController.totalAchievements}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.dynamicHeight(0.014),
                  fontWeight: FontWeight.w500,
                ),
              )),
            ],
          ),
          context.dynamicHeight(0.02).height,
          Obx(() {
            if (_gamificationController.isLoadingAchievements.value) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            
            final unlockedAchievements = _gamificationController.unlockedAchievements;
            final lockedAchievements = _gamificationController.lockedAchievements;
            
            if (unlockedAchievements.isEmpty && lockedAchievements.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.supervised_user_circle,
                      color: AppColors.textSecondary,
                      size: context.dynamicHeight(0.05),
                    ),
                    context.dynamicHeight(0.01).height,
                    Text(
                      'No achievements yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.dynamicHeight(0.016),
                      ),
                    ),
                    context.dynamicHeight(0.005).height,
                    Text(
                      'Complete tasks to unlock achievements!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.dynamicHeight(0.014),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                // Unlocked Achievements
                if (unlockedAchievements.isNotEmpty) ...[
                  Text(
                    'Unlocked (${unlockedAchievements.length})',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.dynamicHeight(0.016),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  context.dynamicHeight(0.01).height,
                  ...unlockedAchievements.take(3).map((achievement) => 
                    _buildAchievementItem(context, achievement, true)
                  ).toList(),
                  if (unlockedAchievements.length > 3) ...[
                    context.dynamicHeight(0.01).height,
                    Text(
                      '+${unlockedAchievements.length - 3} more unlocked',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: context.dynamicHeight(0.014),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
                
                // Locked Achievements
                if (lockedAchievements.isNotEmpty) ...[
                  if (unlockedAchievements.isNotEmpty) context.dynamicHeight(0.02).height,
                  Text(
                    'Locked (${lockedAchievements.length})',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.dynamicHeight(0.016),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  context.dynamicHeight(0.01).height,
                  ...lockedAchievements.take(2).map((achievement) => 
                    _buildAchievementItem(context, achievement, false)
                  ).toList(),
                  if (lockedAchievements.length > 2) ...[
                    context.dynamicHeight(0.01).height,
                    Text(
                      '+${lockedAchievements.length - 2} more locked',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.dynamicHeight(0.014),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, Achievement achievement, bool isUnlocked) {
    return Container(
      margin: EdgeInsets.only(bottom: context.dynamicHeight(0.01)),
      padding: EdgeInsets.all(context.dynamicHeight(0.015)),
      decoration: BoxDecoration(
        color: isUnlocked ? achievement.rarityColor.withAlpha(25) : AppColors.background,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.01)),
        border: Border.all(
          color: isUnlocked ? achievement.rarityColor : AppColors.border,
          width: isUnlocked ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicHeight(0.008)),
            decoration: BoxDecoration(
              color: isUnlocked ? achievement.rarityColor : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(context.dynamicHeight(0.008)),
            ),
            child: Icon(
              achievement.rarityIcon,
              color: Colors.white,
              size: context.dynamicHeight(0.02),
            ),
          ),
          context.dynamicWidth(0.03).width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: context.dynamicHeight(0.016),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                context.dynamicHeight(0.003).height,
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.dynamicHeight(0.013),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isUnlocked) ...[
            context.dynamicWidth(0.02).width,
            Column(
              children: [
                Text(
                  '${achievement.xpReward} XP',
                  style: TextStyle(
                    color: achievement.rarityColor,
                    fontSize: context.dynamicHeight(0.012),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: achievement.rarityColor,
                  size: context.dynamicHeight(0.018),
                ),
              ],
            ),
          ] else ...[
            context.dynamicWidth(0.02).width,
            Icon(
              Icons.lock,
              color: AppColors.textSecondary,
              size: context.dynamicHeight(0.018),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
