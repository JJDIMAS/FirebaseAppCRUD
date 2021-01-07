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
    
    var contactos = [Contacto]()

    @IBOutlet weak var alumnosTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        cargarDatos()
        // Do any additional setup after loading the view.
    }
    func cargarDatos(){
        var newContacto = Contacto()
        let db = Firestore.firestore()
        db.collection("contactos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err.localizedDescription)")
            } else {
                self.contactos.removeAll()
                //Se obtuvieron los datos correctamente
                for document in querySnapshot!.documents {
                    newContacto.nombre = document.data()["nombre"] as? String
                    newContacto.telefono = document.data()["telefono"] as? String
                    newContacto.ID = document.documentID
                    self.contactos.append(newContacto)
                    //self.contactos.append(document.data()["nombre"] as! String)
                    //print("\(document.documentID) => \(document.data())")
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
            //self.alumnosTable.reloadData()
            self.cargarDatos()
        }
        alerta.addAction(actionAceptar)
        present(alerta, animated: true, completion: nil)
    }
}

extension AlumnosViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = alumnosTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        celda.textLabel?.text = contactos[indexPath.row].nombre
        celda.detailTextLabel?.text = contactos[indexPath.row].telefono
        return celda
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Creamos el boton de eliminar
        let delete = UIContextualAction(style: .destructive, title: "Delete"){ (action, view, completition) in
            //Eliminar elemento de la colección
            let db = Firestore.firestore()
            db.collection("contactos").document(self.contactos[indexPath.row].ID!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err.localizedDescription)")
                } else {
                    print("Document successfully removed!")
                    self.alumnosTable.reloadData()
                    self.cargarDatos()
                }
            }
            completition(true)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Editar"){
            (action,view,completition) in
            //Crear la alerta y meter los datos
            let alerta = UIAlertController(title: "Editar alumno", message: "Ingresa los nuevos datos", preferredStyle: .alert)
            alerta.addTextField{
                (nombreAlert) in nombreAlert.text = self.contactos[indexPath.row].nombre
            }
            alerta.addTextField{
                (telefonoAlert) in telefonoAlert.text = self.contactos[indexPath.row].telefono
            }
            let actionAceptar = UIAlertAction(title: "Aceptar", style: .default){ _ in
                
                guard let nombreAlert = alerta.textFields?.first?.text else {return}
                guard let telefonoAlert = alerta.textFields?.last?.text else {return}
                
                let db = Firestore.firestore()
                db.collection("contactos").document(self.contactos[indexPath.row].ID!).setData([
                    "nombre": nombreAlert,
                    "telefono": telefonoAlert
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        self.alumnosTable.reloadData()
                        self.cargarDatos()
                    }
                }

            }
            alerta.addAction(actionAceptar)
            self.present(alerta, animated: true, completion: nil)


            completition(true)
        }
        //Añadimos boton de editar
        let config = UISwipeActionsConfiguration(actions: [delete,edit])
        config.performsFirstActionWithFullSwipe = false
        
        
        return config
    }
}
