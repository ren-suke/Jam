import SwiftUI

struct AudioPlayerView<Presenter: AudioPlayerPresenterProtocol>: View {
    @StateObject private var presenter: Presenter
    
    init(presenter: Presenter) {
        _presenter = .init(wrappedValue: presenter)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 0) {
                Text(presenter.audioFileName)
                    .padding(.bottom, 12)
                
                VStack(alignment: .trailing, spacing: 4) {
                    AudioSpectrumView(audioSamples: presenter.audioSamples)
                        .background(Color.gray.opacity(0.1))
                        .frame(height: 144)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            AudioPlayerLoopRangeView(
                                audioLoopRange: presenter.audioLoopRange,
                                didChangeAudioLoopRange: { audioLoopRange in
                                    presenter.didChangeAudioLoopRange(range: audioLoopRange)
                                }
                            ))
                        .overlay(
                            AudioPlayerSeekBar(
                                audioDuration: presenter.audioDuration,
                                audioCurrentTime: presenter.audioCurrentTime,
                                didChangeAudioProgressRate: { progressRate in
                                    presenter.didChangeAudioCurrentTime(currentTime: presenter.audioDuration * Double(progressRate))
                                }
                            )
                        )
                        .padding(.horizontal, 16)
                    
                    Text("\(presenter.audioCurrentTime.hhmmss) / \(presenter.audioDuration.hhmmss)")
                        .padding(.trailing, 16)
                }
                .padding(.bottom, 4)
                audioPlayToolbarSection
                    .padding(.bottom, 48)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        presenter.didTapAudioFilesButton()
                    }, label: {
                        Text(Image(systemName: "music.note.list"))
                    })
                }
            }
            .onAppear() {
                presenter.viewDidAppear()
            }
            .sheet(item: $presenter.shouldShowAudioFiles, onDismiss: {
                presenter.onDismissAudioFilesView()
            }) { audioPlayer in
                NavigationStack {
                    AudioFilesView(presenter: AudioFilesPresenter(audioPlayer: audioPlayer))
                }
            }
        }
    }
    
    var audioPlayToolbarSection: some View {
        HStack(alignment: .lastTextBaseline) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Button(action: {
                    presenter.didTapGoBackward10SecondsButton()
                }, label: {
                    Text(Image(systemName: "gobackward.10"))
                        .font(.system(size: 28))
                })
                Button(action: {
                    presenter.didTapPlayPauseButton()
                }, label: {
                    Text(Image(systemName: presenter.isAudioPlaying ? "pause" : "play"))
                        .font(.system(size: 40))
                        .frame(width: 36)
                })
                Button(action: {
                    presenter.didTapGoForward10SecondsButton()
                }, label: {
                    Text(Image(systemName: "goforward.10"))
                        .font(.system(size: 28))
                })
            }.frame(alignment: .center)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .overlay(
            Picker("再生速度", selection: Binding<AudioPlaybackRate>(
                get: { presenter.audioPlaybackRate },
                set: { audioPlaybackRate in
                    presenter.didChange(audioPlaybackRate: audioPlaybackRate)
                }
            )) {
                ForEach(AudioPlaybackRate.allCases, id: \.self) { audioPlayRate in
                    Text(audioPlayRate.displayTitle)
                        .tag(audioPlayRate)
                }
            },
            alignment: .trailingLastTextBaseline
        )
    }
}

extension TimeInterval {
    fileprivate var hhmmss: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        if let hhmmss = formatter.string(from: self) {
            return hhmmss
        }
        return "00:00"
    }
}

#Preview {
    AudioPlayerView(presenter: AudioPlayerPresenter(audioPlayer: JamAudioPlayer()))
}
