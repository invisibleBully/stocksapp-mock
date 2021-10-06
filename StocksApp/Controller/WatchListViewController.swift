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
        setupTitleView()
    }
    
    
    private func setupSearchController(){
        let resultsViewController = SearchResultsViewController()
        resultsViewController.delegate = self
        let searchViewController = UISearchController(searchResultsController: resultsViewController)
        searchViewController.searchResultsUpdater = self
        navigationItem.searchController = searchViewController
    }
    
    
    private func setupTitleView() {
        let titleView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100)
        )
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    
    
}




extension WatchListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsViewController = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        print(query)
        //optimize to reduce number of searches when user is done typing...
        //call API to search
        //update result controller
        resultsViewController.update(withResults: ["GOOG","APPL","UBR"])
    }
    
    
}



extension WatchListViewController: SearchResultViewControllerDelegate {
    
    func searchResultsViewControllerDidSelect(searchResult: String) {
        print("Search Result: \(searchResult)")
    }
    
    
}
