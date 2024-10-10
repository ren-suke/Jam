import SwiftUI

struct AudioSpectrumView: View {
    var audioSamples: [Float]
    
    private static let interval: CGFloat = 2.0
    private static let lineWidth: CGFloat = 0.7
    
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let y0 = proxy.size.height * 0.5
                var x = 0.0
                let numberOfDisplayableItems = Int(floor(proxy.size.width / Self.interval))
                
                let compressedAudioSamples = compressLargeArray(to: numberOfDisplayableItems, array: audioSamples)
                var levelArray: [CGFloat] = compressedAudioSamples.map(CGFloat.init)
                    .map { sample in
                        // マイナス値の場合最小値がゼロとなるように数値を引き上げる
                        if let audioSampleMinValue = compressedAudioSamples.min(),
                           audioSampleMinValue < 0 {
                            return sample + CGFloat(audioSampleMinValue * -1)
                        }
                        return sample
                    }
                
                guard let levelArrayMaxValue = levelArray.max() else {
                    return
                }
                // TODO: Care 0 division
                let scalingFactor = y0 / levelArrayMaxValue
                levelArray = levelArray.map { $0 * scalingFactor }
                
                for l in levelArray {
                    path.move(
                        to: .init(
                            x: x,
                            y: y0 - l
                        )
                    )
                    path.addLine(
                        to: .init(
                            x: x,
                            y: y0 + l
                        )
                    )
                    x += Self.interval
                }
            }
            .stroke(lineWidth: Self.lineWidth)
            .fill(Color.gray)
        }
    }
    
    private func compressLargeArray(to itemsCount: Int, array: [Float]) -> [Float] {
        if array.count < itemsCount {
            return array
        }
        if itemsCount <= 0 {
            return []
        }
        let compressStride = array.count / itemsCount
        var result: [Float] = []
        for i in stride(from: 0, to: array.count, by: compressStride) {
            result.append(array[i])
        }
        return result
    }
}
