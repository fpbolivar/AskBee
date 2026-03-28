import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/speech_service.dart';
import '../../services/llm_service.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSpeaking = false;
  final TextEditingController _textController = TextEditingController();
  late AnimationController _micAnimationController;

  @override
  void initState() {
    super.initState();
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _initServices();
  }

  Future<void> _initServices() async {
    final speechService = context.read<SpeechService>();
    await speechService.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _micAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AskBeeUser?>();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(user),
            
            // Question Counter
            if (user != null) _buildQuestionCounter(user),
            
            // Messages
            Expanded(
              child: _buildMessages(),
            ),
            
            // Input Area
            _buildInputArea(user),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AskBeeUser? user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          
          const Spacer(),
          
          // AskBee Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AskBee',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Premium badge or Sign out
          if (user?.isPremium == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '⭐ Premium',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.workspace_premium, color: AppTheme.primaryYellow),
              onPressed: () => _showPremiumDialog(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCounter(AskBeeUser user) {
    final remaining = user.isPremium
        ? AppConstants.premiumQuestionsPerMonth - user.monthlyPremiumQuestions
        : AppConstants.freeQuestionsPerWeek - user.weeklyFreeQuestions;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt,
            size: 16,
            color: remaining > 0 ? AppTheme.primaryTeal : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            '$remaining questions left',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: remaining > 0 ? AppTheme.primaryTeal : Colors.red,
            ),
          ),
          if (!user.isPremium) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showPremiumDialog(),
              child: Text(
                'Upgrade →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                size: 50,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What do you want to know?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the mic and ask me anything!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.primaryOrange : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg['text'],
                  style: TextStyle(
                    fontSize: 16,
                    color: isUser ? Colors.white : AppTheme.textDark,
                  ),
                ),
                if (!isUser && msg['isSpeaking'] == true) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: 14,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Speaking...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(AskBeeUser? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input (optional)
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Or type your question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitQuestion(user),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Mic button (hero element)
          GestureDetector(
            onTap: () => _startListening(user),
            child: AnimatedBuilder(
              animation: _micAnimationController,
              builder: (context, child) {
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? AppTheme.primaryTeal
                        : _isSpeaking
                            ? AppTheme.primaryPurple
                            : AppTheme.primaryOrange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isLoading || _isSpeaking
                                ? AppTheme.primaryOrange
                                : AppTheme.primaryOrange)
                            .withValues(alpha: 0.3 + (_micAnimationController.value * 0.2)),
                        blurRadius: 12 + (_micAnimationController.value * 8),
                        spreadRadius: _micAnimationController.value * 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isLoading
                        ? Icons.hourglass_empty
                        : _isSpeaking
                            ? Icons.stop
                            : Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startListening(AskBeeUser? user) async {
    if (_isLoading || _isSpeaking) return;
    if (user == null) return;

    // Check question limit
    final authService = context.read<AuthService>();
    final canAsk = await authService.canAskQuestion(user);
    if (!canAsk) {
      _showLimitReachedDialog(user);
      return;
    }

    final speechService = context.read<SpeechService>();
    final text = await speechService.listenForSpeech();
    
    if (text != null && text.isNotEmpty) {
      _textController.text = text;
      _submitQuestion(user);
    }
  }

  Future<void> _submitQuestion(AskBeeUser? user) async {
    if (_isLoading) return;
    if (user == null) return;

    final question = _textController.text.trim();
    if (question.isEmpty) return;

    // Check limit
    final authService = context.read<AuthService>();
    final canAsk = await authService.canAskQuestion(user);
    if (!canAsk) {
      _showLimitReachedDialog(user);
      return;
    }

    setState(() => _isLoading = true);

    // Add user message
    setState(() {
      _messages.add({
        'role': 'user',
        'text': question,
        'isSpeaking': false,
      });
    });
    _textController.clear();

    // Get AI response
    final llmService = context.read<LlmService>();
    final response = await llmService.generateResponse(
      question,
      ageGroup: user.ageGroup,
    );

    // Add assistant message
    setState(() {
      _messages.add({
        'role': 'assistant',
        'text': response ?? 'Sorry, I couldn\'t generate a response.',
        'isSpeaking': false,
      });
    });

    // Increment question count
    await authService.incrementQuestionCount(user.uid, isPremium: user.isPremium);

    setState(() => _isLoading = false);

    // Auto-speak the response
    if (response != null) {
      _speakResponse(response);
    }
  }

  Future<void> _speakResponse(String text) async {
    setState(() {
      _isSpeaking = true;
      final lastIndex = _messages.length - 1;
      if (lastIndex >= 0) {
        _messages[lastIndex]['isSpeaking'] = true;
      }
    });

    final speechService = context.read<SpeechService>();
    await speechService.speak(text);

    setState(() {
      _isSpeaking = false;
      if (_messages.isNotEmpty) {
        _messages[_messages.length - 1]['isSpeaking'] = false;
      }
    });
  }

  void _showLimitReachedDialog(AskBeeUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Question Limit Reached'),
        content: Text(
          user.isPremium
              ? 'You\'ve used all 500 of your monthly questions. They\'ll reset next month!'
              : 'You\'ve used your 10 free questions this week. Upgrade to Premium for 500 questions a month!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          if (!user.isPremium)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showPremiumDialog();
              },
              child: const Text('Upgrade to Premium'),
            ),
        ],
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.star, color: AppTheme.textDark),
            ),
            const SizedBox(width: 12),
            const Text('AskBee Premium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Get more questions and unlock all features!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    '\$9.99',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Text(
                    'per month',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumFeature('✓ 500 questions/month'),
                  _buildPremiumFeature('✓ All age filters'),
                  _buildPremiumFeature('✓ Priority access'),
                  _buildPremiumFeature('✓ No ads (never!)'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement RevenueCat / IAP
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon! 🎉')),
              );
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
