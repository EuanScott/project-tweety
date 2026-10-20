import AppIntents
import SwiftUI
import WidgetKit

@main
struct NewLogControlsBundle: WidgetBundle {
  var body: some Widget {
    NewLogControl()
  }
}

/// Never change `kind` after release. People who placed the control would
/// lose it.
struct NewLogControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "dev.euanscott.projecttweety.Controls.newLog") {
      ControlWidgetButton(action: CreateLogIntent()) {
        Label("New log", systemImage: "square.and.pencil")
      }
    }
    .displayName("New log")
  }
}
