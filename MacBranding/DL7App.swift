import SwiftUI

@main
struct DL7App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var permissions = PermissionCenter()
    @State private var exclusions = ExclusionStore()

    var body: some Scene {
        Window("DL7 CLEANING", id: "main") {
            RootView()
                .environment(permissions)
                .environment(exclusions)
                .frame(minWidth: 900, minHeight: 600)
        }
        .defaultSize(width: 1040, height: 700)
        .windowResizability(.contentMinSize)

        Settings {
            SettingsView().environment(exclusions)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
