// ============================================================================
// FILE: lib/features/chat/presentation/widgets/modern_message_bubble.dart
// PURPOSE: Premium message bubble with glassmorphism and animations
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/modern_colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_animations.dart';
import '../../../../data/models/message_model.dart';

/// Modern message bubble with premium design
/// Features: glassmorphism, gradients, smooth animations, swipe gestures
class ModernMessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onSwipeReply;
  final VoidCallback? onLongPress;
  
  const ModernMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onSwipeReply,
    this.onLongPress,
  });

  @override
  State<ModernMessageBubble> createState() => _ModernMessageBubbleState();
}

class _ModernMessageBubbleState extends State<ModernMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  double _swipeOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    // Entry animation
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: widget.isMe ? const Offset(0.3, 0) : const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _buildMessageContent(context),
        ),
      ),
    );
  }
  
  Widget _buildMessageContent(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onHorizontalDragUpdate: _handleSwipe,
        onHorizontalDragEnd: _handleSwipeEnd,
        onLongPress: widget.onLongPress,
        child: Transform.translate(
          offset: Offset(_swipeOffset, 0),
          child: Container(
            margin: EdgeInsets.only(
              bottom: AppSpacing.xs,
              left: widget.isMe ? AppSpacing.xl : AppSpacing.md,
              right: widget.isMe ? AppSpacing.md : AppSpacing.xl,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: _buildBubbleDecoration(context),
            child: _buildBubbleContent(context),
          ),
        ),
      ),
    );
  }
  
  BoxDecoration _buildBubbleDecoration(BuildContext context) {
    if (widget.isMe) {
      // Sent message - gradient background
      return BoxDecoration(
        gradient: ModernColors.sentMessageGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLG),
          topRight: Radius.circular(AppSpacing.radiusLG),
          bottomLeft: Radius.circular(AppSpacing.radiusLG),
          bottomRight: Radius.circular(AppSpacing.radiusSM),
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primaryShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      // Received message - theme-based background
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return BoxDecoration(
        color: isDark
            ? ModernColors.receivedBubbleDark
            : ModernColors.receivedBubbleLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLG),
          topRight: Radius.circular(AppSpacing.radiusLG),
          bottomLeft: Radius.circular(AppSpacing.radiusSM),
          bottomRight: Radius.circular(AppSpacing.radiusLG),
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      );
    }
  }
  
  Widget _buildBubbleContent(BuildContext context) {
    final textColor = widget.isMe
        ? Colors.white
        : Theme.of(context).brightness == Brightness.dark
            ? ModernColors.textPrimaryDark
            : ModernColors.textPrimaryLight;
    
    final timestampColor = widget.isMe
        ? Colors.white.withOpacity(0.8)
        : Theme.of(context).brightness == Brightness.dark
            ? ModernColors.textSecondaryDark
            : ModernColors.textSecondaryLight;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message text
          Text(
            widget.message.text,
            style: AppTypography.chatMessage(color: textColor),
          ),
          
          AppSpacing.vSpaceXXS,
          
          // Timestamp and status row
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateFormat.jm().format(widget.message.timestamp),
                style: AppTypography.chatTimestamp(color: timestampColor),
              ),
              
              // Read receipts for sent messages
              if (widget.isMe) ...[
                AppSpacing.hSpaceXXS,
                _buildReadReceipt(),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildReadReceipt() {
    final isRead = widget.message.readBy.length > 1;
    
    return Icon(
      isRead ? Icons.done_all_rounded : Icons.done_rounded,
      size: 14,
      color: isRead
          ? ModernColors.info.withOpacity(0.9)
          : Colors.white.withOpacity(0.7),
    );
  }
  
  void _handleSwipe(DragUpdateDetails details) {
    if (widget.onSwipeReply == null) return;
    
    setState(() {
      _swipeOffset += details.delta.dx;
      
      // Limit swipe distance
      if (widget.isMe) {
        _swipeOffset = _swipeOffset.clamp(-60.0, 0.0);
      } else {
        _swipeOffset = _swipeOffset.clamp(0.0, 60.0);
      }
    });
  }
  
  void _handleSwipeEnd(DragEndDetails details) {
    if (widget.onSwipeReply == null) return;
    
    // Trigger reply if swiped enough
    if (_swipeOffset.abs() > 40) {
      widget.onSwipeReply?.call();
    }
    
    // Animate back to original position
    setState(() {
      _swipeOffset = 0.0;
    });
  }
}

/// Typing indicator bubble
class TypingIndicatorBubble extends StatefulWidget {
  const TypingIndicatorBubble({super.key});

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: AppSpacing.xs,
          left: AppSpacing.md,
          right: AppSpacing.xl,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? ModernColors.receivedBubbleDark
              : ModernColors.receivedBubbleLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          boxShadow: [
            BoxShadow(
              color: ModernColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            AppSpacing.hSpaceXXS,
            _buildDot(1),
            AppSpacing.hSpaceXXS,
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.2;
        final value = (_controller.value + delay) % 1.0;
        final scale = 0.5 + (0.5 * (1 - ((value - 0.5).abs() * 2)));
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ModernColors.textSecondaryLight,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
