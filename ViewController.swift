import UIKit


class ViewController: UIViewController, UITextFieldDelegate {
    
    var uuid = ""
    var welcome_message = ""
    var received_message = ""
    
    var interCellPadding: Float = 10.0
    var yOff: Int = 60
    var previousWasLeft = false
    
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
    
    @IBAction func onGo(_ sender: UIButton) {
        
        if !(Reachability.isConnectedToNetwork()) {
            print("Internet Connection not Available!")
            DispatchQueue.main.async {
                let alignLeft = true
                self.previousWasLeft = alignLeft
                
                let bubble = self.chatBubble(text: "You seem to be offline. Please conncet to the internet.", y_offset: self.yOff, leftAligned: alignLeft)
                self.mainview.addSubview(bubble)
            }
        }
        
        if !(textfield.text == "") {
            if let response = textfield.text {
                print("user response: \(response)!")
                
                if previousLabelText == "What's your name?" {
                    UserDefaults.standard.set(response, forKey: "name")
                }
                
                if previousLabelText.contains("Where are you right now?") {
                    UserDefaults.standard.set(response, forKey: "base")
                }
                
                if previousLabelText.contains("country are you going to?") {
                    UserDefaults.standard.set(response, forKey: "dest")
                }
                
                
                if response.contains("source: ") {
                    let start = response.index(response.startIndex, offsetBy: 8)
                    let end = response.index(response.startIndex, offsetBy: response.count)
                    let range = start..<end
                    let country = response[range]
                    print("COUNTRURUURURURUU: \(country)")
                    UserDefaults.standard.set(country, forKey: "base")
                }
                
                if response.contains("dest: ") {
                    let start = response.index(response.startIndex, offsetBy: 6)
                    let end = response.index(response.startIndex, offsetBy: response.count)
                    let range = start..<end
                    let country = response[range]
                    print("COUNTRURUURURURUU: \(country)")
                    UserDefaults.standard.set(country, forKey: "dest")
                }
                
                
                DispatchQueue.main.async {
                    let alignLeft = false
                    self.previousWasLeft = alignLeft
                    let bubble = self.chatBubble(text: response, y_offset: self.yOff, leftAligned: alignLeft)
                    self.mainview.addSubview(bubble)
                }
                
                previousResponse = response
                textfield.text = ""
                

                ChatJSON.chat(uuid: self.uuid, message: response) { (result: ChatJSON) in
                    self.received_message = result.json_returned["message"]!
                    print("received_message: \(self.received_message)")
                    
                    if self.received_message.contains("Hello") {
                        let x = UserDefaults.standard.object(forKey: "name") as? String
                        self.received_message = "Hello \(x ?? "?")! Where are you right now?"
                    }
                    
                    if self.received_message.contains("Invalid") {
                        let x = UserDefaults.standard.object(forKey: "name") as? String
                        self.received_message = "Sorry \(x ?? "?"), the country name you entered seems to be invalid. Try entering a valid one."
                    }
                    
                    if self.received_message.contains("So you are from") {
                        let x = UserDefaults.standard.object(forKey: "base") as? String
                        self.received_message = "\(x ?? "?"), noted. And which country are you going to?"
                    }
                    
                    if self.received_message.contains("So you are going") {
                        let x = UserDefaults.standard.object(forKey: "dest") as? String
                        self.received_message = "\(x ?? "?"), awesome!"
                    }
                    
                    DispatchQueue.main.async {
                        let alignLeft = true
                        self.previousWasLeft = alignLeft
                        
                        if self.received_message.contains("<country>") {
                            let bubble1 = self.chatBubble(text: "Here are some tips that will help you out:", y_offset: self.yOff, leftAligned: alignLeft)
                            let bubble2 = self.chatBubble(text: "To change currency from the source to the destination country, just type in the amount straight away", y_offset: self.yOff, leftAligned: alignLeft)
                            let bubble3 = self.chatBubble(text: "To change source country, just type in: source: <new_country_name>", y_offset: self.yOff, leftAligned: alignLeft)
                            let bubble4 = self.chatBubble(text: "To change destination country, just type in: dest: <new_country_name>", y_offset: self.yOff, leftAligned: alignLeft)
                            
                            self.mainview.addSubview(bubble1)
                            self.mainview.addSubview(bubble2)
                            self.mainview.addSubview(bubble3)
                            self.mainview.addSubview(bubble4)
                        } else {
                            let bubble = self.chatBubble(text: self.received_message, y_offset: self.yOff, leftAligned: alignLeft)
                            self.mainview.addSubview(bubble)
                        }
                        
                        print("rec message: \(self.received_message)")
                        print("prev label: \(self.previousLabelText)")
                        
                        if self.received_message.contains("awesome") || self.received_message.contains("<country>") {
                            let bubble1 = self.chatBubble(text: "Here are some tips that will help you out:", y_offset: self.yOff, leftAligned: alignLeft)
                            let bubble2 = self.chatBubble(text: "To change currency from the source to the destination country, just type in the amount straight away", y_offset: self.yOff, leftAligned: alignLeft)
                            let bubble3 = self.chatBubble(text: "To change source country, just type in: source: <new_country_name>", y_offset: self.yOff, leftAligned: alignLeft)
                            let bubble4 = self.chatBubble(text: "To change destination country, just type in: dest: <new_country_name>", y_offset: self.yOff, leftAligned: alignLeft)
                            
                            self.mainview.addSubview(bubble1)
                            self.mainview.addSubview(bubble2)
                            self.mainview.addSubview(bubble3)
                            self.mainview.addSubview(bubble4)
                        }
                        
                        
                        
                        if self.received_message.contains("valid") {
                            print("TRUE")
                            if self.previousLabelText.contains("Where are you right now?") {
                                UserDefaults.standard.set(nil, forKey: "base")
                            } else if self.previousLabelText.contains("country are you going to?") {
                                UserDefaults.standard.set(nil, forKey: "dest")
                            }
                            
                        } else {
                            self.previousLabelText = self.received_message
                            print("FALSE")
                        }
                        
                        if self.received_message.contains("valid") {
                            var text = ""
                            if self.previousLabelText.contains("country are you going to?") {
                                text = "Which country are you going to?"
                            } else if self.previousLabelText.contains("Where are you right now?") {
                                text = "Where are you right now?"
                            }
                            
                            print("text: \(text)")
                            if !(text == "") {
                                let bubble = self.chatBubble(text: text, y_offset: self.yOff, leftAligned: alignLeft)
                                self.mainview.addSubview(bubble)
                                self.previousLabelText = text
                            }
                  
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
        if let x = UserDefaults.standard.object(forKey: "base") as? String {
            if let y = UserDefaults.standard.object(forKey: "dest") as? String {
                text = "Base country: \(x), destination country: \(y)"
            } else {
                text = "Base country: \(x)"
            }
        } else {
            text = "Sorry, there are no saved setting yet."
        }

        DispatchQueue.main.async {
            let alignLeft = true
            self.previousWasLeft = alignLeft
            let bubble = self.chatBubble(text: text, y_offset: self.yOff, leftAligned: alignLeft)
            self.mainview.addSubview(bubble)
        }
        
    }
    
    @IBAction func onInfoButtonTouch(_ sender: UIButton) {
         DispatchQueue.main.async {
            let alignLeft = true
            self.previousWasLeft = alignLeft
            
            let bubble1 = self.chatBubble(text: "Here are some tips that will help you out:", y_offset: self.yOff, leftAligned: alignLeft)
            let bubble2 = self.chatBubble(text: "To change currency from the source to the destination country, just type in the amount straight away", y_offset: self.yOff, leftAligned: alignLeft)
            let bubble3 = self.chatBubble(text: "To change source country, just type in: source: <new_country_name>", y_offset: self.yOff, leftAligned: alignLeft)
            let bubble4 = self.chatBubble(text: "To change destination country, just type in: des:t <new_country_name>", y_offset: self.yOff, leftAligned: alignLeft)
            
            self.mainview.addSubview(bubble1)
            self.mainview.addSubview(bubble2)
            self.mainview.addSubview(bubble3)
            self.mainview.addSubview(bubble4)
        }
    }
    
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        if let x = UserDefaults.standard.object(forKey: "name") as? String {
            print("name: \(x)")
        }
        if let x = UserDefaults.standard.object(forKey: "base") as? String {
            print("base: \(x)")
        }
        if let x = UserDefaults.standard.object(forKey: "dest") as? String {
            print("dest: \(x)")
        }
        
        
        
        textfield.layer.cornerRadius = 10
        button.layer.cornerRadius = 10
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textfield.leftView = paddingView
        textfield.leftViewMode = .always
        textfield.placeholder = "Type text here..."
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
        } else {
            print("Internet Connection not Available!")
            DispatchQueue.main.async {
                let alignLeft = true
                self.previousWasLeft = alignLeft
                
                let bubble = self.chatBubble(text: "You seem to be offline. Please conncet to the internet.", y_offset: self.yOff, leftAligned: alignLeft)
                self.mainview.addSubview(bubble)
            }
        }
        
        
        WelcomeJSON.welcome { (result: WelcomeJSON) in
            self.uuid = result.json_returned["uuid"]!
            print("SELF UUID: \(self.uuid)")
            self.welcome_message = result.json_returned["message"]!
  
            DispatchQueue.main.async {
                let alignLeft = true
                self.previousWasLeft = alignLeft
                if let x = UserDefaults.standard.object(forKey: "name") as? String {
                    self.welcome_message = "Welcome back, \(x)!"
                    self.previousLabelText = "Welcome back, \(x)!"
                } else {
                    let bubble = self.chatBubble(text: "Hi mate! Welcome to Cucon. My name is Chip, I'm here to help you out.", y_offset: self.yOff, leftAligned: alignLeft)
                    self.mainview.addSubview(bubble)
                    self.previousLabelText = "What's your name?"
                }
                
                let bubble = self.chatBubble(text: self.welcome_message, y_offset: self.yOff, leftAligned: alignLeft)
                self.mainview.addSubview(bubble)
            }
            self.previousLabelText = self.welcome_message
            print("uuid: \(self.uuid)")
            print("message: \(self.welcome_message)")
            
            
            
            // RETRIEVING FROM CELL
            
            if let x = (UserDefaults.standard.object(forKey: "name") as? String) {
                var internal_message = ""
                print("HERE name: \(x)")
                
                ChatJSON.chat(uuid: self.uuid, message: x) { (result: ChatJSON) in
                    internal_message = result.json_returned["message"]!
                    print("internal_received_message: \(internal_message)")
                }
                
                if let x = UserDefaults.standard.object(forKey: "base") as? String {
                    print("HERE base: \(x)")
                    print("HERE uuid: \(self.uuid)")
                    
                    ChatJSON.chat(uuid: self.uuid, message: x) { (result: ChatJSON) in
                        internal_message = result.json_returned["message"]!
                        print("internal_received_message: \(internal_message)")
                    }
                    
                    if let x = UserDefaults.standard.object(forKey: "dest") as? String {
                        ChatJSON.chat(uuid: self.uuid, message: x) { (result: ChatJSON) in
                            internal_message = result.json_returned["message"]!
                            print("internal_received_message: \(internal_message)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alignLeft = true
                            self.previousWasLeft = alignLeft
                            let text = "Which country are you going to?"
                            let bubble = self.chatBubble(text: text , y_offset: self.yOff, leftAligned: alignLeft)
                            self.mainview.addSubview(bubble)
                            self.previousLabelText = text
                        }
                    }
                    
                    
                } else {
                    DispatchQueue.main.async {
                        let alignLeft = true
                        self.previousWasLeft = alignLeft
                        let text = "Where are you right now?"
                        let bubble = self.chatBubble(text: text, y_offset: self.yOff, leftAligned: alignLeft)
                        self.mainview.addSubview(bubble)
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






