//
//  EditViewController.swift
//  receitasDeCulinaria
//
//  Created by André Melo on 28/12/2019.
//  Copyright © 2019 André Melo. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

class EditViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    
    @IBOutlet weak var lbNome: UITextField!
    @IBOutlet weak var lbTempo: UITextField!
    @IBOutlet weak var lbCatgoria: UITextField!
    @IBOutlet weak var lbIngName: UITextField!
    @IBOutlet weak var lbIngQuantity: UITextField!
    @IBOutlet weak var lbIngUnit: UITextField!
    @IBOutlet weak var lbDescription: UITextView!
    @IBOutlet weak var tvIngd: UITableView!
    @IBOutlet weak var tvCatgories: UITableView!
    
    var receita: NSManagedObject!
    var categoriaVelha: NSManagedObject!
    var ingredientes: [NSManagedObject]!
    var categorias: [NSManagedObject]!
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    var selectedCatgory: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        lbDescription.textContainerInset = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        
        let set = receita.value(forKey: "ingredientes") as! NSSet
        ingredientes = (set.allObjects as! [NSManagedObject])
        categoriaVelha = (receita.value(forKey: "categoria") as! NSManagedObject)
        selectedCatgory = categoriaVelha.value(forKey: "nome") as? String
        
        lbNome.text = receita.value(forKey: "nome") as? String
        lbTempo.text = (receita.value(forKey: "tempo") as! NSNumber).stringValue
        lbDescription.text = receita.value(forKey: "descricao") as? String
        tvIngd.tableFooterView = UIView()
        tvCatgories.tableFooterView = UIView()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categoria")
        
        do {
            categorias = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        //Para @ouvir@ o teclado -> para mover a janela quando abrimos o teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categoria")
        
        do {
            categorias = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvCatgories {
            if categorias != nil{
                return categorias.count
            }
        }
        if tableView == tvIngd{
            if ingredientes != nil{
                return ingredientes.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tvCatgories && categorias != nil{
            let cellCatgory = tableView.dequeueReusableCell(withIdentifier: "CatCell" ) as! EditReceitaCatCell
            let nome = categorias[indexPath.row].value(forKey: "nome") as? String
            cellCatgory.lbCatName.text = nome
            if nome != selectedCatgory {
                cellCatgory.accessoryType = .none
            }else{
                cellCatgory.accessoryType = .checkmark
            }
            return cellCatgory
        }
        if tableView == tvIngd && ingredientes != nil{
            let cellIngrediente = tableView.dequeueReusableCell(withIdentifier: "ingCell") as! EditReceitaIngCell
            cellIngrediente.lbIngName.text = ingredientes[indexPath.row].value(forKey: "nome") as? String
            let quant = ingredientes[indexPath.row].value(forKey: "quantidade") as? NSNumber
            cellIngrediente.lbIngQuantity.text = quant?.stringValue
            cellIngrediente.lbIngUnit.text = ingredientes[indexPath.row].value(forKey: "unidade") as? String
            return cellIngrediente
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tvCatgories{
            let cell = tableView.cellForRow(at: indexPath)!
            cell.accessoryType = .checkmark
            selectedCatgory = cell.textLabel?.text
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == tvCatgories{
            let btnEdit = editCategory(at: indexPath)
            let btnDelete = deleteCategory(at: indexPath)
            let btnCancel = cancel(at: indexPath)
            return UISwipeActionsConfiguration(actions: [btnCancel,btnDelete,btnEdit])
        }
        if tableView == tvIngd {
            let btnDelete = deleteIngredient(at: indexPath)
            let btnCancel = cancel(at: indexPath)
            return UISwipeActionsConfiguration(actions: [btnCancel, btnDelete])
        }
        return UISwipeActionsConfiguration(actions: [])
    }
    
    func cancel(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Cancelar") { (action, view, completion) in
            completion(true)
        }
        action.image = UIImage(systemName: "xmark")
        action.backgroundColor = .gray
        return action
    }
    
    func editCategory(at indexPath: IndexPath) -> UIContextualAction{
        let element = categorias[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Editar") { (action, view, completion) in
            let alert = UIAlertController(title: "Editar \(element.value(forKey: "nome") as! String)", message: "Pode editar aqui o nome da categoria", preferredStyle: .alert)
            let save = UIAlertAction(title: "Guardar", style: UIAlertAction.Style.default) { (action) in
                let text = alert.textFields?.first?.text
                if text!.isEmpty{
                    self.showToast(message: "Insira um nome para a categoria!")
                }else{
                    element.setValue(text, forKey: "nome")
                    do{
                        try
                            self.managedContext.save()
                    }catch let error as NSError{
                        print("Erro a guardar a receita! \(error)")
                        self.showToast(message: "Ocorreu um problema, tente mais tarde!")
                    }
                    self.tvCatgories.reloadData()
                }
            }
            let cancel = UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil)
            
            alert.addTextField { (textField) in
                textField.text = element.value(forKey: "nome") as? String
                textField.placeholder = "Nome da categoria"
            }
            alert.addAction(save)
            alert.addAction(cancel)
            self.present(alert,animated: true,completion: nil)
            completion(true)
        }
        action.image = UIImage(systemName: "square.and.pencil")
        action.backgroundColor = .orange
        return action
    }
    
    func deleteCategory(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Apagar") { (action, view, completion) in
            let categoria = self.categorias[indexPath.row]
            let set = categoria.value(forKey: "receitas") as! NSSet
            let connections = set.allObjects as! [NSManagedObject]
            if connections.count > 0{
                self.showToast(message: "Esta categoria esta associada a \(connections.count) receitas!")
            }else{
                self.managedContext.delete(categoria)
                do{
                    try
                        self.managedContext.save()
                    self.showToast(message: "Categoria removida com sucesso!")
                }catch let error as NSError{
                    print("Erro a guardar a receita! \(error)")
                    self.showToast(message: "Ocorreu um problema, tente mais tarde!")
                }
                self.tvCatgories.reloadData()
            }
            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        action.backgroundColor = .red
        return action
    }
    
    func deleteIngredient(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Apagar") { (action, view, completion) in
            self.ingredientes.remove(at: indexPath.row)
            self.tvIngd.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            self.showToast(message: "Ingrediente removido com sucesso!")
            self.tvIngd.reloadData()
            completion(true)
            do{
                try
                    self.managedContext.save()
                self.showToast(message: "Aletracoes guardadas com sucesso!")
            }catch let error as NSError{
                print("Erro a guardar as alteracoes! \(error)")
                self.showToast(message: "Ocorreu um problema, tente mais tarde!")
            }
            self.tvIngd.reloadData()
        }
        action.image = UIImage(systemName: "trash")
        action.backgroundColor = .red
        return action
    }
    
    func saveReceita(name: String, time: String, description: String){
        var categoria: NSManagedObject!
        if selectedCatgory.isEmpty{
            self.showToast(message: "Selecione uma categoria!")
            return
        }
        for cat in categorias{
            if cat.value(forKey: "nome") as? String == selectedCatgory {
                categoria = cat
            }
        }
        if categoria == nil{
            self.showToast(message: "Selecione uma categoria!")
            return
        }
        if ingredientes.count < 1 {
            self.showToast(message: "Uma receita sem ingredientes?")
            return
        }
        let receitaVelha = receita
        receita.setValue(name, forKey: "nome")
        receita.setValue(Float(time), forKey: "tempo")
        receita.setValue(description, forKey: "descricao")
        receita.mutableSetValue(forKey: "ingredientes").addObjects(from: ingredientes)
        receita.setValue(categoria, forKey: "categoria")
        
        categoria.mutableSetValue(forKey: "receitas").add(receita!)
        if categoria != categoriaVelha {
            categoriaVelha.mutableSetValue(forKey: "receitas").remove(receitaVelha!)
        }
        
        for ing in ingredientes{
            ing.mutableSetValue(forKey: "receitas").add(receita!)
        }
        do{
            try
                managedContext.save()
        }catch let error as NSError{
            print("Erro a guardar a receita! \(error)")
            showToast(message: "Ocorreu um problema, tente mais tarde!")
        }
        showToast(message: "Receita atualizada com sucesso!")
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    func addIngrediente(name: String, quantity: NSNumber, unit: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Ingrediente", in: managedContext)!
        let ingrediente = NSManagedObject(entity: entity, insertInto: managedContext)
        
        
        ingrediente.setValue(name, forKey: "nome")
        ingrediente.setValue(quantity, forKey: "quantidade")
        ingrediente.setValue(unit, forKey: "unidade")
        
        ingredientes.append(ingrediente)
        tvIngd.reloadData()
    }
    
    func saveCategory(name: String){
        let entity = NSEntityDescription.entity(forEntityName: "Categoria", in: managedContext)!
        let categoria = NSManagedObject(entity: entity, insertInto: managedContext)
        categoria.setValue(name, forKey: "nome")
        
        do{
            try
                managedContext.save()
            categorias.append(categoria)
        }catch let error as NSError{
            print("Erro a guardar a categoria! \(error)")
        }
        tvCatgories.reloadData()
    }
    
    
    
    @IBAction func btnAddCatgory(_ sender: Any) {
        let catName = lbCatgoria.text
        if catName!.isEmpty{
            self.showToast(message: "Insira um nome para a categoria!")
        }else {
            var existe: Bool = false
            for categoria in categorias{
                if categoria.value(forKey: "nome") as? String == catName {
                    existe = true
                }
            }
            if !existe{
                saveCategory(name: catName!)
            }else{
                self.showToast(message: "Já existe esta categoria!")
            }
        }
    }
    
    @IBAction func btnAddIng(_ sender: Any) {
        let ingName = lbIngName.text!
        let ingQuant = lbIngQuantity.text!
        let ingUnit = lbIngUnit.text!
        let num = Float(ingQuant)
        if num == nil {
            self.showToast(message: "Insira uma quantidade valida!")
            return
        }
        if ingName.isEmpty || ingUnit.isEmpty || ingQuant.isEmpty{
            self.showToast(message: "Insira todos os valores do ingrediente!")
        }else {
            var existe: Bool = false
            var ing: NSManagedObject!
            for ingrediente in ingredientes{
                if ingrediente.value(forKey: "nome") as? String == ingName {
                    existe = true
                    ing = ingrediente
                }
            }
            let quant = Float(ingQuant)!
            if quant > 0{
                if !existe{
                    addIngrediente(name: ingName, quantity: NSNumber(value: quant) , unit: ingUnit)
                }else if ing != nil{
                    let originalQuant = Float((ing.value(forKey: "quantidade") as! NSNumber).stringValue)!
                    let total = quant + originalQuant
                    ing.setValue(NSNumber(value: total), forKey: "quantidade")
                }
            }else{
                self.showToast(message: "Pelo menos coloque algum \(ingName)")
            }
        }
        tvIngd.reloadData()
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        let name = lbNome.text!
        let time = lbTempo.text!
        let description = lbDescription.text!
        
        if name.isEmpty{
            self.showToast(message: "Insira o nome da receita!")
            return
        }
        if time.isEmpty{
            self.showToast(message: "Insira o tempo de preparacao da receita!")
            return
        }
        let num = Float(time)
        if num == nil {
            self.showToast(message: "Insira um tempo valido!")
            return
        }
        if description.isEmpty{
            self.showToast(message: "Insira a descrição da receita!")
            return
        }
        
        saveReceita(name: name, time: time, description: description)
        
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    deinit {
        
        // deixa de @ouvir@ o telcado
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}
