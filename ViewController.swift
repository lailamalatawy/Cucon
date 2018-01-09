import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    // message vars
    var uuid = ""
    var welcome_message = ""
    var api_response = ""
    
    // bubble layout vars
    var interCellPadding: Float = 10.0
    var yOff: Int = 60
    var numLinesPrev = 1
    var previousLabelText = ""
    var previousResponse = ""
    
    
    @IBOutlet weak var infoButon: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var scrollviewKeyboard: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBAction func onSend(_ sender: UIButton) {
        
        if !(Reachability.isConnectedToNetwork()) {
            print("no internet connection.")
            DispatchQueue.main.async {
                self.displayBubble(text: "You seem to be offline. Please conncet to the internet.", alignLeft: true)
            }
        }
        
        if !(textfield.text == "") {
            if let user_response = textfield.text {
                print("user response: \(user_response)!")
                
                var base_unsaved = ""
                var dest_unsaved = ""
                
                if previousLabelText == "What's your name?" {
                    let name = user_response.firstUppercased
                    UserDefaults.standard.set(name, forKey: "name")
                    print("user name in userdefaults set to: \(name)")
                }
                
                if previousLabelText.contains("Where are you right now?") {
                    base_unsaved = user_response.firstUppercased
                }
                
                if previousLabelText.contains("country are you going to?") {
                    dest_unsaved = user_response.firstUppercased
                }
                
                
                if user_response.contains("source: ") {
                    let start = user_response.index(user_response.startIndex, offsetBy: 8)
                    let end = user_response.index(user_response.startIndex, offsetBy: user_response.count)
                    let range = start..<end
                    base_unsaved = String(user_response[range]).firstUppercased
                }
                
                if user_response.contains("dest: ") {
                    let start = user_response.index(user_response.startIndex, offsetBy: 6)
                    let end = user_response.index(user_response.startIndex, offsetBy: user_response.count)
                    let range = start..<end
                    dest_unsaved = String(user_response[range]).firstUppercased
                }
                
                // displaying user's enterd text in a bubble on screen
                DispatchQueue.main.async {
                    self.displayBubble(text: user_response, alignLeft: false)
                }
                
                // resetting to defaults
                previousResponse = user_response
                textfield.text = ""
                

                let previousLabelTextSaved = previousLabelText
                var changed = false
                
                ChatJSON.chat(uuid: self.uuid, message: user_response) { (result: ChatJSON) in
                    self.api_response = result.json_returned["message"]!
                    print("api_response: \(self.api_response)")
                    
                    if self.api_response.contains("Hello") {
                        let name_fetched = UserDefaults.standard.object(forKey: "name") as? String
                        self.api_response = "Hello \(name_fetched ?? "?")! Where are you right now?"
                        changed = true
                    }
                    
                    if self.api_response.contains("Invalid") {
                        let name_fetched = UserDefaults.standard.object(forKey: "name") as? String
                        self.api_response = "Sorry \(name_fetched ?? "?"), the country name you entered seems to be invalid. Try entering a valid one."
                        changed  = true
                    }
                    
                    if self.api_response.contains("So you are from") {
                        UserDefaults.standard.set(base_unsaved, forKey: "base")
                        print("base country in userdefaults set to: \(base_unsaved)")
                        
                        let base_fetched = UserDefaults.standard.object(forKey: "base") as? String
                        self.api_response = "\(base_fetched ?? "?"), noted. And which country are you going to?"
                        changed = true
                    }
                    
                    if self.api_response.contains("So you are going") {
                        UserDefaults.standard.set(dest_unsaved, forKey: "dest")
                        print("destination country in userdefaults set to: \(dest_unsaved)")
                        
                        let destination_fetched = UserDefaults.standard.object(forKey: "dest") as? String
                        self.api_response = "\(destination_fetched ?? "?"), awesome!"
                        changed = true
                    }
                    
                    if self.api_response.contains("source country changed successfully") {
                        UserDefaults.standard.set(base_unsaved, forKey: "base")
                        print("source country in userdefaults changed to: \(base_unsaved)")
                        self.api_response = "Source country changed successfully to \(base_unsaved)."
                    }
                    
                    if self.api_response.contains("destination country changed successfully") {
                        UserDefaults.standard.set(dest_unsaved, forKey: "dest")
                        print("destination country in userdefaults changed to: \(dest_unsaved)")
                        self.api_response = "Destination country changed successfully to \(dest_unsaved)."
                    }

                    DispatchQueue.main.async {
                        if changed {
                            self.displayBubble(text: self.api_response, alignLeft: true)
                            self.previousLabelText = self.api_response
                        }

                        if self.api_response.contains("awesome") {
                            self.displayInfo(gibberish: false)
                        } else if self.api_response.contains("<country>") {
                            self.displayInfo(gibberish: true)
                        } else if self.api_response.contains("valid") {
                            var text = ""
                            if previousLabelTextSaved.contains("Where are you right now?") {
                                text = "Where are you right now?"           // reinquire source country
                            } else if previousLabelTextSaved.contains("country are you going to?") {
                                text = "Which country are you going to?"    // reinquire destination country
                            }
                            
                            
                            if !(text == "") {
                                self.displayBubble(text: text, alignLeft: true)
                                self.previousLabelText = text
                            }
                        } else if !changed {
                            self.displayBubble(text: self.api_response, alignLeft: true)
                            self.previousLabelText = self.api_response
                        }
                    }
                }
            } else {
                print("No response was received.")
            }
        }
    }
    
    
    @IBAction func onHistoryButtonTouch(_ sender: UIButton) {
        var text = ""
        DispatchQueue.main.async {
            let alignLeft = true
            
            if let base_fetched = UserDefaults.standard.object(forKey: "base") as? String {
                if let destination_fetched = UserDefaults.standard.object(forKey: "dest") as? String {
                    text = "Source country: \(base_fetched)"
                    let bubble1 = self.chatBubble(text: text, y_offset: self.yOff, leftAligned: alignLeft)
                    print("bubble content:  \(text)")
                    self.mainview.addSubview(bubble1)
                    
                    text = "Destination country: \(destination_fetched)"
                    let bubble2 = self.chatBubble(text: text, y_offset: self.yOff, leftAligned: alignLeft)
                    print("bubble content:  \(text)")
                    self.mainview.addSubview(bubble2)
                } else {
                    text = "Source country: \(base_fetched)"
                    self.displayBubble(text: text, alignLeft: true)
                }
            } else {
                text = "Sorry, there are no saved settings."
                self.displayBubble(text: text, alignLeft: true)
            }
        }
    }
    
    @IBAction func onInfoButtonTouch(_ sender: UIButton) {
         DispatchQueue.main.async {
            self.displayInfo(gibberish: false)
        }
    }
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        if let name_fetched = UserDefaults.standard.object(forKey: "name") as? String {
            print("name: \(name_fetched)")
        }
        if let base_fetched = UserDefaults.standard.object(forKey: "base") as? String {
            print("base: \(base_fetched)")
        }
        if let destination_fetched = UserDefaults.standard.object(forKey: "dest") as? String {
            print("dest: \(destination_fetched)")
        }
        
        // Textfield Layout
        textfield.layer.cornerRadius = 10
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))   // the padding view of the textfield
        textfield.leftViewMode = .always
        textfield.placeholder = "Type text here..."
        
        // Send Button Layout
        button.layer.cornerRadius = 10
        
        
        if Reachability.isConnectedToNetwork(){
            print("internet connection available.")
            
        } else {
            print("no internet connection.")
            DispatchQueue.main.async {
                self.displayBubble(text: "You seem to be offline. Please conncet to the internet.", alignLeft: true)
            }
        }
        
        
        WelcomeJSON.welcome { (result: WelcomeJSON) in
            self.uuid = result.json_returned["uuid"]!
            print("json received uuid: \(self.uuid)")
            self.welcome_message = result.json_returned["message"]!
  
            DispatchQueue.main.async {
                if let name_fetched = UserDefaults.standard.object(forKey: "name") as? String {
                    self.welcome_message = "Welcome back, \(name_fetched)!"
                    self.previousLabelText = self.welcome_message
                } else {
                    let text = "Hi, mate! Welcome to Cucon. My name is Chip, I'm here to help you out."
                    self.displayBubble(text: text, alignLeft: true)
                    self.previousLabelText = "What's your name?"
                }
                
                self.displayBubble(text: self.welcome_message, alignLeft: true)
            }
            
            self.previousLabelText = self.welcome_message
            print("uuid: \(self.uuid)")
            print("message: \(self.welcome_message)")
           
            
            
            // Retrieving from cell
            if let name_fetched = (UserDefaults.standard.object(forKey: "name") as? String) {
                var internal_message = ""
                print("Name fetched: \(name_fetched)")
                
                ChatJSON.chat(uuid: self.uuid, message: name_fetched) { (result: ChatJSON) in
                    internal_message = result.json_returned["message"]!
                    print("internal_received_message: \(internal_message)")
                }
                
                if let base_fetched = UserDefaults.standard.object(forKey: "base") as? String {
                    print("Base fetched: \(base_fetched)")
                    
                    ChatJSON.chat(uuid: self.uuid, message: base_fetched) { (result: ChatJSON) in
                        internal_message = result.json_returned["message"]!
                        print("internal_received_message: \(internal_message)")
                    }
                    
                    if let destination_fetched = UserDefaults.standard.object(forKey: "dest") as? String {
                        ChatJSON.chat(uuid: self.uuid, message: destination_fetched) { (result: ChatJSON) in
                            internal_message = result.json_returned["message"]!
                            print("internal_received_message: \(internal_message)")
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            let text = "Which country are you going to?"
                            self.displayBubble(text: text, alignLeft: true)
                            self.previousLabelText = text
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        let text = "Where are you right now?"
                        self.displayBubble(text: text, alignLeft: true)
                        self.previousLabelText = text
                    }
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func chatBubble(text: String, y_offset: Int, leftAligned: Bool) -> UIView {
        
        let maxWidth: Float = 200.0
        let intraCellPadding: Float = 12.0
        
        let label = UILabel(frame: CGRect(x: Int(intraCellPadding) + 5, y: Int(intraCellPadding), width: Int(maxWidth), height:0))
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.text = text
        label.numberOfLines = 0
        label.sizeToFit()
        
        let width : CGFloat = label.frame.size.width
        let height : CGFloat = label.frame.size.height
        let w =  UIScreen.main.bounds.width
        let x_offset = leftAligned ? (intraCellPadding + 5) : Float(w)-3 * (intraCellPadding + 5) - Float(width)
        
        let bubbleView = UIView(frame: CGRect(x: Int(x_offset), y: yOff, width: Int(Float(width) + 2 * (intraCellPadding + 5)), height: Int(Float(height) + 2 * intraCellPadding)))
        bubbleView.backgroundColor = leftAligned ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bubbleView.layer.cornerRadius = CGFloat(intraCellPadding) + 10
        bubbleView.addSubview(label)
        
        numLinesPrev = lines(label: label)
        print(numLinesPrev)
        yOff += 30 + numLinesPrev * 22
        
        return bubbleView
    }
    
    
    func lines(label: UILabel) -> Int {
        let textSize = CGSize(width: label.frame.size.width, height: CGFloat(Float.infinity))
        let rHeight = lroundf(Float(label.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(label.font.lineHeight))
        let lineCount = rHeight/charSize
        return lineCount
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollviewKeyboard.setContentOffset(CGPoint(x: 0, y: 250), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollviewKeyboard.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func displayBubble(text: String, alignLeft: Bool) {
        let bubble = self.chatBubble(text: text, y_offset: self.yOff, leftAligned: alignLeft)
        print("bubble content:  \(text)")
        self.mainview.addSubview(bubble)
    }
    
    func displayInfo(gibberish: Bool) {
        let alignLeft = true
        var text = ""
        
        if gibberish {
            text = "I can't quite get what you're saying. Here are some tips that might help you out:"
        } else {
            text = "Here are some tips that might help you out:"
        }
        
        let bubble1 = self.chatBubble(text: text, y_offset: self.yOff, leftAligned: alignLeft)
        let bubble2 = self.chatBubble(text: "To change currency from the source to the destination country, just type in the amount straight away", y_offset: self.yOff, leftAligned: alignLeft)
        let bubble3 = self.chatBubble(text: "To change source country, just type in: source: <new_country_name>", y_offset: self.yOff, leftAligned: alignLeft)
        let bubble4 = self.chatBubble(text: "To change destination country, just type in: dest: <new_country_name>", y_offset: self.yOff, leftAligned: alignLeft)
        
        self.mainview.addSubview(bubble1)
        self.mainview.addSubview(bubble2)
        self.mainview.addSubview(bubble3)
        self.mainview.addSubview(bubble4)
    }

}



class myUILabel : UILabel {
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        
    }
}


extension UIScrollView {
    //it will block the mainThread
    func recalculateVerticalContentSize_synchronous () {
        let unionCalculatedTotalRect = recursiveUnionInDepthFor(view: self)
        self.contentSize = CGRect(x:0, y:0, width:self.frame.width, height:unionCalculatedTotalRect.height).size;
    }
    
    private func recursiveUnionInDepthFor (view: UIView) -> CGRect {
        var totalRect = CGRect.zero
        //calculate recursevly for every subView
        for subView in view.subviews {
            totalRect =  totalRect.union(recursiveUnionInDepthFor(view: subView))
        }
        //return the totalCalculated for all in depth subViews.
        return totalRect.union(view.frame)
    }
}


extension String {
    var firstUppercased: String {
        guard let first = first else {
            return "error getting first character of string."
            
        }
        return String(first).uppercased() + dropFirst()
    }
}


//extension UIViewController {
//    func hideKeyboardWhenTappedAround() {
//            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//            tap.cancelsTouchesInView = false
//            view.addGestureRecognizer(tap)
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}






