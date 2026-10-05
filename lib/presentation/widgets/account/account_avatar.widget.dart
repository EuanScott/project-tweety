import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/l10n/app_localizations.dart';

/// The signed-in person's picture in a circle of [size].
///
/// It shows the Profile photo, or the initials on `primary` when there is no
/// photo, or a person icon when there is no name either. While the photo
/// loads, and if it fails, the fallback shows instead: never a broken image.
class const AccountAvatar({
  required final Profile profile,
  required final double size,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final photoUrl = profile.photoUrl;
    final initials = profile.initials;

    return Semantics(
      label: photoUrl == null
          ? l10n.accountNoPhotoLabel
          : l10n.accountPhotoLabel,
      image: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: colorScheme.primary,
                child: Center(
                  child: initials == null
                      ? Icon(
                          Icons.person,
                          size: 0.6 * size,
                          color: colorScheme.onPrimary,
                        )
                      : Text(
                          initials,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 0.4 * size,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              if (photoUrl != null)
                Image.network(
                  photoUrl.toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
