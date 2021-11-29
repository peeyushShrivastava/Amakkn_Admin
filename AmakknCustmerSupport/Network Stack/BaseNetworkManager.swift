//
//  BaseNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/10/20.
//

import Foundation
import UIKit

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
    static let prodURL = "https://prodsa2.amakkn.com/"
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
    var header: String { get }
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
        request.addValue(header, forHTTPHeaderField: "Content-Type")

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
        var params = delegate?.params
        params?["idToken"] = AppUserDefaults.manager.pushFCMToken
        return params
    }
}

// MARK: - API Method
extension ConfigRequest {
    internal var method: HTTPMethod? {
        return delegate?.method
    }
}

// MARK: - Header Method
extension ConfigRequest {
    internal var header: String {
        return delegate?.header ?? "text/plain"
    }
}

// MARK: - Base Network Manager
class BaseNetworkManager: Transport {
    static let shared = BaseNetworkManager()

    let networkSession: URLSession

    fileprivate init(session: URLSession = .shared) {
        networkSession = session
        AppSession.manager.update(session)
    }

    func fetch(_ request: URLRequest?, successCallBack: @escaping (_ resData: Data?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        guard let request = request else { return }

        networkSession.dataTask(with: request) { [weak self] (resData, response, error) in
            DispatchQueue.main.async {
                guard !AppUserDefaults.manager.forcedLogout else { successCallBack(resData); return }

                if let error = error {
                    failureCallBack(error.localizedDescription)

                    return
                } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    failureCallBack("Backend Error")

                    return
                }

                guard let resData = resData else { return }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                    guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int  else { return }

                    /// Force Log-out
                    if respCode == 1001 {
                        DispatchQueue.main.async {
                            self?.showLoginAlert()
                        }

                        return
                    }

                    successCallBack(resData)
                } catch _ { }
            }
        }.resume()
    }
}

// MARK: - Push LoginVC
extension BaseNetworkManager {
    private func showLoginAlert() {
        guard let window = UIApplication.shared.windows.first else { return }
        guard let tabBarController = window.rootViewController as? MainTabBarController else { return }

        tabBarController.selectedIndex = Utility.shared.getSelectedTab()

        guard let navController = tabBarController.viewControllers?[Utility.shared.getSelectedTab()] as? UINavigationController else { return }

        let alertController = UIAlertController(title: "You are logged out for security reasons. Please Login again.", message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                self?.pushLoginVC(on: navController)
            }
        }))

        navController.present(alertController, animated: true, completion: nil)
    }

    private func pushLoginVC(on navController: UINavigationController) {
        AppUserDefaults.manager.forcedLogout = true

        AppNetworkManager.shared.logout {
            DispatchQueue.main.async {
                AppSession.manager.resetAppSession()
                SocketIOManager.sharedInstance.closeConnection()
                SocketIOManager.sharedInstance.dataProvider.clearCodeData()

                guard let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as? LoginViewController else { return }

                let navigationVC = UINavigationController(rootViewController: loginVC)
                navigationVC.modalPresentationStyle = .fullScreen

                navController.present(navigationVC, animated: true, completion: nil)
            }
        } failureCallBack: { _ in }
    }
}

// MARK: - Generic Decoder
struct ResponseModel<T: Codable>: Codable {
    let resCode: Int?
    let response: T?
    let resStr: String?
}
