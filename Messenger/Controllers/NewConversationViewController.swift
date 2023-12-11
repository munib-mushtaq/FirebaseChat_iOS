//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Arslan Raza on 22/11/2023.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private var spinner = JGProgressHUD(style: .dark)
    
    public var completion: (([String: String]) -> (Void))?
    
    private var userList = [[String: String]]()
    
    private var results = [[String: String]]()
    
    private var hasFetched = false
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = UIColor.green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        view.addSubview(noConversationLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        noConversationLabel.frame = CGRect(x: view.width/4, y: (view.height - 200) / 2, width: view.width/2, height: 200)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        results.removeAll()
        spinner.show(in: view)
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.fetchUsers { result in
                switch result {
                case .success(let userCollection):
                    self.userList = userCollection
                    self.hasFetched = true
                    self.filterUsers(with: query)
                case .failure(let failure):
                    print("Failed to get users\(failure)")
                }
            }
        }
    }
    
    func filterUsers(with term: String) {
        guard hasFetched else {
            return
        }
        self.spinner.dismiss(animated: true)
        let results: [[String: String]] = self.userList.filter({
            guard let name = $0["name"]?.description.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noConversationLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noConversationLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var cellContext = cell.defaultContentConfiguration()
        cellContext.text = self.results[indexPath.row]["name"]
        cell.contentConfiguration = cellContext
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = self.results[indexPath.row]
        self.dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
}
