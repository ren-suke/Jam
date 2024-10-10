import SwiftUI

protocol AudioFilesPresenterProtocol: Identifiable, ObservableObject {
    var audioFiles: [URL] { get }
    var shouldDismissSelf: Bool { get }
    
    func viewDidAppear()
    func didSelectAudioFile(fileURL: URL)
}

final class AudioFilesPresenter<AudioPlayer: JamAudioPlayerProtocol>: ObservableObject, AudioFilesPresenterProtocol {
    private var audioPlayer: AudioPlayer
    
    @Published private(set) var audioFiles: [URL] = []
    @Published private(set) var shouldDismissSelf: Bool = false
    
    init(audioPlayer: AudioPlayer) {
        self.audioPlayer = audioPlayer
    }
    
    func viewDidAppear() {
        audioFiles = AppGroupsDataStore.getAllAudioFileURLs()
    }
    
    func didSelectAudioFile(fileURL: URL) {
        do {
            try audioPlayer.switchMusic(url: fileURL)
            shouldDismissSelf = true
        } catch let error {
            print(error)
        }
    }
}
