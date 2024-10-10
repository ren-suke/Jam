import SwiftUI

struct AudioPlayerLoopRangeView: View {
    var audioLoopRange: AudioLoopRange
    var didChangeAudioLoopRange: (AudioLoopRange) -> Void
    
    @State private var containerWidth: CGFloat? = nil
    @State private var leftEdgeDraggingPointX: CGFloat? = nil
    @State private var rightEdgeDraggingPointX: CGFloat? = nil
    
    private static let handleWidth: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .onChange(of: proxy.size.width) { _, newValue in
                    containerWidth = newValue
                }
            Color.yellow
                .frame(width: Self.handleWidth)
                .frame(maxHeight: .infinity)
                .offset(x: calculateLeftEdgeOffsetX(containerWidth: proxy.size.width))
                .gesture(leftEdgeDragGesture)
            
            Color.yellow
                .frame(width: Self.handleWidth)
                .frame(maxHeight: .infinity)
                .offset(x: calculateRightEdgeOffsetX(containerWidth: proxy.size.width))
                .gesture(rightEdgeDragGesture)
        }
    }
    
    func calculateLeftEdgeOffsetX(containerWidth: CGFloat) -> CGFloat {
        leftEdgeDraggingPointX ?? containerWidth * audioLoopRange.begenRatioOfAudioDuration
    }
    
    func calculateRightEdgeOffsetX(containerWidth: CGFloat) -> CGFloat {
        min(rightEdgeDraggingPointX ?? containerWidth * audioLoopRange.endRatioOfAudioDuration, containerWidth) - 4
    }


    var leftEdgeDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                leftEdgeDraggingPointX = max(value.location.x, 0)
            }
            .onEnded { value in
                guard let containerWidth,
                      let leftEdgeDraggingPointX else { return }
                didChangeAudioLoopRange(.init(
                    begenRatioOfAudioDuration: leftEdgeDraggingPointX / containerWidth,
                    endRatioOfAudioDuration: audioLoopRange.endRatioOfAudioDuration
                ))
                self.leftEdgeDraggingPointX = nil
            }
    }
    
    var rightEdgeDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                rightEdgeDraggingPointX = value.location.x
            }
            .onEnded { value in
                guard let containerWidth,
                      let rightEdgeDraggingPointX else { return }
                didChangeAudioLoopRange(.init(
                    begenRatioOfAudioDuration: audioLoopRange.begenRatioOfAudioDuration,
                    endRatioOfAudioDuration: rightEdgeDraggingPointX / containerWidth
                ))
                self.rightEdgeDraggingPointX = nil
            }
    }
}

#Preview {
    AudioPlayerLoopRangeView(
        audioLoopRange: .init(begenRatioOfAudioDuration: .zero, endRatioOfAudioDuration: .zero), didChangeAudioLoopRange: { _ in
            
        })
        .padding(.horizontal, 16)
}
