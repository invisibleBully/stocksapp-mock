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
    private var watchlistMap: [String:[CandleStick]] = [:]
    
    
    
    private let tableView: UITableView =  {
        let tableView = UITableView()
        return tableView
    }()
    
    private var viewModel: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setupTableView()
        fetchWatchListData()
        setupFloatingPanel()
        setupTitleView()
    }
    
    
    
    
    
    private func setupTableView(){
        view.addSubViews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    private func fetchWatchListData(){
        
        let symbols = PersistenceManager.shared.watchList
        let group = DispatchGroup()
        //fetch market data per symbol
        for symbol in symbols {
            group.enter()
            APIManager.shared.marketData(forSymbol: symbol) { [weak self] response  in
                defer { group.leave() }
                switch response {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }
            self.tableView.reloadData()
        }
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
        let topStoryController = NewsViewController(type: .topStories)
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



extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistMap.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //open detail for selection
    }
    
    
}
