import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/v2/components/minimal_colors.dart';

/// Model for onboarding step information
class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Alignment? targetAlignment;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    this.targetAlignment,
  });
}

/// Overlay widget that shows onboarding tooltips for a screen
class ScreenOnboardingOverlay extends StatefulWidget {
  final String screenKey;
  final List<OnboardingStep> steps;
  final Widget child;

  const ScreenOnboardingOverlay({
    Key? key,
    required this.screenKey,
    required this.steps,
    required this.child,
  }) : super(key: key);

  @override
  State<ScreenOnboardingOverlay> createState() => _ScreenOnboardingOverlayState();
}

class _ScreenOnboardingOverlayState extends State<ScreenOnboardingOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _hasShownOnboarding = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAndShowOnboarding() {
    final provider = context.read<OnboardingProvider>();
    if (provider.shouldShowOnboarding(widget.screenKey) && !_hasShownOnboarding) {
      _hasShownOnboarding = true;
      provider.startOnboarding(widget.screenKey);
      _animationController.forward();
    }
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.forward(from: 0.7);
    } else {
      _finishOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.forward(from: 0.7);
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    await _animationController.reverse();
    if (mounted) {
      await context.read<OnboardingProvider>().completeCurrentScreenOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        final shouldShow = provider.isShowingOnboarding &&
            provider.currentOnboardingScreen == widget.screenKey;

        return Stack(
          children: [
            widget.child,
            if (shouldShow) _buildOnboardingOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildOnboardingOverlay() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Semi-transparent backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Prevent tap-through
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),
          // Tooltip card
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildTooltipCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipCard() {
    final step = widget.steps[_currentStep];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.shadow(context),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                step.description,
                style: TextStyle(
                  fontSize: 15,
                  color: MinimalColors.textSecondary(context),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentStep ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: index == _currentStep
                          ? LinearGradient(
                              colors: MinimalColors.primaryGradient(context),
                            )
                          : null,
                      color: index == _currentStep
                          ? null
                          : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Saltar',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 15,
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentStep > 0)
                        IconButton(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back),
                          color: MinimalColors.textSecondary(context),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          shadowColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: MinimalColors.primaryGradient(context),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            child: Text(
                              _currentStep == widget.steps.length - 1
                                  ? 'Entendido'
                                  : 'Siguiente',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
