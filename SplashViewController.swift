import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        perform(#selector(showNavController), with: nil, afterDelay: 1)
    }
    
    @objc func showNavController() {
        performSegue(withIdentifier: "splashSegue", sender: self)
    }
    
    

}
