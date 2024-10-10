import SwiftUI

struct ShareView: View {
    @ObservedObject var presenter = SharePresenter()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 0) {
                Text(presenter.audioFileName)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        presenter.cancel()
                    } label: {
                        Text("キャンセル")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        presenter.save()
                    } label: {
                        Text("保存")
                    }
                }
            }
        }
    }
}
