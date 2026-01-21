import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/achievements_service.dart';
import '../models/player_profile.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';
import '../state/player_profile_notifier.dart';
import '../services/storage_service.dart';
import '../utils/date_formatter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final l10n = AppLocalizations.of(context);
      
      // Проверяем и обновляем достижения
      final profileAsync = ref.read(playerProfileProvider);
      final profile = profileAsync.value;
      
      if (profile != null) {
        final transactions = await StorageService.getTransactions();
        final piggyBanks = await StorageService.getPiggyBanks();
        
        final newlyUnlocked = await AchievementsService.checkAchievements(
          profile: profile,
          transactions: transactions,
          piggyBanks: piggyBanks,
          l10n: l10n,
        );
        
        // Показываем уведомление о новых достижениях
        if (newlyUnlocked.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n != null
                    ? l10n.achievements_unlockedCount(newlyUnlocked.length)
                    : 'Разблокировано достижений: ${newlyUnlocked.length}',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
      
      final updatedAchievements = await AchievementsService.getAchievements(l10n);
      
      if (mounted) {
        setState(() {
          _achievements = updatedAchievements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievements_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _achievements.isEmpty
                  ? Center(
                      child: Text(
                        l10n.achievements_empty,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAchievements,
                      child: AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _achievements.length,
                          itemBuilder: (context, index) {
                            final achievement = _achievements[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _AchievementCard(
                                    achievement: achievement,
                                    onTap: () {
                                      // Можно добавить детальный просмотр
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;

  const _AchievementCard({
    required this.achievement,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'savings':
        return Icons.savings;
      case 'trending_up':
        return Icons.trending_up;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'diamond':
        return Icons.diamond;
      case 'receipt':
        return Icons.receipt;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'check_circle':
        return Icons.check_circle;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(achievement.icon);
    final isUnlocked = achievement.unlocked;
    
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [
                          AuroraTheme.neonYellow.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUnlocked
                    ? null
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked
                      ? AuroraTheme.neonYellow.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.15),
                  width: isUnlocked ? 2 : 1,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: AuroraTheme.neonYellow.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Иконка
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AuroraTheme.neonYellow.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: AuroraTheme.neonYellow.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      iconData,
                      color: isUnlocked
                          ? AuroraTheme.neonYellow
                          : Colors.white.withValues(alpha: 0.3),
                      size: 30,
                    ),
                  ),
                const SizedBox(width: 16),
                // Текст
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: TextStyle(
                                color: isUnlocked
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isUnlocked
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          if (isUnlocked)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          color: isUnlocked
                              ? Colors.white70
                              : Colors.white.withValues(alpha: 0.3),
                          fontSize: 12,
                        ),
                      ),
                      if (achievement.unlockedAt != null) ...[
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            final formattedDate = LocalizedDateFormatter.formatDateShort(
                              context,
                              achievement.unlockedAt!,
                            );
                            return Text(
                              l10n.achievements_unlockedAt(formattedDate),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
