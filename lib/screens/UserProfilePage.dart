import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:note_vault_frontend/screens/EditorPage.dart';
import '/models/FileModel.dart';
import '../services/ApiServices.dart';
import '../services/AuthServices.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String profileImageUrl;

  const UserProfilePage({
    Key? key,
    required this.userId,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? _userId;
  late Future<List<FileModel>> _filesFuture;
  bool _uploading = false;
  bool _ready = false;
  bool _deleting = false;

  // Track files being opened
  final Set<String> _openingFiles = {};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    String? id = widget.userId.trim().isNotEmpty ? widget.userId.trim() : null;
    id ??= await AuthService.getUserId();

    if (!mounted) return;
    if (id == null || id.isEmpty) {
      await AuthService.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    _userId = id;
    _filesFuture = ApiServices.viewAllFiles(userId: _userId!);
    setState(() => _ready = true);
  }

  Future<void> _reloadFiles() async {
    if (_userId == null) return;
    setState(() {
      _filesFuture = ApiServices.viewAllFiles(userId: _userId!);
    });
    await _filesFuture;
  }

  void _createNewFile() {
    if (_userId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(userId: _userId!),
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    if (_userId == null) return;
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final systemFile = File(result.files.single.path!);
      final fileModel = FileModel(
        path: systemFile.path,
        filename: p.basename(systemFile.path),
        username: 'Unknown',
        uploadDate: DateTime.now(),
      );

      setState(() => _uploading = true);
      final success = await ApiServices.uploadFileFromSystem(fileModel, _userId!);
      if (!mounted) return;
      setState(() => _uploading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ File uploaded successfully')),
        );
        await _reloadFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Upload failed')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No file selected')),
      );
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  ImageProvider _avatarProvider() {
    if (widget.profileImageUrl.isNotEmpty) {
      return NetworkImage(widget.profileImageUrl);
    }
    return const AssetImage('assets/icon/avatar_placeholder.png');
  }

  Future<void> _deleteFileDialog(FileModel file) async {
    if (_userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.filename}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      final success = await ApiServices.deleteFile(userId: _userId!, fileId: file.id ?? '');
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted file "${file.filename}"')),
        );
        await _reloadFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete file')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _deleting = false);
    }
  }

  // ---------------- OPEN FILE ----------------
  Future<void> _openFile(FileModel file) async {
    if (_openingFiles.contains(file.id)) return; // Already opening
    setState(() => _openingFiles.add(file.id!));

    try {
      final response = await ApiServices.viewFile(fileId: file.id ?? '');
      final bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${file.filename}';
      final f = File(filePath);
      await f.writeAsBytes(bytes);

      await OpenFilex.open(filePath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _openingFiles.remove(file.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundImage: _avatarProvider(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _createNewFile,
                icon: const Icon(Icons.add),
                label: const Text('Create New File'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: (_uploading || _deleting) ? null : _pickAndUploadFile,
                icon: _uploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_file),
                label: Text(_uploading ? 'Uploading...' : 'Upload from System'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reloadFiles,
              child: FutureBuilder<List<FileModel>>(
                future: _filesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(child: Text('Error: ${snapshot.error}')),
                        ),
                      ],
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: Text('No files found. Pull to refresh.')),
                        ),
                      ],
                    );
                  }

                  final files = snapshot.data!;
                  return ListView.separated(
                    itemCount: files.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final file = files[index];
                      final isOpening = _openingFiles.contains(file.id);

                      return ListTile(
                        leading: isOpening
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.insert_drive_file),
                        title: Text(file.filename),
                        subtitle: Text('Uploaded: ${_formatDate(file.uploadDate)}'),
                        onTap: isOpening ? null : () => _openFile(file),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete File',
                          onPressed: _deleting ? null : () => _deleteFileDialog(file),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
