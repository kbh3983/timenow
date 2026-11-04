import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_settings_service.dart';
import '../stamps/stamp_text_store.dart';

/// 스탬프 문구 편집 창. 탭한 요소에 해당하는 문구들을 한 번에 편집합니다.
Future<void> showStampTextEditDialog(BuildContext context, String elementKey) async {
  final fields = StampTextStore.fieldsFor(elementKey);
  if (fields == null) return;
  HapticFeedback.selectionClick();
  await showDialog<void>(
    context: context,
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
    final accent = settings.accentColor;

    return AlertDialog(
      backgroundColor: settings.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: settings.borderColor),
      ),
      title: Text(
        '문구 변경',
        style: TextStyle(
          color: settings.textColor,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widget.fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            TextField(
              controller: _controllers[i],
              autofocus: i == 0,
              maxLength: 40,
              textInputAction:
                  i == widget.fields.length - 1 ? TextInputAction.done : TextInputAction.next,
              onSubmitted: i == widget.fields.length - 1 ? (_) => _save() : null,
              style: TextStyle(color: settings.textColor, fontSize: 15),
              cursorColor: accent,
              decoration: InputDecoration(
                labelText: widget.fields.length > 1 ? widget.fields[i].label : null,
                labelStyle: TextStyle(color: settings.subTextColor),
                hintText: widget.fields[i].defaultText.isEmpty
                    ? '자동'
                    : widget.fields[i].defaultText,
                hintStyle: TextStyle(color: settings.subTextColor),
                helperText: widget.fields[i].hint,
                helperMaxLines: 2,
                helperStyle: TextStyle(color: settings.subTextColor, fontSize: 11.5),
                counterStyle: TextStyle(color: settings.subTextColor, fontSize: 11),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _resetToDefault,
          child: Text('기본값', style: TextStyle(color: settings.subTextColor)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: TextStyle(color: settings.subTextColor)),
        ),
        TextButton(
          onPressed: _save,
          child: Text('저장', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

