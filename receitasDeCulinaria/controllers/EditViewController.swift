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

class EditViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    
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
