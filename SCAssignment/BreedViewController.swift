//
//  BreedViewController.swift
//  SCAssignment
//
//  Created by arati mohanty on 2/26/18.
//  Copyright © 2018 arati mohanty. All rights reserved.
//

import UIKit

class BreedViewController: UIViewController {

    @IBOutlet weak var subBreedTable: UITableView!
    @IBOutlet weak var breedImageView: UIImageView!
    
    var breedName = ""
    var subBreedsArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateView() {
        self.title = breedName
        if let imageData = imageDict[breedName] {
            let image = UIImage(data: imageData)
            breedImageView.image = image
        } else {
            DispatchQueue.global(qos: .default).async {
                let urlString = "https://dog.ceo/api/breed/" + self.breedName + "/images/random"
                let networkManager = NetworkManager()
                networkManager.delegate = self
                networkManager.getData(urlString: urlString)
            }
        }
        DispatchQueue.global(qos: .default).async {
            let urlString = "https://dog.ceo/api/breed/" + self.breedName + "/list"
            let networkManager = NetworkManager()
            networkManager.delegate = self
            networkManager.getData(urlString: urlString)
        }
    }
}

extension BreedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subBreedsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath as IndexPath)
        cell.textLabel?.text = subBreedsArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard.init(name:"Main", bundle: nil)
        let subBreedVC = sb.instantiateViewController(withIdentifier: "SubBreedsView") as! SubBreedViewController
        subBreedVC.breedName = breedName
        subBreedVC.subBreedName = subBreedsArray[indexPath.row]
        navigationController?.pushViewController(subBreedVC, animated: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

extension BreedViewController: NetworkmanagerDelegate {
    func dataFromServer(response: [String : AnyObject]) {
        guard let message = response["message"] else {
            print("Could not get products from JSON")
            return
        }
        if let stringArray = message as? [String] {
            subBreedsArray = stringArray
            subBreedTable.reloadData()
        }
        else {
            breedImageView.imageFromServerURL(breedName: breedName, urlString: message as! String)
        }
    }
    
    func errorFromServer(error: NSError) {
        print(error.localizedDescription)
    }
}

extension UIImageView {
    public func imageFromServerURL(breedName: String, urlString: String) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error as Any)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                imageDict[breedName] = data
                let image = UIImage(data: data!)
                self.image = image
            })
        }).resume()
    }
}

