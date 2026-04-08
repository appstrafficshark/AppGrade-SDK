
import UIKit
import AppGradeSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AppGrade.shared.initialize(apiKey: "key", enableLogs: true)
    }


}
