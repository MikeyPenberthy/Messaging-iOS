//
//  ChatViewController.swift
//  Messages-iOS
//
//  Created by Michael Penberthy on 8/30/16.
//  Copyright © 2016 Michael Penberthy. All rights reserved.
//

import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    let currentUser: String = (FIRAuth.auth()?.currentUser?.uid)!
    var serverMessages = [Messages]()
    var toUser: String = "alsdsfghakdjhgfaskdhfjg"
    
    let fakeUser1 = "IogQTXFINIWDwEVjNAc2YTtsnVk2"
    let fakeUser2 = "qE0yw0QDUUfi9bsvBF7s5daZuaT2"
    let imageURL = NSURL(string: "http://1.bp.blogspot.com/-KuFrhzsc2TE/U-STcx4dZGI/AAAAAAAAKWQ/rngsW25GXwk/s1600/Hot+Selfie+Ideas+and+Photo+(7).jpg")
    var ava: UIImage?
    // sets chat bubble colors
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAvatarImage()
        self.setup()
        self.addMessages()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
}

//MARK - Set Up
extension ChatViewController {
    
    func addMessages() {
        self.messages = []
        reloadMessagesView()
        for i in 0..<serverMessages.count {
            let sender = (serverMessages[i].fromId != currentUser) ? "Server" : self.senderId
            let messageContent = serverMessages[i].text
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
        self.reloadMessagesView()
    }
    
    func setup() {
        if (currentUser == fakeUser1){
            toUser = fakeUser2
        } else {
            toUser = fakeUser1
        }
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.title = toUser
        self.inputToolbar.contentView.leftBarButtonItem = nil
        let ref = FIRDatabase.database().reference()
            .child(currentUser).child("matches").child(toUser).child("messages")
        
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            let fromId = snapshot.value!["fromId"] as! String
            let text = snapshot.value!["text"] as! String
            let timeStamp = snapshot.value!["timeStamp"] as! NSNumber
            let m = Messages(text: text, timeStamp: timeStamp, fromId: fromId)
            print(self.serverMessages.count)
            self.serverMessages.append(m)
            self.addMessages()
            }, withCancelBlock: nil)
    }
    
    func getAvatarImage(){
        if let imageURL = imageURL {
            NSURLSession.sharedSession().dataTaskWithURL(imageURL, completionHandler :{(data,responce, error) in
                if let data = data {
                    self.ava = UIImage(data:data)
                }
                dispatch_async(dispatch_get_main_queue(), {
                self.reloadMessagesView()
                })
                
            }).resume()
            
        }
    }
    
}

//MARK - Data Source
extension ChatViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        if ava == nil {
            return nil
        } else {
            return JSQMessagesAvatarImageFactory.avatarImageWithPlaceholder(ava , diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
    }
    
}

//MARK - Toolbar
extension ChatViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
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
        
        
        let text = text
        let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        let values = ["text": text, "fromId": currentUser, "timeStamp": timeStamp]
        childRef.updateChildValues(values)
        mChildRef.updateChildValues(values)
        
        
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}