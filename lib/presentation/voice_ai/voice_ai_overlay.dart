import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';

class VoiceAIOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const VoiceAIOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<VoiceAIOverlay> createState() => _VoiceAIOverlayState();
}

class _VoiceAIOverlayState extends State<VoiceAIOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late List<Animation<double>> _waveAnimations;

  bool _isListening = false;
  String _currentState = 'idle'; // idle, listening, processing, result
  String _recognizedText = '';

  final List<String> _voiceCommands = [
    "Book a ticket to Yaoundé",
    "Find buses to Douala tomorrow",
    "Show me my recent bookings",
    "Track my bus location",
  ];

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Create wave animations for audio visualization
    _waveAnimations = List.generate(5, (index) {
      return Tween<double>(
        begin: 0.2,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _waveController,
        curve: Interval(
          index * 0.1,
          0.7 + (index * 0.1),
          curve: Curves.easeInOut,
        ),
      ));
    });

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _currentState = 'listening';
      _recognizedText = '';
    });
    
    HapticFeedback.lightImpact();
    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);
    
    // Simulate voice recognition
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isListening) {
        _simulateRecognition();
      }
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _currentState = 'idle';
    });
    
    _pulseController.stop();
    _waveController.stop();
    HapticFeedback.selectionClick();
  }

  void _simulateRecognition() {
    setState(() {
      _currentState = 'processing';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _recognizedText = _voiceCommands[math.Random().nextInt(_voiceCommands.length)];
          _currentState = 'result';
        });
        
        _pulseController.stop();
        _waveController.stop();
        
        // Auto-close after showing result
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _closeOverlay();
          }
        });
      }
    });
  }

  void _closeOverlay() async {
    await _slideController.reverse();
    widget.onClose();
  }

  Color _getStateColor() {
    switch (_currentState) {
      case 'listening':
        return const Color(0xFF00D2FF);
      case 'processing':
        return const Color(0xFFf4d03f);
      case 'result':
        return const Color(0xFF27ae60);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  String _getStateText() {
    switch (_currentState) {
      case 'listening':
        return 'Listening...';
      case 'processing':
        return 'Processing...';
      case 'result':
        return 'Got it!';
      default:
        return 'Tap to speak';
    }
  }

  Widget _buildMicrophoneButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _getStateColor(),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: _getStateColor().withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: _isListening ? 10 : 5,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveVisualizer() {
    if (!_isListening) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _waveAnimations.map((animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: 6,
              height: 40 * animation.value,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _getStateColor().withOpacity(0.8),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCommandSuggestions() {
    return Column(
      children: [
        Text(
          'Try saying:',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textMediumEmphasisLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...(_voiceCommands.take(3).map((command) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: _getStateColor(),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '"$command"',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHighEmphasisLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ))),
      ],
    );
  }

  Widget _buildRecognizedText() {
    if (_recognizedText.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStateColor().withOpacity(0.1),
            _getStateColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStateColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: _getStateColor(),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Recognized:',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.textMediumEmphasisLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_recognizedText"',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textHighEmphasisLight,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: GestureDetector(
        onTap: _closeOverlay,
        child: Stack(
          children: [
            // Background overlay
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🎤 Voice AI Assistant',
                              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _getStateColor(),
                              ),
                            ),
                            IconButton(
                              onPressed: _closeOverlay,
                              icon: Icon(
                                Icons.close,
                                color: AppTheme.textMediumEmphasisLight,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Microphone button
                        _buildMicrophoneButton(),
                        
                        const SizedBox(height: 20),
                        
                        // State text
                        Text(
                          _getStateText(),
                          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                            color: _getStateColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Wave visualizer
                        SizedBox(
                          height: 50,
                          child: _buildWaveVisualizer(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Recognized text or command suggestions
                        if (_currentState == 'result')
                          _buildRecognizedText()
                        else if (_currentState == 'idle')
                          _buildCommandSuggestions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}