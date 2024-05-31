//
//  LoginViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 22/5/24.
//

import UIKit

import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTxtfield: UITextField!
    @IBOutlet var passwordTxtfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login() {
        guard let email = self.emailTxtfield.text else {
            return
        }
        
        guard let password = self.passwordTxtfield.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let _ = result {
                guard let navController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "NavigationController") as? UINavigationController else {
                    return
                }
                
                navController.modalPresentationStyle = .fullScreen
                
                self.present(navController, animated: true)
            }
        }
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
