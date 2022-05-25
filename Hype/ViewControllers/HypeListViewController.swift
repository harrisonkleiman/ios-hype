//
//  HypeListViewController.swift
//  Hype
//
//  Created by Harrison Kleiman on 5/25/22.
//

import UIKit

class HypeListViewController: UIViewController {

   // MARK: - Class Properties
    var refresh: UIRefreshControl = UIRefreshControl()
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        loadData()
    }
    
    // MARK: - Actions
    @IBAction func addHypeButtonTapped(_ sender: Any) {
        presentHypeAlert(nil)
    }
    
    @objc func loadData() {
        HypeController.shared.fetchAllHypes { (result) in
            switch result {
            case.success(let hypes):
                HypeController.shared.hypes = hypes!
                self.updateViews()
            case.failure(let error):
                print(error.errorDescription)
                print("\n\n\n Error: \(error) \n\n\n")
            }
            
        }
    }
    
    // MARK: - Class Methods
    func setUpViews() {
        tableView.dataSource = self
        tableView.delegate = self
        refresh.attributedTitle = NSAttributedString(string: "Pull to see new Hypes")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    func presentHypeAlert(_ hype: Hype?) {
        let alert = UIAlertController(title: "Get Hype!", message: "What is hype may never die", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "What is hype today?"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            if let hype = hype {
                textField.text = hype.body
            }
        }
        
        let addHypeAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            if let hype = hype {
                hype.body = text
                HypeController.shared.updateHypes(hype) { (result) in
                    switch result {
                    case .success(_):
                        self.updateViews()
                    case .failure(let error):
                        print(error.errorDescription)
                    }
                }
            } else {
                HypeController.shared.saveHype(with: text) { (result) in
                        switch result {
                        case .success(let hype):
                            guard let hype = hype else {return}
                            HypeController.shared.hypes.insert(hype, at: 0)
                            self.updateViews()
                        case .failure(let error):
                            print(error.errorDescription)
                        }
                    }
                }
            }
                
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addHypeAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}

// MARK: - TableView DataSource/Delegate Conformance
extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.formatDate()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHype = HypeController.shared.hypes[indexPath.row]
        presentHypeAlert(selectedHype)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let hypeToDelete = HypeController.shared.hypes[indexPath.row]
                guard let index = HypeController.shared.hypes.firstIndex(of: hypeToDelete) else { return }
                HypeController.shared.deleteHypes(hypeToDelete) { (result) in
                    switch result {
                    case .success(let success):
                        if success {
                            HypeController.shared.hypes.remove(at: index)
                            DispatchQueue.main.async {
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    case .failure(let error):
                        print(error.errorDescription)
                    }
                }
            }
        }
}

// MARK: - TextFieldDelegate Confromance
extension HypeListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
