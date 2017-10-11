// Tự học Swift 4.0 - xuanvinhtd

import Foundation

final class EMAlert {
    class func alert(title: String, message: String, dismissTitle: String, inViewController viewController: UIViewController?, withDismissAction dismissAction: (() -> Void)?) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action: UIAlertAction = UIAlertAction(title: dismissTitle, style: .default, handler: { action in
                guard let dismissAction = dismissAction else {
                    print("Not found action of Alert!")
                    return
                }
                dismissAction()
            })
            
            alertController.addAction(action)
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func alertSorry(message: String?, inViewController viewController: UIViewController?, withDismissAction dismissAction: @escaping () -> Void) {
        
        alert(title: NSLocalizedString("Sorry", comment: ""), message: message!, dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: viewController, withDismissAction: dismissAction)
    }
    
    class func alertSorry(message: String?, inViewController viewController: UIViewController?) {
        
        alert(title: NSLocalizedString("Sorry", comment: ""), message: message!, dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: viewController, withDismissAction: nil)
    }
    
    class func textInput(title: String, placeholder: String?, oldText: String?, dismissTitle: String, inViewController viewController: UIViewController, withFinishedAction finishedAction: ((_ text: String) -> Void)?) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = placeholder
                textField.text = oldText
            })
            
            let action: UIAlertAction = UIAlertAction(title: title, style: .default, handler: { action in
                guard let finishedAction = finishedAction else {
                    print("Not found action of Alert Text Input")
                    return
                }
                
                guard let textField = alertController.textFields?.first, let text = textField.text else {
                    print("Not found text input in Alert text input")
                    return
                }
                
                finishedAction(text)
            })
            
            alertController.addAction(action)
            
            alertController.view.setNeedsLayout()
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func alertConfirm(title: String, message: String?, confirmTitle: String?, dismissTitle: String, inViewController viewController: UIViewController, withFinishedAction finishedAction: ((_ result: Bool) -> Void)?) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let actionCancel: UIAlertAction = UIAlertAction(title: dismissTitle, style: .default, handler: { action in
                guard let finishedAction = finishedAction else {
                    return
                }
                finishedAction(false)
            })
            
            let actionConfirm: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default, handler: { action in
                guard let finishedAction = finishedAction else {
                    return
                }
                finishedAction(true)
            })
            
            alertController.addAction(actionConfirm)
            alertController.addAction(actionCancel)
            
            alertController.view.setNeedsLayout()
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
