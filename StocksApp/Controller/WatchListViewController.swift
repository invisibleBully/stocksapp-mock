//
//  ViewController.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    private var floatingPanel: FloatingPanelController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setupFloatingPanel()
        setupTitleView()
    }
    
    
    private func setupSearchController(){
        let resultsViewController = SearchResultsViewController()
        resultsViewController.delegate = self
        let searchViewController = UISearchController(searchResultsController: resultsViewController)
        searchViewController.searchResultsUpdater = self
        navigationItem.searchController = searchViewController
        //navigationItem.searchController?.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 12)
    }
    
    
    private func setupTitleView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    
    
    
    private func setupFloatingPanel(){
        let topStoryController = TopStoriesNewsViewController()
        let panel = FloatingPanelController()
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: topStoryController)
        panel.addPanel(toParent: self)
        panel.delegate = self
        panel.track(scrollView: topStoryController.tableView)
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
        APIManager.shared.search(query: query) { result  in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    resultsViewController.update(withResults: response.result)
                }
            case .failure(let error):
                print("Error: \(error)")
                break
            }
        }
        
        //update result controller
        //resultsViewController.update(withResults: ["GOOG","APPL","UBR"])
    }
    
    
}



extension WatchListViewController: SearchResultViewControllerDelegate {
    
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let stockDetailController = StockDetailViewController()
        let navigationController = UINavigationController(rootViewController: stockDetailController)
        stockDetailController.title = searchResult.description
        present(navigationController, animated: true, completion: nil)
        
    }
    
    
}



extension WatchListViewController: FloatingPanelControllerDelegate {
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
    
    
}
