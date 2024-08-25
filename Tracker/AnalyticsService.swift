import UIKit
import YandexMobileMetrica

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "5118c013-4041-4ea4-890f-2a5371476fa9") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(_ event: String, params : [AnyHashable : Any]) {
            YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            })
        }
}
