import Foundation

struct WelcomeJSON {
    
    var json_returned = [String:String]()
    
    static func welcome(completion: @escaping (WelcomeJSON) -> ()) {
        guard let welcome_url = URL(string: "https://thawing-forest-80216.herokuapp.com/welcome") else {
            print("URL used is invalid.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: welcome_url) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var welcomeJSON = WelcomeJSON()
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:String] {
                        welcomeJSON.json_returned = json
                    }
                } catch {
                    print("Error serializing json: " + error.localizedDescription)
                }
                completion(welcomeJSON)
            }
        }
        task.resume()
    }
    
}



struct ChatJSON {
    
    var json_returned = [String:String]()
    
    static func chat(uuid: String, message: String, completion: @escaping (ChatJSON) -> ()) {
        guard let chat_url = URL(string: "https://thawing-forest-80216.herokuapp.com/chat") else {
            print("URL used is invalid.")
            return
        }
        
        let jsonObject: [String:String] = ["message":message]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) else {
            print("Serialization of message failed.")
            return
        }
        
        var request = URLRequest(url: chat_url)
        request.httpMethod = "POST"
        request.setValue(uuid, forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody

        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var chatJSON = ChatJSON()
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:String] {
                        chatJSON.json_returned = json
                    }
                } catch {
                    print("Error serializing json: " + error.localizedDescription)
                }
                completion(chatJSON)
            }
        }
        task.resume()
    }
    
}


