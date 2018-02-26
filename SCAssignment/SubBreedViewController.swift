//
//  SubBreedViewController.swift
//  SCAssignment
//
//  Created by arati mohanty on 2/26/18.
//  Copyright © 2018 arati mohanty. All rights reserved.
//

import UIKit

class SubBreedViewController: UIViewController {

    @IBOutlet weak var subBreedImageView: UIImageView!
    var breedName = ""
    var subBreedName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateView() {
        self.title = subBreedName
        DispatchQueue.global(qos: .default).async {
            let urlString = "https://dog.ceo/api/breed/" + self.breedName + "/" + self.subBreedName + "/images/random"
            let networkManager = NetworkManager()
            networkManager.delegate = self
            networkManager.getData(urlString: urlString)
        }
    }
}

extension SubBreedViewController: NetworkmanagerDelegate {
    func dataFromServer(response: [String : AnyObject]) {
        guard let message = response["message"] else {
            print("Could not get products from JSON")
            return
        }
        subBreedImageView.imageFromServerURL(breedName: subBreedName, urlString: message as! String)
    }
    
    func errorFromServer(error: NSError) {
        print(error.localizedDescription)
    }
}
