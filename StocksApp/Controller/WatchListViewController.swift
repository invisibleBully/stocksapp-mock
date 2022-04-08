//
//  ViewController.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import UIKit
import FloatingPanel


/// View controller to render user watch list
final class WatchListViewController: UIViewController {
    
    
    /// timer to optimize searching
    private var searchTimer: Timer?
    
    /// floating panel
    private var floatingPanel: FloatingPanelController?
    
    private var watchlistMap: [String:[CandleStick]] = [:]
    
    /// width to track change label geometry
    static var maxChangeWidth: CGFloat = 0
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    private var observer: NSObjectProtocol?
    
    let defaults  = UserDefaults.standard

    
    
    private let tableView: UITableView =  {
        let tableView = UITableView()
        tableView.register(WatchListTableViewCell.self,
                           forCellReuseIdentifier:WatchListTableViewCell.identifier)
        
        return tableView
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setupTableView()
        fetchWatchListData()
        setupFloatingPanel()
        setupTitleView()
        setupObserver()
    }
    
    
    /// sets up observer for watch list updates
    private func setupObserver(){
        observer = NotificationCenter.default.addObserver(forName: .didAddtoWatchList,
                                                          object: nil,
                                                          queue: .main,
                                                          using: { [weak self] _ in
            guard let self = self else { return }
            self.viewModels.removeAll()
            self.fetchWatchListData()
        })
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
    
    
    
    /// fetch watch list models
    private func fetchWatchListData(){
        
        let symbols = PersistenceManager.shared.watchList
        let group = DispatchGroup()
        //fetch market data per symbol
        for symbol in symbols where  watchlistMap[symbol] == nil {
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
    
    
    /// create view models from models
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
                                                          showAxis: false, fillColor: changePercentage < 0 ? .systemRed : .systemGreen ))
                              
                              
            )
            
        }
        
        self.viewModels = viewModels
    }
    
    
    
    /// get latest closing price
    /// - Parameters:
    ///   - symbol: company symbol
    ///   - data: collection of data
    /// - Returns: string
    private func getLatestClosingPrice(symbol: String, fromData data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return .formatted(number: closingPrice)
    }
    
    
    
    /// get change percentage for symbol data
    /// - Parameter data: collection of data
    /// - Returns: double percentage
    private func getChangePercentage(forCandleStickData data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,let priorClose =
                data.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: latestDate)} )?.close else {
                    return 0
                }
        
        let difference  = 1 - (priorClose/latestClose)
        
        return difference
    }
    
    
    
    /// search up search and results controller
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
    
    /// update search results on key tap
    /// - Parameter searchController: reference of the search controller
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



// MARK: - Search Result View Controller Delegate

extension WatchListViewController: SearchResultViewControllerDelegate {
    
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        HapticsManager.shared.vibrateForSelection()
        
        let stockDetailController = StockDetailViewController(symbol: searchResult.displaySymbol, companyName: searchResult.description)
        let navigationController = UINavigationController(rootViewController: stockDetailController)
        stockDetailController.title = searchResult.description
        present(navigationController, animated: true, completion: nil)
    }
    
    
}



// MARK: - FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
    
    /// gets floating panel state change
    /// - Parameter fpc: reference of floating panel controller
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
    
}



// MARK: - TabelViewController Delegate & Datasource

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
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            PersistenceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
            viewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //open detail for selection
        HapticsManager.shared.vibrateForSelection()
        let viewModel = viewModels[indexPath.row]
        let viewController = StockDetailViewController(symbol: viewModel.symbol, companyName: viewModel.companyName, candleStickData: watchlistMap[viewModel.symbol] ?? [])
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    
}



// MARK: - WatchListTableViewCellDelegate

extension WatchListViewController: WatchListTableViewCellDelegate {
    
    func didUpdateMaxWidth() {
        //optimize: only refresh rows prior to the current row that changes max width
        tableView.reloadData()
    }
    
}
