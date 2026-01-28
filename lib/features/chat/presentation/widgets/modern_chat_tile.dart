// ============================================================================
// FILE: lib/features/chat/presentation/widgets/modern_chat_tile.dart
// PURPOSE: Premium chat list tile with animations and swipe actions
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/modern_colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_animations.dart';

/// Modern chat list tile with premium design and swipe actions
class ModernChatTile extends StatefulWidget {
  final String username;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onMute;
  final int index;
  
  const ModernChatTile({
    super.key,
    required this.username,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.onTap,
    this.onArchive,
    this.onDelete,
    this.onMute,
    this.index = 0,
  });

  @override
  State<ModernChatTile> createState() => _ModernChatTileState();
}

class _ModernChatTileState extends State<ModernChatTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  double _swipeOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
    ));
    
    // Staggered animation for list items
    Future.delayed(AppAnimations.staggerDelay(widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child:GestureDetector(
          onHorizontalDragUpdate: _handleSwipe,
          onHorizontalDragEnd: _handleSwipeEnd,
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: Transform.translate(
            offset: Offset(_swipeOffset, 0),
            child: _buildTileContent(context),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTileContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: AppSpacing.listItemPadding,
      decoration: BoxDecoration(
        color: isDark ? ModernColors.darkSurface : ModernColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? ModernColors.glassBorderDark
                : ModernColors.glassBorderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar with online indicator
          _buildAvatar(),
          
          AppSpacing.hSpaceSM,
          
          // Chat info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Username
                    Expanded(
                      child: Text(
                        widget.username,
                        style: AppTypography.username(
                          color: isDark
                              ? ModernColors.textPrimaryDark
                              : ModernColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    AppSpacing.hSpaceXS,
                    
                    // Time
                    Text(
                      _formatTime(widget.lastMessageTime),
                      style: AppTypography.chatTimestamp(
                        color: isDark
                            ? ModernColors.textTertiaryDark
                            : ModernColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
                
                AppSpacing.vSpaceXXS,
                
                // Last message and unread badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.lastMessage,
                        style: AppTypography.chatMessage(
                          color: isDark
                              ? ModernColors.textSecondaryDark
                              : ModernColors.textSecondaryLight,
                        ).copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    if (widget.unreadCount > 0) ...[
                      AppSpacing.hSpaceXS,
                      _buildUnreadBadge(),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatar() {
    return Stack(
      children: [
        // Avatar
        Container(
          width: AppSpacing.avatarMD,
          height: AppSpacing.avatarMD,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.isOnline
                ? ModernColors.primaryGradient
                : null,
            color: widget.isOnline ? null : ModernColors.textTertiaryLight,
            border: widget.isOnline
                ? Border.all(color: ModernColors.primary, width: 2)
                : null,
          ),
          child: widget.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    widget.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                  ),
                )
              : _buildAvatarFallback(),
        ),
        
        // Online indicator
        if (widget.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: ModernColors.onlineGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        widget.username.substring(0, 1).toUpperCase(),
        style: AppTypography.username(color: Colors.white).copyWith(
          fontSize: 18,
        ),
      ),
    );
  }
  
  Widget _buildUnreadBadge() {
    final count = widget.unreadCount > 99 ? '99+' : widget.unreadCount.toString();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        gradient: ModernColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primaryShadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Center(
        child: Text(
          count,
          style: AppTypography.chatTimestamp(color: Colors.white).copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays == 0) {
      return DateFormat.jm().format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(time);
    } else {
      return DateFormat.MMMd().format(time);
    }
  }
  
  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dx;
      _swipeOffset = _swipeOffset.clamp(-80.0, 80.0);
    });
  }
  
  void _handleSwipeEnd(DragEndDetails details) {
    if (_swipeOffset.abs() > 60) {
      // Trigger action based on swipe direction
      if (_swipeOffset < 0 && widget.onArchive != null) {
        widget.onArchive!();
      } else if (_swipeOffset > 0 && widget.onMute != null) {
        widget.onMute!();
      }
    }
    
    // Animate back to center
    setState(() {
      _swipeOffset = 0.0;
    });
  }
}
