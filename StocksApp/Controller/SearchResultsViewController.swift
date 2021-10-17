//
//  SearchResultsViewController.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import UIKit




protocol SearchResultViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult)
}



class SearchResultsViewController: UIViewController {
    
    
    weak var delegate: SearchResultViewControllerDelegate?
    var results = [SearchResult]()
    
    
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultTableViewCell.self,
                           forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        return tableView
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTable()
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    func setupTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func update(withResults results: [SearchResult]) {
        self.results = results
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    
    
}




extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell else {
            return UITableViewCell()
        }
        
        let result = results[indexPath.row]
        cell.textLabel?.text = result.symbol
        cell.detailTextLabel?.text = result.displaySymbol
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedResult = results[indexPath.row]
        delegate?.searchResultsViewControllerDidSelect(searchResult: selectedResult)
    }
    
    
}
