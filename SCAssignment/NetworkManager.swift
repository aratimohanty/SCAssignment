//
//  NetworkManager.swift
//  SCAssignment
//
//  Created by arati mohanty on 2/26/18.
//  Copyright © 2018 arati mohanty. All rights reserved.
//

import UIKit
import Foundation

@objc protocol NetworkmanagerDelegate: class{
    func dataFromServer(response:[String: AnyObject])
    func errorFromServer(error:NSError)
}
class NetworkManager: NSObject {
    var session: URLSession = URLSession.init()
    weak var delegate: NetworkmanagerDelegate?
    func getData(urlString: String) {
        var err:NSError?
        guard let url = NSURL(string: urlString) else {
            err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error: cannot create URL"])
            delegate?.errorFromServer(error: err!)
            return
        }
        let urlRequest = NSURLRequest(url: url as URL)
        
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: { [weak weakSelf = self, weak weakDelegate  = self.delegate] (data, response, error) in
            
            guard error == nil else {
                weakSelf?.delegate?.errorFromServer(error: error! as NSError)
                return
            }
            
            guard let responseData = data else {
                err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error: did not receive data"])
                weakSelf?.delegate?.errorFromServer(error: err!)
                return
            }
            
            do {
                guard let responseFromServer = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "error trying to convert data to JSON"])
                    weakSelf?.delegate?.errorFromServer(error: err!)
                    return
                }
                DispatchQueue.main.async {
                    weakDelegate?.dataFromServer(response:responseFromServer)
                }
            }
            catch  {
                err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "error trying to convert data to JSON"])
                weakSelf?.delegate?.errorFromServer(error: err!)
                return
            }
        })
        task.resume()
    }
}
