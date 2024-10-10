import Foundation

struct AppGroupsDataStore {
    private static let appGroupID = "group.com.ren-matsushita.jam"
    private static let localAudioFileURLStringsKey = "AppGroupsDataStore.localAudioFileURLStringsKey"
    
    static func getAllAudioFileURLs() -> [URL] {
        guard let userDefaults = UserDefaults(suiteName: appGroupID) else {
            assertionFailure("AppGroupIDが間違っている")
            return []
        }
        guard let urlStrings = userDefaults.array(forKey: localAudioFileURLStringsKey) as? [String] else {
            return []
        }
        return urlStrings.compactMap(URL.init(string:))
    }
    
    static func getLatestAudioFileURL() -> URL? {
        let audioFileURLs = getAllAudioFileURLs()
        return audioFileURLs.last
    }
}

