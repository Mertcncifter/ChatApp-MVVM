//
//  NewChatViewController.swift
//  ChatApp
//
//  Created by mert can çifter on 15.04.2023.
//

import UIKit
import JGProgressHUD

class NewChatViewController: UIViewController {

    // MARK: - Properties
    
    private var viewModel : NewChatViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    public var completion: ((SearchResult) -> (Void))?

    private let spinner = JGProgressHUD()
    
    private var results = [SearchResult]()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewChatTableViewCell.self, forCellReuseIdentifier: NewChatTableViewCell.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
            
    }()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = NewChatViewModel()
        
        view.addSubview(tableView)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .systemBackground
        searchBar.delegate = self
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width / 4, y: (view.height - 200), width: view.width / 2, height: 200)
    }
    
    // MARK: - Helpers
    
    private func configureSpinner(state: Bool) {
        if state {
            spinner.show(in: view)
        }
        else {
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
        }
    }

    // MARK: - Selectors

    @objc private func dismissSelf() {
        dismiss(animated: true,completion: nil)
    }
    
}

// MARK: - UISearchBarDelegate

extension NewChatViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        viewModel.searchUsers(query: text)
        
    }

}


// MARK: - UITableViewDelegate

extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewChatTableViewCell.identifier, for: indexPath) as! NewChatTableViewCell
        
        cell.configure(with: results[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - NewChatViewModel

extension NewChatViewController: NewChatViewModelDelegate {
    func handleViewModelOutput(_ output: NewChatViewModelOutput) {
        switch output {
        case .setLoading(let state):
            configureSpinner(state: state)
        case .error(let error):
            break
        case .showResult(let results):
            self.results = results
            if results.isEmpty {
                self.noResultsLabel.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.noResultsLabel.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
    
    func navigate(to route: NewChatViewRoute) {
        
    }
}
