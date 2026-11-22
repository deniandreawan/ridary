import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            HomeView()
                .toolbar(.hidden, for: .navigationBar)
        }
        .tint(RidaryTheme.accent)
    }
}
