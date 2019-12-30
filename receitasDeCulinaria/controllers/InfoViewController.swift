//
//  InfoViewController.swift
//  receitasDeCulinaria
//
//  Created by André Melo on 27/12/2019.
//  Copyright © 2019 André Melo. All rights reserved.
//

import UIKit
import CoreData

class InfoViewController: UIViewController {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbCat: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbDesciption: UITextView!
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    
    @IBAction func btnEdit(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "EditViewController") as? EditViewController
        viewController?.receita = receita
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    var receita: NSManagedObject!
    var ingredientes: [NSManagedObject]!
    var receitas: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        
        
        
        let name = receita.value(forKeyPath: "nome") as? String
        let time = (receita.value(forKeyPath: "tempo") as! NSNumber).stringValue
        let cat = receita.value(forKeyPath: "categoria") as! NSManagedObject
        let nameCat = cat.value(forKeyPath: "nome") as! String
        lbName.text = name
        lbCat.text = nameCat
        lbTime.text = time
        lbDesciption.text = receita.value(forKeyPath: "descricao") as? String
        let set = receita.value(forKeyPath: "ingredientes") as! NSSet
        ingredientes = set.allObjects as? [NSManagedObject]
       //Para @ouvir@ o teclado -> para mover a janela quando abrimos o teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }

    
    
    deinit {
        
        // deixa de @ouvir@ o telcado
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

extension InfoViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngerdienteCell", for: indexPath) as! IngerdienteTableViewCell
        let unidade = ingredientes[indexPath.row].value(forKeyPath: "unidade") as! String
        var text = (ingredientes[indexPath.row].value(forKeyPath: "quantidade") as! NSNumber).stringValue
        
        
        cell.lbName.text = ingredientes[indexPath.row].value(forKeyPath: "nome") as? String
        text += " "
        text += unidade
        cell.lbQuantity.text = text

        return cell
    }
}



