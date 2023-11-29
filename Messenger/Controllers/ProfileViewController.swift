//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Arslan Raza on 22/11/2023.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dataSet = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Profile"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    func logout() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            vc.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false)
        } catch {
            print("Error while logout the user.")
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var cellContext = cell.defaultContentConfiguration()
        cellContext.text = dataSet[indexPath.row]
        cellContext.textProperties.alignment = .center
        cellContext.textProperties.color = .red
        cell.contentConfiguration = cellContext
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: "Alert", message: "Do you want to logout.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { [weak self ] action in
            guard let strongSelf = self else { return }
            strongSelf.logout()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}
