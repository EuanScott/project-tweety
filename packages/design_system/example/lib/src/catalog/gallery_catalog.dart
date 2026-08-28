import '../showcases/app_button_showcase.dart';
import '../showcases/app_confirmation_dialog_showcase.dart';
import '../showcases/app_icon_button_showcase.dart';
import '../showcases/app_list_tile_showcase.dart';
import '../showcases/app_loading_indicator_showcase.dart';
import '../showcases/app_picker_field_showcase.dart';
import '../showcases/app_refresh_indicator_showcase.dart';
import '../showcases/app_segmented_control_showcase.dart';
import '../showcases/app_switch_showcase.dart';
import '../showcases/app_text_field_showcase.dart';
import 'gallery_entry.dart';

/// The full set of design_system widgets tracked by the gallery, in nav
/// order.
final List<GalleryEntry> galleryCatalog = [
  GalleryEntry(
    id: 'app_button',
    label: 'AppButton',
    category: .actions,
    showcaseBuilder: (context) => const AppButtonShowcase(),
  ),
  GalleryEntry(
    id: 'app_icon_button',
    label: 'AppIconButton',
    category: .actions,
    showcaseBuilder: (context) => const AppIconButtonShowcase(),
  ),
  GalleryEntry(
    id: 'app_text_field',
    label: 'AppTextField',
    category: .inputs,
    showcaseBuilder: (context) => const AppTextFieldShowcase(),
  ),
  GalleryEntry(
    id: 'app_picker_field',
    label: 'AppPickerField',
    category: .inputs,
    showcaseBuilder: (context) => const AppPickerFieldShowcase(),
  ),
  GalleryEntry(
    id: 'app_switch',
    label: 'AppSwitch',
    category: .inputs,
    showcaseBuilder: (context) => const AppSwitchShowcase(),
  ),
  GalleryEntry(
    id: 'app_segmented_control',
    label: 'AppSegmentedControl',
    category: .inputs,
    showcaseBuilder: (context) => const AppSegmentedControlShowcase(),
  ),
  GalleryEntry(
    id: 'app_loading_indicator',
    label: 'AppLoadingIndicator',
    category: .feedback,
    showcaseBuilder: (context) => const AppLoadingIndicatorShowcase(),
  ),
  GalleryEntry(
    id: 'app_refresh_indicator',
    label: 'AppRefreshIndicator',
    category: .feedback,
    showcaseBuilder: (context) => const AppRefreshIndicatorShowcase(),
  ),
  GalleryEntry(
    id: 'app_list_tile',
    label: 'AppListTile',
    category: .lists,
    showcaseBuilder: (context) => const AppListTileShowcase(),
  ),
  GalleryEntry(
    id: 'app_confirmation_dialog',
    label: 'AppConfirmationDialog',
    category: .dialogs,
    showcaseBuilder: (context) => const AppConfirmationDialogShowcase(),
  ),
];
