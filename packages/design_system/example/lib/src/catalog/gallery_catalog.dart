import '../showcases/app_button_showcase.dart';
import 'gallery_entry.dart';

/// The full set of design_system widgets tracked by the gallery, in nav
/// order. Entries with no [GalleryEntry.showcaseBuilder] render as
/// not-yet-implemented until a later ticket wires them up.
final List<GalleryEntry> galleryCatalog = [
  GalleryEntry(
    id: 'app_button',
    label: 'AppButton',
    category: .actions,
    showcaseBuilder: (context, brightness) =>
        AppButtonShowcase(brightness: brightness),
  ),
  const GalleryEntry(
    id: 'app_icon_button',
    label: 'AppIconButton',
    category: .actions,
  ),
  const GalleryEntry(
    id: 'app_text_field',
    label: 'AppTextField',
    category: .inputs,
  ),
  const GalleryEntry(
    id: 'app_picker_field',
    label: 'AppPickerField',
    category: .inputs,
  ),
  const GalleryEntry(
    id: 'app_loading_indicator',
    label: 'AppLoadingIndicator',
    category: .feedback,
  ),
  const GalleryEntry(
    id: 'app_refresh_indicator',
    label: 'AppRefreshIndicator',
    category: .feedback,
  ),
  const GalleryEntry(
    id: 'app_list_tile',
    label: 'AppListTile',
    category: .lists,
  ),
  const GalleryEntry(
    id: 'app_confirmation_dialog',
    label: 'AppConfirmationDialog',
    category: .dialogs,
  ),
];
