import Foundation

struct AppGroupsDataStore {
    private static let appGroupID = "group.com.ren-matsushita.jam"
    private static let localAudioFileURLStringsKey = "AppGroupsDataStore.localAudioFileURLStringsKey"
    
    static func saveAudioFileURL(url: URL) {
        guard let userDefaults = UserDefaults(suiteName: appGroupID) else {
            assertionFailure("AppGroupIDが間違っている")
            return
        }
        let array = userDefaults.array(forKey: localAudioFileURLStringsKey) ?? []
        guard let urlStrings = array as? [String] else {
            return
        }
        userDefaults.setValue(urlStrings + [url.absoluteString], forKey: localAudioFileURLStringsKey)
    }
}
