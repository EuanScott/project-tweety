/// Categories used to group widgets in the component gallery's nav.
enum GalleryCategory {
  actions('Actions'),
  inputs('Inputs'),
  feedback('Feedback'),
  lists('Lists'),
  dialogs('Dialogs');

  new(this.label);

  final String label;
}
