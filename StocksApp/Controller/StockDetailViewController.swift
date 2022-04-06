//
//  StockDetailViewController.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import UIKit
import SafariServices

class StockDetailViewController: UIViewController {
    
    //symbol, company name, any chart data we may have
    private let symbol: String
    private let companyName: String
    private var candleStick: [CandleStick]
    private var stories: [NewsStory] = []
    private var metrics: Metric?
    
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return tableView
    }()
    
    
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStick = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        setupCloseButton()
        setupTableView()
        fetchFinancialData()
        fetchNews()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: view.width,
                                                         height: (view.width * 0.7) + 100)
        )
    }
    
    
    private func fetchFinancialData(){
        
        let group = DispatchGroup()
        //fetch candle sticks if needed
        if candleStick.isEmpty {
            group.enter()
            APIManager.shared.marketData(forSymbol: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let result):
                    self?.candleStick = result.candleSticks
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                
            }
        }
        //fetch financial metrics
        group.enter()
        APIManager.shared.financialMetrics(forSymbol: symbol) { [weak self] result  in
            defer {
                group.leave()
            }
            switch result {
            case .success(let result):
                let metrics = result.metric
                self?.metrics = metrics
            case .failure(let error):
                print("Error on metrics API... \(error.localizedDescription)")
            }
            
        }
        
        
        group.notify(queue: .main) { [weak self]  in
            self?.renderChart()
        }
        
        
    }
    
    
    private func renderChart(){
        //chartViewModel
        //collection of financial view models
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: view.width,
                                                             height: (view.width * 0.7) + 100)
        )
        
        
        var viewModels: [MetricCollectionViewCell.ViewModel] = []
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.annualWeekHigh)"))
            viewModels.append(.init(name: "52W Low", value: "\(metrics.annualWeekLow)"))
            viewModels.append(.init(name: "52W Daily", value: "\(metrics.annualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.tenDayAverageTradingVolume)"))
        }
        //configure
        //headerView.backgroundColor = .link
        headerView.configure(chartViewModel: .init(data: candleStick.reversed().map { $0.close },
                                                   showLegend: true, showAxis: true), metricViewModels: viewModels)
        tableView.tableHeaderView = headerView
    }
    
    
    private func setupCloseButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(closeView)
        )
    }
    
    
    @objc func closeView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func fetchNews(){
        
        APIManager.shared.news(for: .company(symbol: symbol), completion: { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let stories):
                self.stories = stories
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error Fetching Company News Data: \(error)")
            }
        })
    }
    
    
    
}



extension StockDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier,
                                                       for: indexPath) as? NewsStoryTableViewCell else { return UITableViewCell()}
        
        cell.configure(with: .init(model: stories[indexPath.row]))
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as?
                NewsHeaderView else { return nil }
        
        header.delegate = self
        header.configure(withViewModel: .init(title: symbol.uppercased(),
                                              shouldShowActionButton: !PersistenceManager.shared.watchListContains(symbol: symbol)))
        return header
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
    }
    
    
}




extension StockDetailViewController: NewsHeaderViewDelegate {
    
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)
        
        let alert = UIAlertController(title: "Watchlist",
                                      message: "We've added \(companyName) to your watchlist",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}
