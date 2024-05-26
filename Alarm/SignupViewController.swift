//
//  SignupViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 22/5/24.
//

import UIKit

import FirebaseAuth

class SignupViewController: UIViewController {
    
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signup() {
        guard let email = emailTextfield.text else {
            return
        }
        
        guard let password = passwordTextfield.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let _ = result {
                let alert = UIAlertController.init(title: "Success", message: "Signed up successfully", preferredStyle: .alert)
                
                let okAction = UIAlertAction.init(title: "OK", style: .default) { action in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                alert.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
            
            if let error = error {
                let alert = UIAlertController.init(title: "Error", message: "Invalid email", preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "OK", style: .default) { action in
                    // reset all the fields if email input is invalid
                    self.emailTextfield.text = ""
                    self.passwordTextfield.text = ""
                }
                
                alert.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
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
