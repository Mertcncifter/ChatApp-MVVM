//
//  ChatHomeViewController.swift
//  ChatApp
//
//  Created by mert can çifter on 19.04.2023.
//

import UIKit
import JGProgressHUD


class ChatHomeViewController: UIViewController {

    // MARK: - Properties
    
    private var viewModel : ChatHomeViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private var conversations = [Conversation]()
    
    private let spinner = JGProgressHUD(style: .dark)

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        return table
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ChatHomeViewModel()
        
        view.addSubview(tableView)
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))

    }
    
    // MARK: - Helpers

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
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

    @objc private func didTapComposeButton() {
        let vc = NewChatViewController()
        vc.completion = { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.viewModel.newChat(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension ChatHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        viewModel.openChat(model: model)
       
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            
            conversations.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .left)
            
            tableView.endUpdates()
        }
    }
    
}

// MARK: - UITableViewDelegate

extension ChatHomeViewController: ChatHomeViewModelDelegate {
    func handleViewModelOutput(_ output: ChatHomeViewModelOutput) {
        switch output {
        case .setLoading(let state):
            configureSpinner(state: state)
        case .error(_):
            break
        case .showConversationList(let conversations):
            self.conversations = conversations
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func navigate(to route: ChatHomeViewRoute) {
        switch route {
        case .chat(let model):
            let vm = ChatViewModel(with: model.email, id: model.id,newConversation: model.newConversation)
            let vc = ChatViewController(viewModel: vm)
            vc.title = model.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
