// ============================================================================
// FILE: lib/core/widgets/media_message_widget.dart
// PURPOSE: Widget for displaying media messages (images and audio)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../data/models/message_model.dart';
import '../../core/constants/app_constants.dart';

class MediaMessageWidget extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;

  const MediaMessageWidget({
    Key? key,
    required this.message,
    required this.isMe,
    this.onRetry,
    this.onDelete,
  }) : super(key: key);

  @override
  State<MediaMessageWidget> createState() => _MediaMessageWidgetState();
}

class _MediaMessageWidgetState extends State<MediaMessageWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.message.messageType) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.audio:
        return _buildAudioMessage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageMessage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.message.mediaUrl ?? '',
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.error)),
              ),
              fit: BoxFit.cover,
              width: 250,
              height: 200,
            ),
            if (widget.isMe)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatFileSize(widget.message.mediaSize ?? 0),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.blue[100] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
            color: widget.isMe ? Colors.blue[800] : Colors.grey[800],
          ),

          // Audio waveform or progress
          Expanded(
            child: _buildAudioProgress(),
          ),

          // Duration text
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
              style: TextStyle(
                fontSize: 12,
                color: widget.isMe ? Colors.blue[800] : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioProgress() {
    if (_duration.inSeconds == 0) {
      return Container(
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    return LinearProgressIndicator(
      value: _duration.inSeconds > 0 
        ? _position.inSeconds / _duration.inSeconds 
        : 0,
      backgroundColor: Colors.grey[300],
      color: widget.isMe ? Colors.blue[600] : Colors.grey[600],
      minHeight: 4,
    );
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        await _audioPlayer.setUrl(widget.message.mediaUrl ?? '');
        await _audioPlayer.play();
      } catch (e) {
        // Handle error
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return hours == '00' 
        ? '$minutes:$seconds' 
        : '$hours:$minutes:$seconds';
  }
}

/// Widget for media message input controls
class MediaMessageInput extends StatelessWidget {
  final VoidCallback onImagePick;
  final VoidCallback onImageCapture;
  final VoidCallback onAudioRecord;
  final bool isRecording;
  final VoidCallback onStopRecording;

  const MediaMessageInput({
    Key? key,
    required this.onImagePick,
    required this.onImageCapture,
    required this.onAudioRecord,
    required this.isRecording,
    required this.onStopRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Image picker button
        IconButton(
          icon: const Icon(Icons.image),
          onPressed: onImagePick,
          tooltip: 'Pick Image',
        ),

        // Camera capture button
        IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: onImageCapture,
          tooltip: 'Take Photo',
        ),

        // Audio recording button
        if (!isRecording)
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: onAudioRecord,
            tooltip: 'Record Audio',
          )
        else
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: onStopRecording,
            color: Colors.red,
            tooltip: 'Stop Recording',
          ),

        const Spacer(),
      ],
    );
  }
}