import AVKit

protocol JamAudioPlayerProtocol: AnyObject, Identifiable {
    var isPlaying: Bool { get }
    var currentAudioURL: URL? { get }
    var duration: TimeInterval? { get }
    var currentTime: TimeInterval? { get }
    func switchMusic(url: URL) throws
    func play()
    func movePlayHead(to time: TimeInterval)
    func pause()
    func stop()
    func getAudioSamples() -> [Float]?
    func setPlaybackRate(rate: Float)
}

final class JamAudioPlayer: JamAudioPlayerProtocol {
    private var audioPlayer: AVAudioPlayer?
    
    var currentAudioURL: URL? {
        audioPlayer?.url
    }
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying == true
    }
    
    var duration: TimeInterval? {
        audioPlayer?.duration
    }
    
    var currentTime: TimeInterval? {
        audioPlayer?.currentTime
    }
    
    func setPlaybackRate(rate: Float) {
        audioPlayer?.rate = rate
    }
    
    func switchMusic(url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.enableRate = true
        audioPlayer?.numberOfLoops = -1 // Infinity loop
    }
    
    func movePlayHead(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func play() {
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func stop() {
        audioPlayer?.stop()
    }

    func getAudioSamples() -> [Float]? {
        guard let url = audioPlayer?.url else {
            return nil
        }
        let file = try? AVAudioFile(forReading: url)
        guard let audioFile = file else { return nil }

        let frameCount = Int(audioFile.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(frameCount)) else {
            assertionFailure()
            return nil
        }
        try? audioFile.read(into: buffer)

        guard let channelData = buffer.floatChannelData else { return nil }
        let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameCount))
        
        return samples
    }
    
    private func compressLargeArray(to itemsCount: Int, array: [Float]) -> [Float] {
        if array.count < itemsCount {
            return array
        }
        let compressStride = array.count / itemsCount
        var result: [Float] = []
        for i in stride(from: 0, to: array.count, by: compressStride) {
            result.append(array[i])
        }
        return result
    }
}
