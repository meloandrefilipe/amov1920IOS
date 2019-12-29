//
//  AddViewController.swift
//  receitasDeCulinaria
//
//  Created by André Melo on 28/12/2019.
//  Copyright © 2019 André Melo. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var lbName: UITextField!
    @IBOutlet weak var lbTime: UITextField!
    @IBOutlet weak var lbCatgory: UITextField!
    @IBOutlet weak var lbIngName: UITextField!
    @IBOutlet weak var lbIngQuantity: UITextField!
    @IBOutlet weak var lbIngUnit: UITextField!
    @IBOutlet weak var lbDescricao: UITextView!
    @IBOutlet weak var tvCatgorys: UITableView!
    @IBOutlet weak var tvIngredients: UITableView!
    
    var categorias: [NSManagedObject] = []
    var ingredientes: [NSManagedObject] = []
    var selectedCatgory: String!
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvCatgorys{
            return categorias.count
        }else if tableView == tvIngredients {
            return ingredientes.count
        }
        return 0
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tvCatgorys{
            let cellCatgory = tableView.dequeueReusableCell(withIdentifier: "CategoryCell" ) as! NewCatgoryViewCell
            let nome = categorias[indexPath.row].value(forKey: "nome") as? String
            cellCatgory.lbCategoryName.text = nome
            if nome != selectedCatgory {
                cellCatgory.accessoryType = .none
            }else{
                cellCatgory.accessoryType = .checkmark
            }
            return cellCatgory
        }else if tableView == tvIngredients {
            let cellIngrediente = tableView.dequeueReusableCell(withIdentifier: "IngerdienteCell") as! NewIngerdienteViewCell
            cellIngrediente.lbIngName.text = ingredientes[indexPath.row].value(forKey: "nome") as? String
            let quant = ingredientes[indexPath.row].value(forKey: "quantidade") as? NSNumber
            cellIngrediente.lbIngQuantity.text = quant?.stringValue
            cellIngrediente.lbIngUni.text = ingredientes[indexPath.row].value(forKey: "unidade") as? String
            return cellIngrediente
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        selectedCatgory = cell.textLabel?.text
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        if tableView == tvIngredients {
            ingredientes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            tableView.reloadData()
        }
        if tableView == tvCatgorys {
            let categoria = categorias[indexPath.row]
            let set = categoria.value(forKey: "receitas") as! NSSet
            let connections = set.allObjects as! [NSManagedObject]
            if connections.count > 0{
                for conn in connections{
                    print(conn.value(forKey: "nome") as! String)
                }
            }else{
                print("Sem ligacoes!")
            }
        }
        return
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        selectedCatgory = ""
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        
        
        //Para @ouvir@ o teclado -> para mover a janela quando abrimos o teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        tvCatgorys.reloadData()
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
    
    
    
    @IBAction func btnAddCat(_ sender: UIButton) {
          let catName = lbCatgory.text
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
        tvIngredients.reloadData()
      }
      
      @IBAction func btnAddReceita(_ sender: Any) {
        let name = lbName.text!
        let time = lbTime.text!
        let description = lbDescricao.text!
        
        if name.isEmpty{
            self.showToast(message: "Insira o nome da receita!")
            return
        }
        if time.isEmpty{
            self.showToast(message: "Insira o tempo de preparacao da receita!")
            return
        }
        if description.isEmpty{
            self.showToast(message: "Insira a descrição da receita!")
            return
        }
        
        saveReceita(name: name, time: time, description: description)
      }
      
      @IBAction func btnCancel(_ sender: Any) {
          lbName.text = ""
          lbTime.text = ""
          lbCatgory.text = ""
          lbDescricao.text = ""
          lbIngName.text = ""
          lbIngQuantity.text = ""
          lbIngUnit.text = ""
          _ = navigationController?.popViewController(animated: true)
      }
      
    
    func saveReceita(name: String, time: String, description: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Receita", in: managedContext)!
        let receita = NSManagedObject(entity: entity, insertInto: managedContext)
        
        var categoria: NSManagedObject!
        
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
        receita.setValue(name, forKey: "nome")
        receita.setValue(Decimal(string: time), forKey: "tempo")
        receita.setValue(description, forKey: "descricao")
        receita.mutableSetValue(forKey: "ingredientes").addObjects(from: ingredientes)
        receita.setValue(categoria, forKey: "categoria")
        
        categoria.mutableSetValue(forKey: "receitas").add(receita)
        for ing in ingredientes{
            ing.mutableSetValue(forKey: "receitas").add(receita)
        }
        do{
            try
                managedContext.save()
        }catch let error as NSError{
            print("Erro a guardar a receita! \(error)")
            showToast(message: "Ocorreu um problema, tente mais tarde!")
        }
        showToast(message: "Receita Adicionada com sucesso!")
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
        tvIngredients.reloadData()
    }
    
    
    
    
    func saveCategory(name: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
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
        tvCatgorys.reloadData()
    }
    
    deinit {
        
        // deixa de @ouvir@ o telcado
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}
