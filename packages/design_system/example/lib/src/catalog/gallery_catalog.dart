import '../showcases/app_button_showcase.dart';
import '../showcases/app_confirmation_dialog_placeholder.dart';
import '../showcases/app_icon_button_showcase.dart';
import '../showcases/app_list_tile_showcase.dart';
import '../showcases/app_loading_indicator_showcase.dart';
import '../showcases/app_picker_field_showcase.dart';
import '../showcases/app_refresh_indicator_showcase.dart';
import '../showcases/app_text_field_showcase.dart';
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
  GalleryEntry(
    id: 'app_icon_button',
    label: 'AppIconButton',
    category: .actions,
    showcaseBuilder: (context, brightness) =>
        AppIconButtonShowcase(brightness: brightness),
  ),
  GalleryEntry(
    id: 'app_text_field',
    label: 'AppTextField',
    category: .inputs,
    showcaseBuilder: (context, brightness) =>
        AppTextFieldShowcase(brightness: brightness),
  ),
  GalleryEntry(
    id: 'app_picker_field',
    label: 'AppPickerField',
    category: .inputs,
    showcaseBuilder: (context, brightness) =>
        AppPickerFieldShowcase(brightness: brightness),
  ),
  GalleryEntry(
    id: 'app_loading_indicator',
    label: 'AppLoadingIndicator',
    category: .feedback,
    showcaseBuilder: (context, brightness) =>
        AppLoadingIndicatorShowcase(brightness: brightness),
  ),
  GalleryEntry(
    id: 'app_refresh_indicator',
    label: 'AppRefreshIndicator',
    category: .feedback,
    showcaseBuilder: (context, brightness) =>
        AppRefreshIndicatorShowcase(brightness: brightness),
  ),
  GalleryEntry(
    id: 'app_list_tile',
    label: 'AppListTile',
    category: .lists,
    showcaseBuilder: (context, brightness) =>
        AppListTileShowcase(brightness: brightness),
  ),
  GalleryEntry(
    id: 'app_confirmation_dialog',
    label: 'AppConfirmationDialog',
    category: .dialogs,
    showcaseBuilder: (context, brightness) =>
        const AppConfirmationDialogPlaceholder(),
  ),
];
