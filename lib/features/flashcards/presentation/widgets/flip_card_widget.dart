import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/flashcard.dart';

/// Cartão interativo que gira em 3D (eixo Y) ao ser tocado,
/// alternando entre a pergunta (frente) e a resposta (verso).
///
/// O cartão ocupa todo o espaço recebido; posicione-o dentro de um widget
/// com tamanho definido (a `StudyScreen` calcula o tamanho de forma responsiva).
class FlipCardWidget extends StatefulWidget {
  /// Flashcard exibido pelo cartão.
  final Flashcard flashcard;

  const FlipCardWidget({super.key, required this.flashcard});

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  static const Color _darkPurple = Color(0xFF4C1D95);
  static const Color _neutralText = Color(0xFF1F2937);
  static const Color _mutedText = Color(0xFF6B7280);

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ao trocar de flashcard, o novo cartão sempre começa pela pergunta.
    if (oldWidget.flashcard.id != widget.flashcard.id) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final status = _controller.status;
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.forward) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTapHint: AppStrings.flipCardHint,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final bool isFront = _animation.value < 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(math.pi * _animation.value),
              child: isFront ? _buildFront() : _buildBack(),
            );
          },
        ),
      ),
    );
  }

  /// Frente do cartão: pergunta sobre fundo branco.
  Widget _buildFront() {
    return _CardSurface(
      backgroundColor: Colors.white,
      borderColor: const Color(0xFFE9E3FB),
      child: _CardContent(
        labelIcon: const Icon(
          Icons.lightbulb_rounded,
          color: Colors.amber,
          size: 20,
        ),
        label: AppStrings.questionLabel,
        labelColor: _darkPurple,
        text: widget.flashcard.question,
        textStyle: const TextStyle(
          fontFamily: AppFonts.poppins,
          color: _neutralText,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        hint: AppStrings.tapToRevealAnswer,
        hintColor: _mutedText,
      ),
    );
  }

  /// Verso do cartão: resposta sobre gradiente roxo → índigo.
  /// As duas cores mantêm contraste ≥ 6,8:1 com o texto branco (WCAG AA),
  /// garantindo leitura confortável em respostas longas.
  /// O conteúdo recebe uma rotação extra de 180° para não aparecer espelhado.
  Widget _buildBack() {
    return _CardSurface(
      gradient: const LinearGradient(
        colors: [Colors.deepPurple, Colors.indigo],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(math.pi),
        child: _CardContent(
          label: AppStrings.answerLabel,
          labelColor: Colors.white,
          text: widget.flashcard.answer,
          textStyle: const TextStyle(
            fontFamily: AppFonts.poppins,
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
          hint: AppStrings.tapToShowQuestion,
          hintColor: Colors.white,
        ),
      ),
    );
  }
}

/// Superfície visual do cartão: bordas arredondadas e sombra suave.
class _CardSurface extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? borderColor;

  const _CardSurface({
    required this.child,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Em cartões baixos (ex.: paisagem), reduz o respiro interno.
        final isCompact = constraints.maxHeight < 320;

        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(isCompact ? 16 : 28),
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(28),
            border:
                borderColor != null ? Border.all(color: borderColor!) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

/// Conteúdo textual do cartão: rótulo, texto principal centralizado e dica.
class _CardContent extends StatelessWidget {
  final Widget? labelIcon;
  final String label;
  final Color labelColor;
  final String text;
  final TextStyle textStyle;
  final String hint;
  final Color hintColor;

  const _CardContent({
    this.labelIcon,
    required this.label,
    required this.labelColor,
    required this.text,
    required this.textStyle,
    required this.hint,
    required this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (labelIcon != null) ...[
              labelIcon!,
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Ocupa o espaço disponível e rola caso o texto seja maior que o cartão.
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Text(text, textAlign: TextAlign.center, style: textStyle),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, size: 16, color: hintColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  color: hintColor,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
