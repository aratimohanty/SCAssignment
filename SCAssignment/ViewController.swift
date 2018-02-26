//
//  ViewController.swift
//  SCAssignment
//
//  Created by arati mohanty on 2/26/18.
//  Copyright © 2018 arati mohanty. All rights reserved.
//

import UIKit

var imageDict = [String:Data]()

class ViewController: UIViewController {
    
    @IBOutlet weak var listTable: UITableView!
    
    var searchController: UISearchController!
    var breedsArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dogs"
        
        getDataFromServer()
        configureSearchController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDataFromServer() {
        DispatchQueue.global(qos: .default).async {
            let urlString = "https://dog.ceo/api/breeds/list/all"
            let networkManager = NetworkManager()
            networkManager.delegate = self
            networkManager.getData(urlString: urlString)
        }
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        listTable.tableHeaderView = searchController.searchBar
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return breedsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath as IndexPath)
        if shouldShowSearchResults {
            cell.textLabel?.text = filteredArray[indexPath.row]
        } else {
            cell.textLabel?.text = breedsArray[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard.init(name:"Main", bundle: nil)
        let breedVC = sb.instantiateViewController(withIdentifier: "BreedsView") as! BreedViewController
        breedVC.breedName = breedsArray[indexPath.row]
        navigationController?.pushViewController(breedVC, animated: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

extension ViewController: NetworkmanagerDelegate {
    func dataFromServer(response: [String : AnyObject]) {
        guard let message = response["message"] else {
            print("Could not get products from JSON")
            return
        }
        let breedsDict = message as! [String : Any]
        breedsArray = Array(breedsDict.keys)
        listTable.reloadData()
    }
    
    func errorFromServer(error: NSError) {
        print(error.localizedDescription)
    }
}

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        listTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        listTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            listTable.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchController)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if(searchString == "") {
            filteredArray = breedsArray
        } else {
            filteredArray = breedsArray.filter({ (breed: String) -> Bool in
                let stringMatch = breed.lowercased().range(of: searchString!.lowercased())
                return stringMatch != nil
            })
        }
        listTable.reloadData()
    }
    
}
