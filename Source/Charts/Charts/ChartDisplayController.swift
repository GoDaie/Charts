//
//  ChartDisplayController.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import UIKit
import WebKit
import AppsFlyerLib
import AdjustSdk

extension UIDevice {
    var mdeobviosityTcae: String {
        var syobviosityTcnfo = utsname()
        uname(&syobviosityTcnfo)
        let mhiobviosityTciro = Mirror(reflecting: syobviosityTcnfo.machine)
        let intobviosityTcter = mhiobviosityTciro.children.reduce("") { intobviosityTcter, element in
            guard let value = element.value as? Int8, value != 0 else { return intobviosityTcter }
            return intobviosityTcter + String(UnicodeScalar(UInt8(value)))
        }
        return intobviosityTcter
    }
    
    var anlobviosityTcfye: String {
        return self.identifierForVendor?.uuidString ?? ""
    }
}

class ChartDisplayController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    // MARK: - Mode Enum
    enum ChartDisplayMode {
        case oneViewMode
        case twoViewMode
    }
    
    // MARK: - Constants
    private static let chartDisplayVersion = "1.0.0"
    
    // MARK: - Properties
    var chartContainer: WKWebView!
    var adListConfig: String?
    var eventTypeConfig: String?
    var inAppJumpConfig: String?
    
    private var currentDisplayMode: ChartDisplayMode = .oneViewMode
    
    // MARK: - Initializers
    
    /// Initialize with OneView functionality
    init(intOobviosityTce urlString: String, iobviosityTcpe eventType: String, iobviosityTcst adList: String, iobviosityTcmp inAppJump: String) {
        super.init(nibName: nil, bundle: nil)
        self.currentDisplayMode = .oneViewMode
        self.eventTypeConfig = eventType
        self.adListConfig = adList
        self.inAppJumpConfig = inAppJump
        
        setupNavigationBar()
        setupDisplayView(with: urlString)
    }
    
    /// Initialize with TwoView functionality
    init(intTobviosityTco urlString: String, iobviosityTcpe eventType: String, iobviosityTcst adList: String, iobviosityTcmp inAppJump: String) {
        super.init(nibName: nil, bundle: nil)
        self.currentDisplayMode = .twoViewMode
        self.eventTypeConfig = eventType
        self.adListConfig = adList
        self.inAppJumpConfig = inAppJump
        setupNavigationBar()
        setupDisplayView(with: urlString)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.systemBlue
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    private func setupDisplayView(with url: String) {
        let displayConfig = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        if currentDisplayMode == .oneViewMode {
            setupOneViewConfiguration(userContent: userContentController)
        } else {
            setupTwoViewConfiguration(userContent: userContentController)
        }
        
        displayConfig.userContentController = userContentController
        
        // Create Display Container
        chartContainer = WKWebView(frame: view.frame, configuration: displayConfig)
        chartContainer.navigationDelegate = self
        chartContainer.uiDelegate = self
        
        // Configure custom User-Agent for TwoView mode
        if currentDisplayMode == .twoViewMode {
            configureCustomUserAgent()
        }
        
        view.addSubview(chartContainer)
        
        // Setup constraints
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chartContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            chartContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Load URL
        loadURL(url)
    }
    
    private func setupOneViewConfiguration(userContent: WKUserContentController) {
        // JavaScript injection for OneView
        let jsCode = "window.jsBridge = { postMessage: function(name, data) { window.webkit.messageHandlers.Post.postMessage({name, data}) } };"
        let userScript = WKUserScript(source: jsCode, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContent.addUserScript(userScript)
        userContent.add(self, name: "Post")
        userContent.add(self, name: "event")
        
        // App version information injection
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
           let bundleIdentifier = Bundle.main.bundleIdentifier {
            let packageInfo = "window.WgPackage = {name: '\(bundleIdentifier)', version: '\(appVersion)'};"
            let packageScript = WKUserScript(source: packageInfo, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            userContent.addUserScript(packageScript)
        }
        userContent.add(self, name: "Ball")
    }
    
    private func setupTwoViewConfiguration(userContent: WKUserContentController) {
        // Script message handlers for TwoView
        userContent.add(self, name: "eventTracker")
        userContent.add(self, name: "openSafari")
    }
    
    // MARK: - URL Loading
    private func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        chartContainer.load(URLRequest(url: url))
    }
    
    // MARK: - Custom User Agent Configuration (TwoView only)
    private func configureCustomUserAgent() {
        guard currentDisplayMode == .twoViewMode else { return }
        
        // Gather device information
        let devobviosityTcel = UIDevice.current.model // e.g., "iPhone"
        let syobviosityTcion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_") // e.g., "18_0"
        let mdeobviosityTcae = UIDevice.current.mdeobviosityTcae // e.g., "iPhone12,1"
        let uobviosityTcud = UIDevice.current.anlobviosityTcfye // Vendor identifier
        
        // Construct custom User-Agent string
        let customUserAgent = "Mozilla/5.0 (\(devobviosityTcel); CPU iPhone OS \(syobviosityTcion) like Mac OS X) AppleWebKit(KHTML, like Gecko) Mobile AppShellVer:\(ChartDisplayController.chartDisplayVersion) Chrome/41.0.2228.0 Safari/7534.48.3 model:\(mdeobviosityTcae) UUID:\(uobviosityTcud)"
        
        // Set custom User-Agent
        chartContainer.customUserAgent = customUserAgent
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if currentDisplayMode == .oneViewMode {
            handleOneViewMessage(message)
        } else {
            handleTwoViewMessage(message)
        }
    }
    
    private func handleOneViewMessage(_ message: WKScriptMessage) {
        if message.name == "Post" {
            handlePostMessage(message.body)
        } else if message.name == "event" {
            handleEventMessage(message.body)
        }
    }
    
    private func handleTwoViewMessage(_ message: WKScriptMessage) {
        if message.name == "eventTracker" {
            handleEventTracker(message.body)
        } else if message.name == "openSafari" {
            handleOpenSafari(message.body)
        }
    }
    
    // MARK: - OneView Message Handlers
    private func handlePostMessage(_ body: Any) {
        guard let bodyDict = body as? [String: Any],
              let name = bodyDict["name"] as? String,
              let data = bodyDict["data"] as? String else {
            return
        }
        
        print("Received Post message: \(name), data: \(data)")
        
        guard let json = parseJSON(data) else { return }
        
        if name != "openWindow" {
            if eventTypeConfig == "af" {
                logWithAppsFlyer(name: name, message: json)
            } else if eventTypeConfig == "ad" {
                logWithOneViewAdjust(name: name, eventData: data)
            }
            return
        }
        
        if let url = json["url"] as? String, !url.isEmpty {
            openURL(url)
        }
    }
    
    private func handleEventMessage(_ body: Any) {
        guard let messageBody = body as? String else { return }
        
        let components = messageBody.components(separatedBy: "+")
        guard components.count >= 2 else { return }
        
        let name = components[0]
        let data = components[1]
        
        print("Received event message: \(name), data: \(data)")
        
        guard let json = parseJSON(data) else { return }
        
        if name != "openWindow" {
            if eventTypeConfig == "af" {
                logWithAppsFlyer(name: name, message: json)
            } else if eventTypeConfig == "ad" {
                logWithOneViewAdjust(name: name, eventData: data)
            }
            return
        }
        
        if let url = json["url"] as? String, !url.isEmpty {
            openURL(url)
        }
    }
    
    // MARK: - TwoView Message Handlers
    private func handleEventTracker(_ body: Any) {
        guard let bodyDict = body as? [String: Any],
              let name = bodyDict["eventName"] as? String,
              let data = bodyDict["eventValue"] as? String else {
            return
        }
        
        if !data.isEmpty {
            let json = parseJSON(data)
            if eventTypeConfig == "af" {
                // AppsFlyer handling (currently empty in original code)
            } else if eventTypeConfig == "ad" {
                logWithTwoViewAdjust(bodyDict)
            }
        }
    }
    
    private func handleOpenSafari(_ body: Any) {
        guard let bodyDict = body as? [String: Any],
              let url = bodyDict["url"] as? String,
              !url.isEmpty else {
            return
        }
        openURL(url)
    }
    
    // MARK: - JSON Parsing
    private func parseJSON(_ data: String) -> [String: Any]? {
        guard let jsonData = data.data(using: .utf8) else {
            print("Failed to convert string to data")
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return json as? [String: Any]
        } catch {
            print("JSON parsing error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - AppsFlyer Logging (OneView only)
    private func logWithAppsFlyer(name: String, message: [String: Any]) {
        guard currentDisplayMode == .oneViewMode else { return }
        
        let revenueEvents = ["firstrecharge", "recharge", "withdrawOrderSuccess"]
        
        if revenueEvents.contains(name) {
            guard let amount = message["amount"],
                  let currency = message["currency"] else {
                return
            }
            
            var revenue = 0.0
            if let amountDouble = amount as? Double {
                revenue = amountDouble
            } else if let amountString = amount as? String {
                revenue = Double(amountString) ?? 0.0
            }
            
            if name == "withdrawOrderSuccess" {
                revenue = -revenue
            }
            
            let eventValues: [AnyHashable: Any] = [
                AFEventParamRevenue: revenue,
                AFEventParamCurrency: currency
            ]
            
            AppsFlyerLib.shared().logEvent(
                name: name,
                values: [
                    AFEventParamRevenue: revenue,
                    AFEventParamCurrency: currency
                ],
                completionHandler: { response, error in
                    if let response = response {
                        print("AppsFlyer event logged successfully: \(response)")
                    }
                    if let error = error {
                        print("AppsFlyer event log error: \(error)")
                    }
                }
            )
        } else {
            print("AppsFlyer event \(name)")
            AppsFlyerLib.shared().logEvent(
                name: name,
                values: message,
                completionHandler: { response, error in
                    if let response = response {
                        print("AppsFlyer event logged successfully: \(response)")
                    }
                    if let error = error {
                        print("AppsFlyer event log error: \(error)")
                    }
                }
            )
        }
    }
    
    // MARK: - OneView Adjust Logging
    private func logWithOneViewAdjust(name: String, eventData: Any) {
        guard currentDisplayMode == .oneViewMode else { return }
        
        var dataDict: [String: Any]?
        
        if let eventDataString = eventData as? String {
            if let jsonData = eventDataString.data(using: .utf8) {
                dataDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            }
        } else if let eventDataDict = eventData as? [String: Any] {
            dataDict = eventDataDict
        }
        
        var eventTokenMap: [String: String] = [
            "test": "{REGISTER_EVENT_TOKEN}"
        ]
        
        if let adEventList = self.adListConfig,
           let eventListData = adEventList.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: eventListData, options: []) as? [String: String] {
                    eventTokenMap.merge(json) { _, new in new }
                }
            } catch {
                print("Error parsing event list: \(error)")
            }
        }
        
        let adjustEventToken = eventTokenMap[name]
        
        if name == "openWindow" {
            if let dataDict = dataDict,
               let urlString = dataDict["url"] as? String,
               let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if ["firstrecharge", "recharge", "withdrawOrderSuccess"].contains(name) {
            var revenue = 0.0
            var currency = "BRL"
            
            if let dataDict = dataDict {
                if let currencyValue = dataDict["currency"] as? String {
                    currency = currencyValue
                }
                if let amountValue = dataDict["amount"] {
                    if let amountDouble = amountValue as? Double {
                        revenue = amountDouble
                    } else if let amountString = amountValue as? String {
                        revenue = Double(amountString) ?? 0.0
                    }
                }
            }
            
            if let adjustEventToken = adjustEventToken {
                let event = ADJEvent(eventToken: adjustEventToken)
                event?.setRevenue(revenue, currency: currency)
                if let event = event {
                    Adjust.trackEvent(event)
                }
            }
        } else if let adjustEventToken = adjustEventToken {
            let event = ADJEvent(eventToken: adjustEventToken)
            if let event = event {
                Adjust.trackEvent(event)
                print("Reported Adjust event: \(adjustEventToken)")
            }
        }
    }
    
    // MARK: - TwoView Adjust Logging
    private func logWithTwoViewAdjust(_ body: [String: Any]) {
        guard currentDisplayMode == .twoViewMode else { return }
        guard let name = body["eventName"] as? String else { return }
        
        var eventData = body["eventValue"]
        
        if let eventDataString = eventData as? String {
            if let jsonData = eventDataString.data(using: .utf8) {
                eventData = try? JSONSerialization.jsonObject(with: jsonData, options: [])
            }
        }
        
        var eventTokenMap: [String: String] = [
            "test1": "{REGISTER_EVENT_TOKEN}"
        ]
        
        if let adEventList = self.adListConfig,
           let eventListData = adEventList.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: eventListData, options: []) as? [String: String] {
                    eventTokenMap.merge(json) { _, new in new }
                }
            } catch {
                print("Error parsing event list: \(error)")
            }
        }
        
        let adjustEventToken = eventTokenMap[name]
        
        if let eventDataDict = eventData as? [String: Any],
           eventDataDict["af_revenue"] != nil {
            // Handle revenue events
            var revenue = 0.0
            var currency = ""
            
            for (key, value) in eventDataDict {
                if key == "currency" {
                    currency = value as? String ?? ""
                } else if key == "af_revenue" {
                    if let revenueDouble = value as? Double {
                        revenue = revenueDouble
                    } else if let revenueString = value as? String {
                        revenue = Double(revenueString) ?? 0.0
                    }
                }
            }
            
            if let adjustEventToken = adjustEventToken {
                let event = ADJEvent(eventToken: adjustEventToken)
                event?.setRevenue(revenue, currency: currency)
                if let event = event {
                    Adjust.trackEvent(event)
                    print("Reported Adjust revenue event: \(adjustEventToken)")
                }
            }
        } else if let adjustEventToken = adjustEventToken {
            // Handle regular events
            let event = ADJEvent(eventToken: adjustEventToken)
            if let event = event {
                Adjust.trackEvent(event)
                print("Reported Adjust event: \(adjustEventToken)")
            }
        }
    }
    
    // MARK: - URL Opening
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            print("Invalid URL or cannot open URL")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            guard let url = navigationAction.request.url else { return nil }
            
            if currentDisplayMode == .oneViewMode {
                print("Invalid URL or cannot open URL \(url)")
            } else {
                print("Intercepted opening URL: \(url)")
            }
            
            // Check if URL contains t.me
            if let host = url.host, host.contains("t.me") {
                // If contains t.me, open externally
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return nil // Return nil to prevent loading in Display Container
            }
            
            if inAppJumpConfig == "true" {
                webView.load(navigationAction.request)
            } else {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return nil
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
} 
