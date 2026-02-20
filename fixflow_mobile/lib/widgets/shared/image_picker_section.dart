import 'dart:io';
import 'package:fixflow_core/fixflow_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ImagePickerSection extends StatelessWidget {
  final List<XFile> pickedFiles;
  final List<RequestImageResponse> existingImages;
  final String baseUrl;
  final bool enabled;
  final ValueChanged<List<XFile>> onPickedChanged;
  final ValueChanged<int>? onExistingRemoved;

  static const int maxImages = 5;
  static const int maxSizeMb = 5;
  static const _allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

  const ImagePickerSection({
    super.key,
    required this.pickedFiles,
    this.existingImages = const [],
    this.baseUrl = '',
    this.enabled = true,
    required this.onPickedChanged,
    this.onExistingRemoved,
  });

  int get _totalCount => existingImages.length + pickedFiles.length;
  bool get _canAdd => _totalCount < maxImages && enabled;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (image == null) return;

    final ext = '.${image.name.split('.').last.toLowerCase()}';
    if (!_allowedExtensions.contains(ext)) return;

    final size = await image.length();
    if (size > maxSizeMb * 1024 * 1024) return;

    onPickedChanged([...pickedFiles, image]);
  }

  void _removePicked(int index) {
    final updated = [...pickedFiles]..removeAt(index);
    onPickedChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Slike', style: theme.textTheme.labelLarge),
            const SizedBox(width: 8),
            Text(
              '($_totalCount/$maxImages)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...existingImages.asMap().entries.map(
                    (entry) => _ExistingThumbnail(
                      url: '$baseUrl${entry.value.imagePath}',
                      onRemove: enabled && onExistingRemoved != null
                          ? () => onExistingRemoved!(entry.value.id)
                          : null,
                    ),
                  ),
              ...pickedFiles.asMap().entries.map(
                    (entry) => _FileThumbnail(
                      file: File(entry.value.path),
                      onRemove: enabled ? () => _removePicked(entry.key) : null,
                    ),
                  ),
              if (_canAdd) _AddButton(onTap: _pickImage),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExistingThumbnail extends StatelessWidget {
  final String url;
  final VoidCallback? onRemove;

  const _ExistingThumbnail({required this.url, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _ThumbnailWrapper(
      onRemove: onRemove,
      child: Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ErrorPlaceholder(),
      ),
    );
  }
}

class _FileThumbnail extends StatelessWidget {
  final File file;
  final VoidCallback? onRemove;

  const _FileThumbnail({required this.file, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _ThumbnailWrapper(
      onRemove: onRemove,
      child: Image.file(
        file,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ErrorPlaceholder(),
      ),
    );
  }
}

class _ThumbnailWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRemove;

  const _ThumbnailWrapper({required this.child, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.x,
                    size: 14,
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.plus,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              'Dodaj',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(LucideIcons.imageOff, size: 20),
    );
  }
}
