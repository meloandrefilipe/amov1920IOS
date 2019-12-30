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

    var receitas: [NSManagedObject]!
    var filteredData: [NSManagedObject]!
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
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
        tableView.reloadData()
    }
    
    deinit {
        
        // deixa de @ouvir@ o telcado
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @IBOutlet weak var searchBar: UITableView!
    @IBOutlet weak var tableView: UITableView!

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


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell =  tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
        let cat = filteredData[indexPath.row].value(forKeyPath: "categoria") as! NSManagedObject
        let nameCat = cat.value(forKeyPath: "nome") as? String
        let time = (filteredData[indexPath.row].value(forKeyPath: "tempo") as! NSNumber).stringValue
        customCell.lbName.text = filteredData[indexPath.row].value(forKeyPath: "nome") as? String
        customCell.lbTime.text = time
        customCell.lbCatgory.text = nameCat
        return customCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        let rec = filteredData[indexPath.row]
        managedContext.delete(rec)
        filteredData.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController
        viewController?.receita = filteredData[indexPath.row]
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredData = receitas
            tableView.reloadData()
            return
            
        }
        
        
        filteredData = receitas.filter({ (receita) -> Bool in
            let name = receita.value(forKeyPath: "nome") as! String
            let time = (receita.value(forKeyPath: "tempo") as! NSDecimalNumber).stringValue
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
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let text = searchBar.text!
        if !text.isEmpty{
            filteredData = receitas.filter({ (receita) -> Bool in
                let name = receita.value(forKeyPath: "nome") as! String
                let time = receita.value(forKeyPath: "tempo") as! String
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


