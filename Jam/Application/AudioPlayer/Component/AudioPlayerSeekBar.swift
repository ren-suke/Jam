import SwiftUI

struct AudioPlayerSeekBar: View {
    var audioDuration: TimeInterval
    var audioCurrentTime: TimeInterval
    var didChangeAudioProgressRate: (Float) -> Void
    
    @State private var width: CGFloat = 0
    @State private var draggingHandlePoint: CGPoint?
    
    private var audioProgressRate: CGFloat {
        CGFloat(audioCurrentTime / audioDuration)
    }
    
    var body: some View {
        GeometryReader { proxy in
            Color.blue
                .onChange(of: proxy.size.width) { _, newValue in
                    width = newValue
                }
                .frame(width: 2)
                .frame(maxHeight: .infinity)
                .overlay(
                    Circle()
                        .backgroundStyle(Color.blue)
                        .frame(width: 4, height: 5)
                        .offset(y: -2),
                    alignment: .top
                )
                .offset(x: draggingHandlePoint?.x ?? proxy.size.width * audioProgressRate)
                .gesture(dragGesture)
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                draggingHandlePoint = value.location
            }
            .onEnded { value in
                draggingHandlePoint = nil
                didChangeAudioProgressRate(Float(value.location.x / width))
            }
    }
}
