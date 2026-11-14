import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_localizations.dart';
import '../services/app_settings_service.dart';
import '../stamps/stamp_text_store.dart';

/// 스탬프 문구 편집 하단 시트. 탭한 요소에 해당하는 문구들을 한 번에 편집합니다.
Future<void> showStampTextEditDialog(BuildContext context, String elementKey) async {
  final fields = StampTextStore.fieldsFor(elementKey);
  if (fields == null) return;
  HapticFeedback.selectionClick();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    showDragHandle: false,
    sheetAnimationStyle: AnimationStyle(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
    ),
    builder: (context) => _StampTextEditDialog(fields: fields),
  );
}

class _StampTextEditDialog extends StatefulWidget {
  final List<StampTextField> fields;
  const _StampTextEditDialog({required this.fields});

  @override
  State<_StampTextEditDialog> createState() => _StampTextEditDialogState();
}

class _StampTextEditDialogState extends State<_StampTextEditDialog> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final store = StampTextStore();
    _controllers = widget.fields
        .map((f) => TextEditingController(
              text: store.customText(f.key) ?? (f.clearOnEditIfDefault ? '' : f.defaultText),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetToDefault() {
    HapticFeedback.lightImpact();
    setState(() {
      for (var i = 0; i < widget.fields.length; i++) {
        final f = widget.fields[i];
        _controllers[i].text = f.clearOnEditIfDefault ? '' : f.defaultText;
      }
    });
  }

  Future<void> _save() async {
    final values = <String, String>{};
    for (var i = 0; i < widget.fields.length; i++) {
      values[widget.fields[i].key] = _controllers[i].text;
    }
    await StampTextStore().saveAll(values);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService();
    final isLight = settings.isLight;
    final accent = settings.accentColor;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF17191E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isLight
              ? const Color(0xFFE2E4E8)
              : const Color(0xFF2E323A).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 드래그 핸들
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isLight
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF2E323A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 헤더 & 기본값 복원 버튼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.editStampTextTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: isLight ? const Color(0xFF111418) : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.editStampTextSubtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isLight
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF9AA1AC),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _resetToDefault,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 15,
                          color: isLight
                              ? const Color(0xFF64748B)
                              : const Color(0xFF9AA1AC),
                        ),
                        label: Text(
                          AppStrings.restoreDefault,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isLight
                                ? const Color(0xFF64748B)
                                : const Color(0xFF9AA1AC),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 입력 필드 목록
                  for (var i = 0; i < widget.fields.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    if (widget.fields.length > 1) ...[
                      Text(
                        widget.fields[i].label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? const Color(0xFF475569)
                              : const Color(0xFF9AA1AC),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    TextField(
                      controller: _controllers[i],
                      autofocus: i == 0,
                      maxLength: 40,
                      textInputAction: i == widget.fields.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      onSubmitted:
                          i == widget.fields.length - 1 ? (_) => _save() : null,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 14,
                        color: isLight
                            ? const Color(0xFF111418)
                            : const Color(0xFFF4F6F8),
                      ),
                      cursorColor: accent,
                      decoration: InputDecoration(
                        hintText: widget.fields[i].defaultText.isEmpty
                            ? AppStrings.autoTextHint
                            : widget.fields[i].defaultText,
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isLight
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF9AA1AC).withValues(alpha: 0.6),
                        ),
                        helperText: widget.fields[i].hint,
                        helperMaxLines: 2,
                        helperStyle: TextStyle(
                          fontSize: 11.5,
                          color: isLight
                              ? const Color(0xFF64748B)
                              : const Color(0xFF9AA1AC),
                        ),
                        counterStyle: TextStyle(
                          fontSize: 11,
                          color: isLight
                              ? const Color(0xFF64748B)
                              : const Color(0xFF9AA1AC),
                        ),
                        suffixIcon: _controllers[i].text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  size: 18,
                                  color: isLight
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controllers[i].clear();
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isLight
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF22252C),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isLight
                                ? const Color(0xFFE2E4E8)
                                : const Color(0xFF2E323A).withValues(alpha: 0.35),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isLight
                                ? const Color(0xFFE2E4E8)
                                : const Color(0xFF2E323A).withValues(alpha: 0.35),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: accent,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // 하단 취소 / 저장 버튼
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: isLight
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF2E323A).withValues(alpha: 0.5),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            AppStrings.cancel,
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFF4F6F8),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: accent.computeLuminance() > 0.6
                                ? Colors.black
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _save,
                          child: Text(
                            AppStrings.save,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
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

