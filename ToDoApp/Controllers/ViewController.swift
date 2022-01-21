//
//  ViewController.swift
//  ToDoApp
//
//  Created by Uzay Altıner on 19.01.2022.
//

import UIKit

class ViewController: UIViewController {
    var todoArray = [String]()
    @IBOutlet weak var tableView: UITableView!
    var alertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
    @IBAction func removeButtonTapped(_ sender: UIBarButtonItem) {
        presentAlert(title: "Uyarı",
                     message: "Listeyi silmek istediğinizden emin misiniz?",
                     defaultButtonTitle: "Sil",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvaible: false,
                     defaultButtonHandler: { _ in
            self.todoArray.removeAll()
            self.tableView.reloadData()
        })
    }
    
    
    func presentAddAlert(){
        presentAlert(title: "Ekle",
                     message: nil,
                     defaultButtonTitle: "Ekle",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvaible: true,
                     defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            
            if text != "" {
                self.todoArray.append((text)!)
                self.tableView.reloadData()
            } else {
                self.presentWarningAlert()
            }
        }
        )
        
    }
    
    func presentWarningAlert(){
        presentAlert(title: "Uyarı!",
                     message: "Boş ekleme yapamazsınız.",
                     cancelButtonTitle: "Tamam")
    }
    func presentAlert(title: String?,
                      message: String?,
                      preferedStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvaible: Bool = false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil,
                      isDefaultButtonOnTrashButton: Bool = false){
        
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferedStyle)
        
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvaible {
            alertController.addTextField()
        }
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        cell.textLabel?.text = todoArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "sil") { _, _, _ in
            self.todoArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Düzenle",
                              message: nil,
                              defaultButtonTitle: "Tamam",
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvaible: true,
                              defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                
                if text != "" {
                    self.todoArray[indexPath.row] = text!
                    self.tableView.reloadData()
                } else {
                    self.presentWarningAlert()
                }
            })
            
        }
        editAction.backgroundColor = .systemGreen
        deleteAction.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions:[deleteAction, editAction])
        return config
    }
    
}

