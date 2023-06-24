
import Foundation

public extension Bundle {

    var releaseVersionNumber: String? { return infoDictionary?["CFBundleShortVersionString"] as? String }

    var buildVersionNumber: String? { return infoDictionary?["CFBundleVersion"] as? String }
    
    func loadJson<T: Decodable>(from file: String) -> [T] {
        if let url = self.url(forResource: file, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([T].self, from: data)
                return jsonData
            } catch {
                debugPrint("error:\(error)")
                return []
            }
        }
        return []
    }
}
