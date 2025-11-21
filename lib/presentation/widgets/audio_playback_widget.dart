// ============================================================================
// audio_playback_widget.dart - WIDGET DE REPRODUCCIÓN DE AUDIO GRABADO
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/voice_recording_service.dart';
import '../../injection_container_clean.dart';
import '../screens/v2/components/minimal_colors.dart';

class AudioPlaybackWidget extends StatefulWidget {
  final String audioPath;
  final String? duration;

  const AudioPlaybackWidget({
    Key? key,
    required this.audioPath,
    this.duration,
  }) : super(key: key);

  @override
  State<AudioPlaybackWidget> createState() => _AudioPlaybackWidgetState();
}

class _AudioPlaybackWidgetState extends State<AudioPlaybackWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  VoiceRecordingService? _voiceService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeVoiceService();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeVoiceService() async {
    try {
      _voiceService = sl<VoiceRecordingService>();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing voice service for playback: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _voiceService == null) {
      return _buildLoadingState();
    }

    // Check if file exists
    if (!File(widget.audioPath).existsSync()) {
      return _buildFileNotFoundState();
    }

    return ChangeNotifierProvider.value(
      value: _voiceService!,
      child: Consumer<VoiceRecordingService>(
        builder: (context, voiceService, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MinimalColors.backgroundCard(context),
                  MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(voiceService),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getShadowColor(voiceService),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildPlaybackControls(voiceService),
                if (voiceService.isPlaying && voiceService.currentRecordingPath == widget.audioPath) ...[
                  const SizedBox(height: 12),
                  _buildProgressIndicator(voiceService),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cargando reproductor...',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileNotFoundState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio no encontrado',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'El archivo de audio ya no está disponible',
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.audiotrack,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reflexión de Voz',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.duration ?? 'Duración: --:--',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(VoiceRecordingService voiceService) {
    final isPlayingThis = voiceService.isPlaying && voiceService.currentRecordingPath == widget.audioPath;
    
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isPlayingThis ? _pulseAnimation.value : 1.0,
              child: GestureDetector(
                onTap: () => _togglePlayback(voiceService),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPlayingThis 
                          ? [Colors.orange, Colors.orange.shade700]
                          : MinimalColors.accentGradient(context),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (isPlayingThis ? Colors.orange : MinimalColors.accentGradient(context)[0])
                            .withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlayingThis ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        if (voiceService.isPlaying && voiceService.currentRecordingPath == widget.audioPath) ...[
          GestureDetector(
            onTap: () => voiceService.stopPlayback(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.stop,
                color: MinimalColors.textSecondary(context),
                size: 18,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (voiceService.isPlaying && voiceService.currentRecordingPath == widget.audioPath) ...[
          Text(
            '${voiceService.formatDuration(voiceService.playbackDuration)} / ${voiceService.formatDuration(voiceService.totalDuration)}',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator(VoiceRecordingService voiceService) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: voiceService.playbackProgress,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            MinimalColors.accentGradient(context)[0],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              voiceService.formatDuration(voiceService.playbackDuration),
              style: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 10,
              ),
            ),
            Text(
              voiceService.formatDuration(voiceService.totalDuration),
              style: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _togglePlayback(VoiceRecordingService voiceService) async {
    final isPlayingThis = voiceService.isPlaying && voiceService.currentRecordingPath == widget.audioPath;
    
    if (isPlayingThis) {
      await voiceService.pausePlayback();
      _pulseController.stop();
    } else {
      // Stop any current playback
      if (voiceService.isPlaying) {
        await voiceService.stopPlayback();
      }
      
      // Set the current recording path and start playback
      voiceService.setCurrentRecordingPath(widget.audioPath);
      await voiceService.startPlayback();
      
      if (voiceService.isPlaying) {
        _pulseController.repeat();
      }
    }
  }

  Color _getBorderColor(VoiceRecordingService voiceService) {
    final isPlayingThis = voiceService.isPlaying && voiceService.currentRecordingPath == widget.audioPath;
    
    if (isPlayingThis) {
      return MinimalColors.accentGradient(context)[0].withValues(alpha: 0.5);
    }
    return MinimalColors.textMuted(context).withValues(alpha: 0.3);
  }

  Color _getShadowColor(VoiceRecordingService voiceService) {
    final isPlayingThis = voiceService.isPlaying && voiceService.currentRecordingPath == widget.audioPath;
    
    if (isPlayingThis) {
      return MinimalColors.accentGradient(context)[0].withValues(alpha: 0.2);
    }
    return Colors.black.withValues(alpha: 0.1);
  }
}