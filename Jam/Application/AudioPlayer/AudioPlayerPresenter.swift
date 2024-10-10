import SwiftUI
import Combine

struct AudioLoopRange {
    var begenRatioOfAudioDuration: TimeInterval
    var endRatioOfAudioDuration: TimeInterval
}

//enum AudioPlayerSheetDestination<AudioPlayer: JamAudioPlayerProtocol>: Identifiable {
//    var id: String {
//        switch self {
//        case .audioFiles: "audioFiles"
//        }
//    }
//    
//    case audioFiles(AudioPlayer)
//}

protocol AudioPlayerPresenterProtocol: ObservableObject {
    associatedtype AudioPlayer: JamAudioPlayerProtocol
    var audioFileName: String { get }
    var isAudioPlaying: Bool { get }
    var audioSamples: [Float] { get }
    var audioDuration: TimeInterval { get }
    var audioCurrentTime: TimeInterval { get }
    var audioLoopRange: AudioLoopRange { get }
    var shouldShowAudioFiles: AudioPlayer? { get set }
    
    func viewDidAppear()
    func onDismissAudioFilesView()
    func switchMusic(with url: URL)
    func didTapGoForward10SecondsButton()
    func didTapGoBackward10SecondsButton()
    func didTapPlayPauseButton()
    func didChangeAudioCurrentTime(currentTime: TimeInterval)
    func didChangeAudioLoopRange(range: AudioLoopRange)
    func didTapAudioFilesButton()
    func didChange(audioPlaybackRate: AudioPlaybackRate)
}

enum AudioPlaybackRate: Float, CaseIterable {
    case x025 = 0.25
    case x05 = 0.5
    case x075 = 0.75
    case `default` = 1
    case x125 = 1.25
    case x15 = 1.5
    case x175 = 1.75
    
    var displayTitle: String {
        switch self {
        case .x025: "×0.25"
        case .x05: "×0.5"
        case .x075: "×0.75"
        case .default: "×1.0"
        case .x125: "×1.25"
        case .x15: "×1.5"
        case .x175: "×1.75"
        }
    }
}

final class AudioPlayerPresenter<AudioPlayer: JamAudioPlayerProtocol>: ObservableObject, AudioPlayerPresenterProtocol {
    var audioPlayer: AudioPlayer
    
    @Published private(set) var audioFileName = ""
    @Published private(set) var isAudioPlaying = false
    @Published private(set) var audioSamples: [Float] = []
    @Published private(set) var audioDuration: TimeInterval = .zero
    @Published private(set) var audioCurrentTime: TimeInterval = .zero
    @Published private(set) var audioLoopRange: AudioLoopRange = .init(begenRatioOfAudioDuration: 0, endRatioOfAudioDuration: 1)
    @Published var shouldShowAudioFiles: AudioPlayer?
    
    private var displayLink: CADisplayLink? = nil
    
    init(audioPlayer: AudioPlayer) {
        self.audioPlayer = audioPlayer
    }
    
    func viewDidAppear() {
        if let url = AppGroupsDataStore.getLatestAudioFileURL() {
            audioFileName = url.lastPathComponent
            switchMusic(with: url)
        }
    }
    
    func onDismissAudioFilesView() {
        guard let duration = audioPlayer.duration,
              let currentTime = audioPlayer.currentTime,
              let audioSamples = audioPlayer.getAudioSamples(),
              let currentAudioURL = audioPlayer.currentAudioURL else { return }
        self.audioSamples = audioSamples
        audioDuration = duration
        audioCurrentTime = currentTime
        audioLoopRange = .init(begenRatioOfAudioDuration: 0, endRatioOfAudioDuration: 1)
        audioFileName = currentAudioURL.lastPathComponent
    }
    
    func switchMusic(with url: URL) {
        do {
            try audioPlayer.switchMusic(url: url)
        } catch let error {
            print(error)
        }
        guard let duration = audioPlayer.duration,
              let currentTime = audioPlayer.currentTime,
              let audioSamples = audioPlayer.getAudioSamples() else { return }
        self.audioSamples = audioSamples
        audioDuration = duration
        audioCurrentTime = currentTime
        audioLoopRange = .init(begenRatioOfAudioDuration: 0, endRatioOfAudioDuration: 1)
    }
    
    func didTapPlayPauseButton() {
        if isAudioPlaying {
            audioPlayer.pause()
            isAudioPlaying = false
            
            displayLink?.invalidate()
        } else {
            audioPlayer.play()
            isAudioPlaying = true
            
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkReceived(displayLink:)))
            displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    func didTapGoBackward10SecondsButton() {
        let timeToMove = audioCurrentTime - 10
        if timeToMove < 0 {
            movePlayHead(to: 0)
        } else {
            movePlayHead(to: timeToMove)
        }
    }
    
    func didTapGoForward10SecondsButton() {
        let timeToMove = audioCurrentTime + 10
        if timeToMove > audioDuration {
            movePlayHead(to: audioDuration)
        } else {
            movePlayHead(to: timeToMove)
        }
    }
    
    func didChangeAudioCurrentTime(currentTime: TimeInterval) {
        movePlayHead(to: currentTime)
    }
    
    func didChangeAudioLoopRange(range: AudioLoopRange) {
        self.audioLoopRange = range
        audioPlayer.movePlayHead(to: audioDuration * range.begenRatioOfAudioDuration)
    }
    
    func didTapAudioFilesButton() {
        shouldShowAudioFiles = audioPlayer
    }
    
    func didChange(audioPlaybackRate: AudioPlaybackRate) {
        audioPlayer.setPlaybackRate(rate: audioPlaybackRate.rawValue)
    }
    
    private func movePlayHead(to time: TimeInterval) {
        audioPlayer.movePlayHead(to: time)
        if !audioPlayer.isPlaying {
            audioCurrentTime = time
        }
    }
    
    @objc private func displayLinkReceived(displayLink: CADisplayLink) {
        guard let currentTime = audioPlayer.currentTime else { return }
        if currentTime >= audioDuration * audioLoopRange.endRatioOfAudioDuration {
            audioPlayer.movePlayHead(to: audioDuration * audioLoopRange.begenRatioOfAudioDuration)
        }
        self.audioCurrentTime = currentTime
    }
}
