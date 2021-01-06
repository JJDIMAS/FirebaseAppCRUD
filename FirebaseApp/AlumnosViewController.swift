//
//  AlumnosViewController.swift
//  FirebaseApp
//
//  Created by Mac19 on 05/01/21.
//

import UIKit
import Firebase
import FirebaseAuth


class AlumnosViewController: UIViewController {
    
    var contactos = [String]()

    @IBOutlet weak var alumnosTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        cargarDatos()
        // Do any additional setup after loading the view.
    }
    func cargarDatos(){
        let db = Firestore.firestore()
        db.collection("contactos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err.localizedDescription)")
            } else {
                //Se obtuvieron los datos correctamente
                for document in querySnapshot!.documents {
                    self.contactos.append(document.data()["nombre"] as! String)
                    print("\(document.documentID) => \(document.data())")
                }
                self.alumnosTable.reloadData()
            }
        }
    }
    
    @IBAction func cerrarSesion(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            }
        
    }
    
    @IBAction func agregarAlumno(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Agregar alumno", message: "Nuevo", preferredStyle: .alert)
        alerta.addTextField{
            (nombreAlert) in nombreAlert.placeholder = "Nombre"
        }
        alerta.addTextField{
            (telefonoAlert) in telefonoAlert.placeholder = "Telefono"
        }
        let actionAceptar = UIAlertAction(title: "Agregar", style: .default){ _ in
            
            guard let nombreAlert = alerta.textFields?.first?.text else {return}
            guard let telefonoAlert = alerta.textFields?.last?.text else {return}
            
            let db = Firestore.firestore()
            db.collection("contactos").addDocument(data: ["nombre": nombreAlert, "telefono": telefonoAlert])
        }
        alerta.addAction(actionAceptar)
        present(alerta, animated: true, completion: nil)
        alumnosTable.reloadData()
        
    }
}

extension AlumnosViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = alumnosTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        celda.textLabel?.text = contactos[indexPath.row]
        return celda
    }
    
    
}
