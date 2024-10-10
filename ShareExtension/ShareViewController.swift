import UIKit
import SwiftUI

final class ShareViewController: UIHostingController<ShareView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: ShareView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.presenter.configure(context: extensionContext)
    }
}

