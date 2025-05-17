import 'package:flutter/material.dart';

class FunctionEditor extends StatefulWidget {
  final Function(String) onAddFunction;
  final VoidCallback onCancel;
  final bool isDark;

  const FunctionEditor({
    super.key,
    required this.onAddFunction,
    required this.onCancel,
    required this.isDark,
  });

  @override
  _FunctionEditorState createState() => _FunctionEditorState();
}

class _FunctionEditorState extends State<FunctionEditor> {
  late String _currentExpression;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _currentExpression = "";
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Editor de función',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildExpressionInput(isDark),
          const SizedBox(height: 20),
          _buildFunctionButtons(isDark),
          const SizedBox(height: 12),
          _buildNumpad(isDark),
          const SizedBox(height: 20),
          _buildActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildExpressionInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration.collapsed(
          hintText: 'Escribe la función aquí...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
        ),
        style: TextStyle(
          fontSize: 18,
          color: isDark ? Colors.white : Colors.black,
        ),
        onChanged: (text) {
          setState(() {
            _currentExpression = text;
          });
        },
      ),
    );
  }

  Widget _buildFunctionButtons(bool isDark) {
    final functions = [
      {'label': 'sin', 'template': 'sin()'},
      {'label': 'cos', 'template': 'cos()'},
      {'label': 'tan', 'template': 'tan()'},
      {'label': 'logₐ', 'template': 'log(■,■)'},
      {'label': 'ln', 'template': 'ln()'},
      {'label': 'e^', 'template': 'e^'},
      {'label': '^', 'template': '^'},
      {'label': '√', 'template': 'sqrt()'},
      {'label': 'π', 'template': 'π'},
      {'label': 'abs', 'template': 'abs()'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: functions.map((func) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.deepPurple[800] : Colors.deepPurple[50],
            foregroundColor: isDark ? Colors.deepPurple[100] : Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            elevation: 0,
          ),
          onPressed: () => _insertTemplate(func['template']!),
          child: Text(
            func['label']!,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumpad(bool isDark) {
    return Column(
      children: [
        _buildNumpadRow(['7', '8', '9', '(', ')'], isDark),
        _buildNumpadRow(['4', '5', '6', '+', '-'], isDark),
        _buildNumpadRow(['1', '2', '3', '*', '/'], isDark),
        _buildNumpadRow([
          '0',
          'x',
          '⌫',
          '.',
          '='
        ], isDark, specialIndex: 2),
      ],
    );
  }

  Widget _buildNumpadRow(List<String> labels, bool isDark, {int? specialIndex}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: label == '⌫' 
                  ? _removeLast
                  : () => _insertText(label),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    color: index == specialIndex 
                      ? (isDark ? Colors.red[300] : Colors.red)
                      : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: isDark ? Colors.deepPurple[300]! : Colors.deepPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? Colors.deepPurple[300] : Colors.deepPurple,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _currentExpression.isEmpty
                ? null
                : () => widget.onAddFunction(_currentExpression),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.deepPurple : Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Text(
              'Graficar',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _insertTemplate(String template) {
    final cursorPos = _textController.selection.base.offset;
    final newText = _currentExpression.substring(0, cursorPos) +
        template +
        _currentExpression.substring(cursorPos);

    _textController.text = newText;
    _currentExpression = newText;

    // Mover cursor dentro de los paréntesis
    final newCursorPos = cursorPos + template.indexOf(')');
    _textController.selection = TextSelection.collapsed(offset: newCursorPos);
    _focusNode.requestFocus();
  }

  void _insertText(String text) {
    final cursorPos = _textController.selection.base.offset;
    final newText = _currentExpression.substring(0, cursorPos) +
        text +
        _currentExpression.substring(cursorPos);

    _textController.text = newText;
    _currentExpression = newText;
    _textController.selection = TextSelection.collapsed(
      offset: cursorPos + text.length,
    );
    _focusNode.requestFocus();
  }

  void _removeLast() {
    if (_currentExpression.isNotEmpty) {
      final newText = _currentExpression.substring(
        0, _currentExpression.length - 1);
      _textController.text = newText;
      _currentExpression = newText;
      _textController.selection = TextSelection.collapsed(
        offset: newText.length,
      );
      _focusNode.requestFocus();
    }
  }
}