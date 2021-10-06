//
//  SearchResultsViewController.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import UIKit




protocol SearchResultViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidSelect(searchResult: String)
}



class SearchResultsViewController: UIViewController {
    
    
    weak var delegate: SearchResultViewControllerDelegate?
    var results = [String]()
    
    
    
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
    
    func update(withResults results: [String]) {
        self.results = results
        tableView.reloadData()
    }
    
    
    
}




extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = "AAPL"
        cell.detailTextLabel?.text = "Apple Inc."
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultsViewControllerDidSelect(searchResult: "AAPL")
    }
    
    
}
