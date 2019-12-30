//
//  ViewController.swift
//  receitasDeCulinaria
//
//  Created by André Melo on 27/12/2019.
//  Copyright © 2019 André Melo. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var receitas: [NSManagedObject]!
    var filteredData: [NSManagedObject]!
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        navigationController?.navigationBar.barTintColor = UIColor.init(hex: "ffb300")
        super.viewDidLoad()
        searchBar.delegate = self
        self.hideKeyboard()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        
        let receitasDB = NSFetchRequest<NSManagedObject>(entityName: "Receita")
        do {
            receitas = try managedContext.fetch(receitasDB)
            filteredData = receitas
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        
        //Para @ouvir@ o teclado -> para mover a janela quando abrimos o teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let receitasDB = NSFetchRequest<NSManagedObject>(entityName: "Receita")
        do {
            receitas = try managedContext.fetch(receitasDB)
            filteredData = receitas
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is InfoViewController{
            let viewController = segue.destination as? InfoViewController
            let index: Int = tableView.indexPathForSelectedRow!.row
            viewController?.receita = filteredData[index]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData != nil {
            return filteredData.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredData != nil {
            let customCell =  tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
            let cat = filteredData[indexPath.row].value(forKeyPath: "categoria") as! NSManagedObject
            let nameCat = cat.value(forKeyPath: "nome") as? String
            let time = (filteredData[indexPath.row].value(forKeyPath: "tempo") as! NSNumber).stringValue
            customCell.lbName.text = filteredData[indexPath.row].value(forKeyPath: "nome") as? String
            customCell.lbTime.text = time
            customCell.lbCatgory.text = nameCat
            return customCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let btnDelete = deleteRecepie(at: indexPath)
        let btnCancel = cancel(at: indexPath)
        return UISwipeActionsConfiguration(actions: [btnCancel, btnDelete])
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredData = receitas
            tableView.reloadData()
            return
            
        }
        filteredData = receitas.filter({ (receita) -> Bool in
            let name = receita.value(forKeyPath: "nome") as! String
            let time = (receita.value(forKeyPath: "tempo") as! NSNumber).stringValue
            let cat = receita.value(forKeyPath: "categoria") as! NSManagedObject
            let nameCat = cat.value(forKeyPath: "nome") as! String
            switch searchBar.selectedScopeButtonIndex{
            case 0:
                return name.lowercased().contains(searchText.lowercased())
            case 1:
                return time.lowercased().contains(searchText.lowercased())
            case 2:
                return nameCat.lowercased().contains(searchText.lowercased())
            default:
                return false
                
            }
        })
        tableView.reloadData()
        
    }
    
    func cancel(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Cancelar") { (action, view, completion) in
            completion(true)
        }
        action.image = UIImage(systemName: "xmark")
        action.backgroundColor = .gray
        return action
    }
    
    func deleteRecepie(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Apagar") { (action, view, completion) in
            let rec = self.filteredData[indexPath.row]
            self.managedContext.delete(rec)
            self.filteredData.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            do{
                try
                    self.managedContext.save()
                self.showToast(message: "Aletracoes guardadas com sucesso!")
            }catch let error as NSError{
                print("Erro a guardar as alteracoes! \(error)")
                self.showToast(message: "Ocorreu um problema, tente mais tarde!")
            }
            self.showToast(message: "Receita apagada com sucesso!")
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        action.backgroundColor = .red
        return action
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let text = searchBar.text!
        if !text.isEmpty{
            filteredData = receitas.filter({ (receita) -> Bool in
                let name = receita.value(forKeyPath: "nome") as! String
                let time = (receita.value(forKeyPath: "tempo") as! NSNumber).stringValue
                let cat = receita.value(forKeyPath: "categoria") as! NSManagedObject
                let nameCat = cat.value(forKeyPath: "nome") as! String
                switch selectedScope{
                case 0:
                    return name.lowercased().contains(text.lowercased())
                case 1:
                    return time.lowercased().contains(text.lowercased())
                case 2:
                    return nameCat.lowercased().contains(text.lowercased())
                default:
                    return false
                }
            })
        }else{
            filteredData = receitas
        }
        tableView.reloadData()
    }
    
    @IBAction func btnTime(_ sender: UIButton) {
        filteredData = receitas.sorted(by: { (receitaA, receitaB) -> Bool in
            let timeA = Float(truncating: receitaA.value(forKeyPath: "tempo") as! NSNumber)
            let timeB = Float(truncating: receitaB.value(forKeyPath: "tempo") as! NSNumber)
            return timeA < timeB
        })
        tableView.reloadData()
    }
    @IBAction func btnCatgory(_ sender: UIButton) {
        filteredData = receitas.sorted(by: { (receitaA, receitaB) -> Bool in
            let catA = receitaA.value(forKeyPath: "categoria") as! NSManagedObject
            let catB = receitaB.value(forKeyPath: "categoria") as! NSManagedObject
            let nameA = catA.value(forKeyPath: "nome") as? String
            let nameB = catB.value(forKeyPath: "nome") as? String
            return nameA! < nameB!
        })
        tableView.reloadData()
    }
    @IBAction func btnName(_ sender: UIButton) {
        filteredData = receitas.sorted(by: { (receitaA, receitaB) -> Bool in
            let nameA = receitaA.value(forKeyPath: "nome") as? String
            let nameB = receitaB.value(forKeyPath: "nome") as? String
            return nameA! < nameB!
        })
        tableView.reloadData()
    }
    
    deinit {
        // deixa de @ouvir@ o telcado
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardNotes = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if UIResponder.keyboardWillHideNotification != notification.name {
            view.frame.origin.y = -(keyboardNotes.height)
        }else{
            view.frame.origin.y = 0
        }
        
    }
}

extension UIViewController{
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: 5, y: self.view.frame.size.height-100, width: (self.view.frame.width - 10), height: 35))
        toastLabel.numberOfLines = 0
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UIColor {
    convenience init(hex:String, alpha:CGFloat = 1.0) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt64 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt64(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}


