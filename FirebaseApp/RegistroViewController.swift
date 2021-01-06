//
//  RegistroViewController.swift
//  FirebaseApp
//
//  Created by Mac19 on 04/01/21.
//

import UIKit
import FirebaseAuth

class RegistroViewController: UIViewController {

    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var correoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registrarUsuario(_ sender: UIButton) {
        
        if let email = correoTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e.localizedDescription)
                    if(e.localizedDescription.contains("password")){
                        self.alerta(mensaje: "La contraseña debe tener al menos 6 caracteres")
                    }else if e.localizedDescription.contains("email") {
                        self.alerta(mensaje: "Ingresa un correo válido")
                    }
                    
                }else{
                    //Ya podemos registrar el usuario
                    self.performSegue(withIdentifier: "menuPrincipal", sender: self)
                    
                }
              // ...
            }
        }

    }
    
    func alerta (mensaje : String ){
        let alerta = UIAlertController(title: "Error", message: "Verifica los datos proporcionados. \n \(mensaje)", preferredStyle: .alert)
        let accion = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(accion)
        present(alerta, animated: true, completion: nil)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
