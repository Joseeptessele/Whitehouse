//
//  ViewController.swift
//  Whitehouse
//
//  Created by José Eduardo Pedron Tessele on 30/08/19.
//  Copyright © 2019 José P Tessele. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UISearchResultsUpdating {

    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var search: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        search.searchBar.sizeToFit()
        tableView.tableHeaderView = search.searchBar
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON(){
        let urlString: String
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(creditsMessage))
        
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        // global -> run in the background
        if let url = URL(string: urlString){
            if let data = try? Data(contentsOf: url){
                parse(json: data)
                return
            }
        }
        // as showError method has UI work and is being called on a background thread
        // it must come back to the main thread
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredPetitions.removeAll()
        if isFiltering(){
            for petition in petitions {
                if petition.title.contains(text){
                    filteredPetitions.append(petition)
                    print(petition.title)
                }
            }
        }
        tableView.reloadData()
    }

    func searchBarIsEmpty() -> Bool {
        return search.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return search.isActive && !searchBarIsEmpty()
    }
    
    @objc func creditsMessage(){
        let ac = UIAlertController(title: "Did you know?", message: "These petitions are from Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(ac, animated: true)
    }
    
    @objc func showError(){
        let ac = UIAlertController(title: "Loadin Error", message: "There was a problem loading the feed; please check your connection and try again", preferredStyle: .alert)
    
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
       present(ac, animated: true)
    }
    
    func parse(json: Data){
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json){
            petitions = jsonPetitions.results
            // as this method is being called on a background thread and
            // is bad do UI work on this kind of thread, the reload data must
            // go to the main thread
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering(){
            return filteredPetitions.count
        }
        
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition: Petition
        if isFiltering() && search.isActive {
            petition = filteredPetitions[indexPath.row]
        } else {
            petition = petitions[indexPath.row]
        }
        cell.textLabel?.text = "\(petition.title)"
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        if isFiltering() && search.isActive {
            vc.detailItem = filteredPetitions[indexPath.row]
        } else {
            vc.detailItem = petitions[indexPath.row]
        }
        
        if search.isActive{
            search.dismiss(animated: true, completion: nil)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

