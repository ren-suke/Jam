import SwiftUI

struct AudioFilesView<Presenter: AudioFilesPresenterProtocol>: View {
    @StateObject private var presenter: Presenter
    @Environment(\.dismiss) private var dismiss
    
    init(presenter: Presenter) {
        _presenter = .init(wrappedValue: presenter)
    }
    
    var body: some View {
        ScrollView {
            if presenter.audioFiles.isEmpty {
                Text("曲が保存されていません")
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                    ForEach(presenter.audioFiles, id: \.self) { audioFile in
                        Button(action: {
                            presenter.didSelectAudioFile(fileURL: audioFile)
                        }, label: {
                            Text(audioFile.lastPathComponent)
                                .foregroundColor(.primary)
                                .padding()
                        })
                        Divider()
                    }
                }
            }
        }
        .onAppear {
            presenter.viewDidAppear()
        }
        .navigationTitle("オーディオ選択")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("閉じる")
                }
            }
        }
        .onChange(of: presenter.shouldDismissSelf) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}
