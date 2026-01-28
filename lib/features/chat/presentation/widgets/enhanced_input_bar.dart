// ============================================================================
// FILE: lib/features/chat/presentation/widgets/enhanced_input_bar.dart
// PURPOSE: Premium message input with glassmorphism and animations
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/themes/modern_colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_animations.dart';
import '../../../../core/widgets/glass_container.dart';

/// Enhanced input bar with glassmorphism and smooth animations
class EnhancedInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final VoidCallback? onAttachmentTap;
  final VoidCallback? onEmojiTap;
  final VoidCallback? onVoiceTap;
  final bool isTyping;
  
  const EnhancedInputBar({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.onAttachmentTap,
    this.onEmojiTap,
    this.onVoiceTap,
    this.isTyping = false,
  });

  @override
  State<EnhancedInputBar> createState() => _EnhancedInputBarState();
}

class _EnhancedInputBarState extends State<EnhancedInputBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;
  late Animation<double> _sendButtonRotation;
  
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    
    widget.controller.addListener(_onTextChanged);
    
    _sendButtonController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    
    _sendButtonScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: AppAnimations.emphasized,
    ));
    
    _sendButtonRotation = Tween<double>(
      begin: -0.25,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: AppAnimations.emphasized,
    ));
  }
  
  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 15.0,
      opacity: 0.7,
      borderRadius: 0,
      showBorder: false,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            if (widget.onAttachmentTap != null)
              _buildIconButton(
                icon: Icons.add_circle_outline_rounded,
                onTap: widget.onAttachmentTap!,
                color: ModernColors.textSecondaryLight,
              ),
            
            AppSpacing.hSpaceXS,
            
            // Text input field
            Expanded(
              child: _buildTextField(context),
            ),
            
            AppSpacing.hSpaceXS,
            
            // Emoji button (only show when no text)
            if (!_hasText && widget.onEmojiTap != null)
              _buildIconButton(
                icon: Icons.emoji_emotions_outlined,
                onTap: widget.onEmojiTap!,
                color: ModernColors.textSecondaryLight,
              ),
            
            AppSpacing.hSpaceXXS,
            
            // Send button (animated) or Voice button
            _hasText
                ? _buildSendButton()
                : widget.onVoiceTap != null
                    ? _buildIconButton(
                        icon: Icons.mic_outlined,
                        onTap: widget.onVoiceTap!,
                        color: ModernColors.primary,
                      )
                    : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 120,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? ModernColors.darkSurfaceVariant.withOpacity(0.5)
            : ModernColors.lightSurfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: isDark
              ? ModernColors.glassBorderDark
              : ModernColors.glassBorderLight,
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: TextField(
        controller: widget.controller,
        style: AppTypography.chatMessage(
          color: isDark
              ? ModernColors.textPrimaryDark
              : ModernColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: 'Type a message...',
          hintStyle: AppTypography.chatMessage(
            color: isDark
                ? ModernColors.textTertiaryDark
                : ModernColors.textTertiaryLight,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
      ),
    );
  }
  
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: color,
          size: AppSpacing.iconMD,
        ),
      ),
    );
  }
  
  Widget _buildSendButton() {
    return ScaleTransition(
      scale: _sendButtonScale,
      child: RotationTransition(
        turns: _sendButtonRotation,
        child: InkWell(
          onTap: () {
            if (_hasText) {
              HapticFeedback.mediumImpact();
              widget.onSendMessage();
            }
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: ModernColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primaryShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// Voice recording indicator
class VoiceRecordingIndicator extends StatefulWidget {
  final Duration duration;
  final VoidCallback onCancel;
  final VoidCallback onSend;
  
  const VoiceRecordingIndicator({
    super.key,
    required this.duration,
    required this.onCancel,
    required this.onSend,
  });

  @override
  State<VoiceRecordingIndicator> createState() =>
      _VoiceRecordingIndicatorState();
}

class _VoiceRecordingIndicatorState extends State<VoiceRecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 15.0,
      opacity: 0.9,
      borderRadius: AppSpacing.radiusXL,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Cancel button
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: widget.onCancel,
            color: ModernColors.error,
          ),
          
          AppSpacing.hSpaceXS,
          
          // Recording icon (pulsing)
          FadeTransition(
            opacity: _controller,
            child: Icon(
              Icons.fiber_manual_record,
              color: ModernColors.error,
              size: AppSpacing.iconMD,
            ),
          ),
          
          AppSpacing.hSpaceXS,
          
          // Duration
          Text(
            _formatDuration(widget.duration),
            style: AppTypography.chatMessage(
              color: ModernColors.textPrimaryDark,
            ).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const Spacer(),
          
          // Waveform placeholder
          _buildWaveform(),
          
          const Spacer(),
          
          // Send button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: ModernColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: widget.onSend,
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(15, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.1;
            final value = (_controller.value + delay) % 1.0;
            final height = 4 + (16 * value);
            
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: ModernColors.primary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
