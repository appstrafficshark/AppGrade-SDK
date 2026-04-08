
import Foundation
import UIKit

public class AppGrade {

    public static let shared = AppGrade()
    
    private var configuration: SDKConfiguration?
    private var core: AppGradeCore?
    
    private init() {}
    
    public func initialize(apiKey: String, enableLogs: Bool = false) {
        let config = SDKConfiguration(apiKey: apiKey, enableLogs: enableLogs)
        self.configuration = config
        self.core = AppGradeCore(configuration: config)
        core?.start()
    }
    
}
