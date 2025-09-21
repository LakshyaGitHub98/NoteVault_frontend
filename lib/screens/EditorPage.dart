import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_vault_frontend/services/ApiServices.dart';

class EditorPage extends StatefulWidget {
  final String userId;
  const EditorPage({super.key, required this.userId});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _controller = TextEditingController();

  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isDark = true;

  final List<String> _history = [];
  int _historyIndex = -1;

  void _applyStyleToSelection(TextStyle style) {
    final selection = _controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final fullText = _controller.text;
    final selectedText = selection.textInside(fullText);

    String styledText = selectedText;
    if (style.fontWeight == FontWeight.bold) styledText = "**$styledText**";
    if (style.fontStyle == FontStyle.italic) styledText = "_$styledText";
    if (style.decoration == TextDecoration.underline) styledText = "__$styledText";

    final newText = selection.textBefore(fullText) + styledText + selection.textAfter(fullText);

    _saveToHistory();

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.baseOffset + styledText.length),
    );
  }

  void _saveToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(_controller.text);
    _historyIndex = _history.length - 1;
  }

  void _undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _controller.text = _history[_historyIndex];
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      _controller.text = _history[_historyIndex];
    }
  }

  void _saveNote() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _filenameController = TextEditingController();

        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text("Save File", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: TextField(
            controller: _filenameController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Enter filename",
              hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                final filename = _filenameController.text.trim();
                final content = _controller.text;

                if (filename.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Filename cannot be empty")),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  final success = await ApiServices.uploadFile(
                    filename: filename,
                    content: content, // ✅ Corrected key
                    userId: widget.userId,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text("Note '$filename' saved successfully")),
                      );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Save failed: $e")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _clearNote() {
    setState(() => _controller.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note cleared")),
    );
  }

  void _showWordCount() {
    final wordCount = _controller.text.trim().split(RegExp(r'\s+')).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Word count: $wordCount")),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: "Note Vault Editor",
      applicationVersion: "1.0.0",
      applicationLegalese: "Made with Flutter 💙",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Editor'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? Colors.grey[900] : Colors.grey[200],
            height: 50,
            child: Row(
              children: [
                _buildFileMenu(),
                _buildEditMenu(),
                _buildViewMenu(),
                _buildHelpMenu(),
              ],
            ),
          ),
          Container(
            color: isDark ? Colors.grey[850] : Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            child: Row(
              children: [
                _buildToolbarButton("Bold", () {
                  setState(() => isBold = !isBold);
                  _applyStyleToSelection(const TextStyle(fontWeight: FontWeight.bold));
                }, isBold),
                _buildToolbarButton("Italic", () {
                  setState(() => isItalic = !isItalic);
                  _applyStyleToSelection(const TextStyle(fontStyle: FontStyle.italic));
                }, isItalic),
                _buildToolbarButton("Underline", () {
                  setState(() => isUnderline = !isUnderline);
                  _applyStyleToSelection(const TextStyle(decoration: TextDecoration.underline));
                }, isUnderline),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
                ),
                maxLines: null,
                decoration: InputDecoration.collapsed(
                  hintText: "Start typing...",
                  hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                ),
                onChanged: (_) => _saveToHistory(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Menus ----------------

  Widget _buildFileMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'Save') {
          _saveNote();
        } else if (value == 'Clear All') {
          _clearNote();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'Save', child: Text('Save')),
        PopupMenuItem(value: 'Clear All', child: Text('Clear All')),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("File", style: TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildEditMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'Undo') _undo();
        else if (value == 'Redo') _redo();
        else if (value == 'Cut') {
          final text = _controller.text;
          Clipboard.setData(ClipboardData(text: text));
          _clearNote();
        } else if (value == 'Copy') {
          Clipboard.setData(ClipboardData(text: _controller.text));
        } else if (value == 'Paste') {
          Clipboard.getData('text/plain').then((clip) {
            if (clip != null) {
              _controller.text += clip.text ?? '';
            }
          });
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'Undo', child: Text('Undo')),
        PopupMenuItem(value: 'Redo', child: Text('Redo')),
        PopupMenuItem(value: 'Cut', child: Text('Cut')),
        PopupMenuItem(value: 'Copy', child: Text('Copy')),
        PopupMenuItem(value: 'Paste', child: Text('Paste')),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("Edit", style: TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildViewMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'Word Count') _showWordCount();
        else if (value == 'Toggle Theme') {
          setState(() => isDark = !isDark);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'Word Count', child: Text('Word Count')),
        PopupMenuItem(value: 'Toggle Theme', child: Text('Toggle Theme')),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("View", style: TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildHelpMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'About') _showAbout();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'About', child: Text('About')),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("Help", style: TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onPressed, bool active) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: TextStyle(color: active ? Colors.blue : Colors.white70, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}