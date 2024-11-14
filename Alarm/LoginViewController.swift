//
//  LoginViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 22/5/24.
//

import UIKit

import UserNotifications

import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTxtfield: UITextField!
    @IBOutlet var passwordTxtfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
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
                
                DispatchQueue.main.async {
                    self.present(navController, animated: true)
                }
            }
            
            if let _ = error {
                let alertController = UIAlertController.init(title: "Error", message: "Username or password is incorrect", preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "OK", style: .default) { action in
                    DispatchQueue.main.async {
                        self.emailTxtfield.text = ""
                        self.passwordTxtfield.text = ""
                    }
                }
                alertController.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true)
                }
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
