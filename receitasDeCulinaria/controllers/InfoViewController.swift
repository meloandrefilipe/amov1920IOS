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
    @IBOutlet weak var lbCat: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbDesciption: UITextView!
    
    var receita: NSManagedObject!
    var ingredientes: [NSManagedObject]!
    var receitas: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        let name = receita.value(forKeyPath: "nome") as? String
        self.title = name
        
        
        
        let time = (receita.value(forKeyPath: "tempo") as! NSNumber).stringValue
        let cat = receita.value(forKeyPath: "categoria") as! NSManagedObject
        let nameCat = cat.value(forKeyPath: "nome") as! String
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let name = receita.value(forKeyPath: "nome") as? String
        let time = (receita.value(forKeyPath: "tempo") as! NSNumber).stringValue
        let cat = receita.value(forKeyPath: "categoria") as! NSManagedObject
        let nameCat = cat.value(forKeyPath: "nome") as! String
        self.title = name
        lbCat.text = nameCat
        lbTime.text = time
        lbDesciption.text = receita.value(forKeyPath: "descricao") as? String
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is EditViewController
        {
            let viewController = segue.destination as? EditViewController
            viewController?.receita = receita
        }
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
        if ingredientes != nil{
            return ingredientes.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ingredientes != nil{
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngerdienteCell", for: indexPath) as! IngerdienteTableViewCell
            let unidade = ingredientes[indexPath.row].value(forKeyPath: "unidade") as! String
            var text = (ingredientes[indexPath.row].value(forKeyPath: "quantidade") as! NSNumber).stringValue
            
            
            cell.lbName.text = ingredientes[indexPath.row].value(forKeyPath: "nome") as? String
            text += " "
            text += unidade
            cell.lbQuantity.text = text
            
            return cell
        }
        return UITableViewCell()
    }
}



