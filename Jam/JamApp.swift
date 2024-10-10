import SwiftUI

@main
struct JamApp: App {
    @State private var jamAudioPlayer = JamAudioPlayer()
    
    var body: some Scene {
        WindowGroup {
            AudioPlayerView(presenter: AudioPlayerPresenter(audioPlayer: jamAudioPlayer))
        }
    }
}
