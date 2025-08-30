import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _controller = TextEditingController();
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;

  TextStyle get _currentStyle {
    return TextStyle(
      color: Colors.white,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
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
              _buildMenuItem("File", onTap: _saveNote),
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
                }),
                _buildToolbarButton("Italic", () {
                  setState(() => isItalic = !isItalic);
                }),
                _buildToolbarButton("Underline", () {
                  setState(() => isUnderline = !isUnderline);
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
                style: _currentStyle,
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

  Widget _buildMenuItem(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  void _saveNote() {
    final text = _controller.text;
    print("Saving note: $text");
    // TODO: Send to backend or save locally
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note saved")),
    );
  }
}