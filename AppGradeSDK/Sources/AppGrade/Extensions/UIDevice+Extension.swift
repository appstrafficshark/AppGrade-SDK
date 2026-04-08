
import UIKit

extension UIDevice {
    
    static var deviceId: String {
        return UIDevice.current.identifierForVendor?.description ?? UUID().description
    }
    
}
