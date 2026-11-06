import SwiftUI

@main
struct DL7CompanionApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            DL7PremiumView()
            #else
            DL7HomeView()
            #endif
        }
    }
}
