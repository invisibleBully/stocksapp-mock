//
//  ViewController.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import UIKit

class WatchListViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
    }
    
    
    private func setupSearchController(){
        let resultsViewController = SearchResultsViewController()
        let searchViewController = UISearchController(searchResultsController: resultsViewController)
        searchViewController.searchResultsUpdater = self
        navigationItem.searchController = searchViewController
    }
    
    
}




extension WatchListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsViewController = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        //optimize to reduce number of searches when user is done typing...
        //call API to search
        //update result controller
        print(query)
    }
    
    
}
