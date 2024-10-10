import SwiftUI
import UniformTypeIdentifiers

final class SharePresenter: ObservableObject {
    @Published var audioFileName: String = ""
    private var extensionContext: NSExtensionContext?
    private var url: URL?
    
    @MainActor
    func configure(context: NSExtensionContext?) {
        extensionContext = context
        
        guard let item = context?.inputItems.first as? NSExtensionItem,
              let itemProvider = item.attachments?.first else { return }
        
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.mp3.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.mp3.identifier, options: nil) { [weak self ]data, error in
                guard let self else { return }
                guard let url = data as? URL else { return }
                self.audioFileName = url.lastPathComponent
                self.url = url
            }
        }
    }
    
    func cancel() {
        extensionContext?.cancelRequest(withError: ShareError.cancel)
    }
    
    func save() {
        if let url {
            AppGroupsDataStore.saveAudioFileURL(url: url)
        }
        extensionContext?.completeRequest(returningItems: nil)
    }
    
    enum ShareError: Error {
        case cancel
    }
}
