//
//  BaseNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/10/20.
//

import Foundation

// MARK: - Data Fetch
protocol Transport {
    func fetch(_ request: URLRequest?,
               successCallBack: @escaping (_ resData: Data?) -> Void,
               failureCallBack: @escaping (_ errorStr: String?) -> Void)
}

// MARK: - App Environment Config
enum Environment: String {
    case dev = "AMK_DEV"
    case prod = "AMK_PROD"
}

// MARK: - Base URL
struct BaseURL {
    static let devURL = "https://devsa1.amakkn.com/"
    static let prodURL = "https://prodsa1.amakkn.com/"
}

// MARK: - Base URL String
var amkBaseURL: String {
    return BaseURL.prodURL
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Config Request Delegate
protocol ConfigRequestDelegate {
    var urlString: String { get }
    var params: [String: Any]? { get }
    var selectedLanguage: String { get }
    var hashedUserID: String { get }
    var method: HTTPMethod { get }
    func getRequest(with endPoint: APIEndPoint) -> URLRequest?
}

// MARK: - Configurable Request
protocol RequestConfigurable {
    var urlString: String { get }
    var request: URLRequest? { get }
    var params: [String: Any]? { get }
    var method: HTTPMethod? { get }
}

// MARK: - API EndPoint
protocol APIEndPoint { }

// MARK: - Config Request
class ConfigRequest: RequestConfigurable {    
    var endPoint: APIEndPoint
    var delegate: ConfigRequestDelegate?

    var request: URLRequest? {
        return createRequest()
    }

    init(_ endPoint: APIEndPoint) {
        self.endPoint = endPoint
    }

    private func createRequest() -> URLRequest? {
        guard let apiURL = URL(string: urlString) else { return nil }

        var request = URLRequest(url: apiURL)
        request.httpMethod = method?.rawValue
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")

        request.httpBody = createRequestBody()

        return request
    }

    private func createRequestBody() -> Data? {
        do {
            if let params = params {
                let data = try JSONSerialization.data(withJSONObject: params, options: [])

                return data
            }
        } catch _ {
            debugPrint("Invalid params")
        }

        return nil
    }
}

// MARK: - API Method
extension ConfigRequest {
    internal var urlString: String {
        if delegate?.urlString.contains("prodchat") ?? false {
            return delegate?.urlString ?? ""
        }

        return amkBaseURL + (delegate?.urlString ?? "")
    }
}

// MARK: - API Method
extension ConfigRequest {
    internal var params: [String: Any]? {
        return delegate?.params
    }
}

// MARK: - API Method
extension ConfigRequest {
    internal var method: HTTPMethod? {
        return delegate?.method
    }
}

// MARK: - Base Network Manager
class BaseNetworkManager: Transport {
    static let shared = BaseNetworkManager()

    let networkSession: URLSession

    fileprivate init(session: URLSession = .shared) {
        networkSession = session
    }

    func fetch(_ request: URLRequest?, successCallBack: @escaping (_ resData: Data?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        guard let request = request else { return }

        networkSession.dataTask(with: request) { (resData, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    failureCallBack(error.localizedDescription)

                    return
                } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    failureCallBack("Backend Error")

                    return
                }

                successCallBack(resData)
            }
        }.resume()
    }
}

// MARK: - Generic Decoder
struct ResponseModel<T: Codable>: Codable {
    let resCode: Int?
    let response: T?
    let resStr: String?
}
