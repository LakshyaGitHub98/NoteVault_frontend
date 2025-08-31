import 'package:flutter/material.dart';
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

  void _applyStyleToSelection(TextStyle style) {
    final selection = _controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final fullText = _controller.text;
    final selectedText = selection.textInside(fullText);

    String styledText = selectedText;
    // if (style.fontWeight == FontWeight.bold) styledText = "**$styledText**";
    // if (style.fontStyle == FontStyle.italic) styledText = "_$styledText_";
    // if (style.decoration == TextDecoration.underline) styledText = "__$styledText__";

    final newText = selection.textBefore(fullText) + styledText + selection.textAfter(fullText);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.baseOffset + styledText.length),
    );
  }

  void _saveNote() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _filenameController = TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Save File", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _filenameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter filename",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
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

                Navigator.pop(context); // Close dialog

                try {
                  final success = await ApiServices.uploadFile(
                    filename: filename,
                    description: content,
                    userId: widget.userId,
                  );
                  if(!mounted)return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Colors.grey[900],
          child: Row(
            children: [
              _buildFileMenu(),
              _buildMenuItem("Edit"),
              _buildMenuItem("View"),
              _buildMenuItem("Help"),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            child: Row(
              children: [
                _buildToolbarButton("Bold", () {
                  setState(() => isBold = !isBold);
                  _applyStyleToSelection(const TextStyle(fontWeight: FontWeight.bold));
                }),
                _buildToolbarButton("Italic", () {
                  setState(() => isItalic = !isItalic);
                  _applyStyleToSelection(const TextStyle(fontStyle: FontStyle.italic));
                }),
                _buildToolbarButton("Underline", () {
                  setState(() => isUnderline = !isUnderline);
                  _applyStyleToSelection(const TextStyle(decoration: TextDecoration.underline));
                }),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
                ),
                maxLines: null,
                decoration: const InputDecoration.collapsed(
                  hintText: "Start typing...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        child: Text("File", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildMenuItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(label, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}