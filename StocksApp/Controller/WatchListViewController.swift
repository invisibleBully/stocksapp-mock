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
    static var maxChangeWidth: CGFloat = 0
    
    
    private let tableView: UITableView =  {
        let tableView = UITableView()
        tableView.register(WatchListTableViewCell.self,
                           forCellReuseIdentifier:WatchListTableViewCell.identifier)
        
        return tableView
    }()
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    let defaults  = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setupTableView()
        fetchWatchListData()
        setupFloatingPanel()
        setupTitleView()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
            self.creatViewModels()
            self.tableView.reloadData()
        }
    }
    
    
    private func creatViewModels(){
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(forCandleStickData: candleSticks)
            viewModels.append(.init(symbol: symbol,
                                    companyName: defaults.string(forKey: symbol) ?? "Company",
                                    price: getLatestClosingPrice(symbol: symbol,fromData: candleSticks),
                                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                                    changePercentage: .percentage(fromDouble: changePercentage),
                                    chartViewModel: .init(data: candleSticks.reversed().map { $0.close },
                                                          showLegend: false,
                                                          showAxis: false ))
                              
                              
            )
            
        }
        
        print("\n\n\n \(viewModels)")
        self.viewModels = viewModels
    }
    
    
    
    private func getLatestClosingPrice(symbol: String, fromData data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return .formatted(number: closingPrice)
    }
    
    
    
    private func getChangePercentage(forCandleStickData data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,let priorClose =
                data.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: latestDate)} )?.close else {
                    return 0
                }
        
        let difference  = 1 - (priorClose/latestClose)
        
        return difference
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
        return viewModels.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier,
                                                       for: indexPath) as? WatchListTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configureCell(viewModel: viewModels[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //open detail for selection
    }
    
    
}



extension WatchListViewController: WatchListTableViewCellDelegate {
    
    func didUpdateMaxWidth() {
        //optimize: only refresh rows prior to the current row that changes max width
        tableView.reloadData()
    }
    
}
