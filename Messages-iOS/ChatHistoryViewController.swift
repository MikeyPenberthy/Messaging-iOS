//
//  ChatHistoryViewController.swift
//  Messages-iOS
//
//  Created by Michael Penberthy on 8/29/16.
//  Copyright © 2016 Michael Penberthy. All rights reserved.
//

import UIKit
import Firebase

class ChatHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let currentUser: String = (FIRAuth.auth()?.currentUser?.uid)!
    var messages = [Messages]()
    var toUser: String = "alsdsfghakdjhgfaskdhfjg"
    
    let fakeUser1 = "IogQTXFINIWDwEVjNAc2YTtsnVk2"
    let fakeUser2 = "qE0yw0QDUUfi9bsvBF7s5daZuaT2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (currentUser == fakeUser1){
            toUser = fakeUser2
        } else {
            toUser = fakeUser1
        }
        
        //        var messages = [Messages]()
        let ref = FIRDatabase.database().reference().child(currentUser).child("matches").child(toUser).child("messages")
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            let fromId = snapshot.value!["fromId"] as! String
            let text = snapshot.value!["text"] as! String
            let timeStamp = snapshot.value!["timeStamp"] as! NSNumber
            let m = Messages(text: text, timeStamp: timeStamp, fromId: fromId)
            print(self.messages.count)
            
            self.messages.append(m)
            self.tableView.reloadData()
            }, withCancelBlock: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sendMessage(sender: AnyObject) {
        
        
        let userRef = FIRDatabase.database().reference().child(currentUser)
        let uMatchRef = userRef.child("matches")
        let umMessageRef = uMatchRef.child(toUser)
        let uMessageRef = umMessageRef.child("messages")
        let childRef = uMessageRef.childByAutoId()
        
        let matchedRef = FIRDatabase.database().reference().child(toUser)
        let mMatchedRef = matchedRef.child("matches")
        let umMatchRef = mMatchedRef.child(currentUser)
        let mMessageRef = umMatchRef.child("messages")
        let mChildRef = mMessageRef.childByAutoId()
        
        
        let text = chatTextField.text!
        let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        let values = ["text": text, "fromId": currentUser, "timeStamp": timeStamp]
        childRef.updateChildValues(values)
        mChildRef.updateChildValues(values)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customcell", forIndexPath: indexPath)
        cell.sizeToFit()
        cell.textLabel?.text = messages[indexPath.row].fromId
        cell.detailTextLabel?.text = messages[indexPath.row].text
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
