//
//  ViewController.swift
//  ToDoApp
//
//  Created by Uzay Altıner on 19.01.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var todoArray = [NSManagedObject]()
    @IBOutlet weak var tableView: UITableView!
    var alertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
        
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
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
            let deleteAll = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try! managedObjectContext?.execute(deleteAll)
            self.fetch()
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
                let appDelegeta = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegeta?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext!)
                
                listItem.setValue(text,
                                  forKey: "title")
                
                try? managedObjectContext?.save()
                
                self.fetch()
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
    func fetch(){
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        
        todoArray = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = todoArray[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "sil") { _, _, _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            managedObjectContext?.delete(self.todoArray[indexPath.row])
            try? managedObjectContext?.save()
            
            self.fetch()
            
            
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
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.todoArray[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
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

