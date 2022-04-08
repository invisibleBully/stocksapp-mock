//
//  TopStoriesNewsViewController.swift
//  StocksApp
//
//  Created by Jude Botchwey on 05/10/2021.
//

import UIKit
import SafariServices


/// Types of stories
enum StoryType {
    
    case topStories
    case company(symbol: String)
    
    var title: String {
        switch self {
        case .topStories:
            return "Top Stories"
        case .company(symbol: let symbol):
            return symbol.uppercased()
        }
    }
    
}





final class NewsViewController: UIViewController {
    
    
    var type: StoryType!
    
    let tableView: UITableView =  {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        return table
    }()
    
    
    
    private var stories: [NewsStory] = []
    
    
    
    init(type: StoryType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupTableView()
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
    }
    
    
    private func fetchNews(){
        APIManager.shared.news(for: self.type) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    
    private func open(url: URL){
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
    }
    
}






extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsStoryTableViewCell.identifier,
            for: indexPath) as? NewsStoryTableViewCell else {
                return UITableViewCell()
            }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as?
                NewsHeaderView else {return UIView()}
        headerView.configure(withViewModel: .init(title: self.type.title,
                                                  shouldShowActionButton: false))
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedOpenAlert()
            return
        }
        open(url: url)
    }
    
    
    private func presentFailedOpenAlert(){
        HapticsManager.shared.vibrate(for: .error)
        
        let alert = UIAlertController(title: "Invalid Web Address",
                                      message: "We are unable to open this article. Please try again later.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
}
