//
//  ViewController.swift
//  MultipeerChatDemo
//
//  Created by Go Sato on 2015/11/26.
//  Copyright © 2015年 go. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate,
MCSessionDelegate {
    
    //Peerを検索する際に使用する文字列
    let serviceType = "LCOC-Chat"
    
    //!:暗黙的なオプショナル型、初期値がnilでも使用時までには必ず値が入っている
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    @IBOutlet var chatView: UITextView!
    @IBOutlet var messageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Peerを作成
        //引数に端末の名前
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        //セッションを初期化
        //セキュアな通信を行うこともできるっぽい
        self.session = MCSession(peer: peerID)
        //デリゲートを設定
        self.session.delegate = self
        
        //Session の検索中、ホスト側に表示させる画面
        self.browser = MCBrowserViewController(serviceType:serviceType,session:self.session)
        self.browser.delegate = self;
        
        //クライアントになる
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType,discoveryInfo:nil, session:self.session)
        self.assistant.start()
    }
    
    @IBAction func sendChat(sender: UIButton) {
        // Bundle up the text in the message field, and send it off to all
        // connected peers
        
        let msg = self.messageField.text!.dataUsingEncoding(NSUTF8StringEncoding,
            allowLossyConversion: false)
        
        if(msg != nil){
            do{
                //Peerにデータを送る
                //Unrelible:ソケットレベルのキューに入れることなく即時に送信する
                try self.session.sendData(msg!, toPeers: self.session.connectedPeers,withMode: MCSessionSendDataMode.Unreliable)
            }catch{
                print("Error sending data")
            }
        
            //送信側からの呼び出し
            self.updateChat(self.messageField.text!, fromPeer: self.peerID)
        
            self.messageField.text = ""
        }
    }
    
    func updateChat(text : String, fromPeer peerID: MCPeerID) {
        // Appends some text to the chat view
        // If this peer ID is the local device's peer ID, then show the name
        // as "Me"
        var name : String
        
        switch peerID {
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
        }
        
        if(text != ""){
            // Add the name to the message and display it
            let message = "\(name): \(text)\n"
            self.chatView.text = message + self.chatView.text
        }
    }
    
    //クライアントを探す
    @IBAction func showBrowser(sender: UIButton) {
        // Show the browser view controller
        self.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    //Done ボタン押下
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            //画面を閉じる
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Cancell ボタン押下
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is cancelled
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //以下送り合うデータによって使い分ける
    
    func session(session: MCSession, didReceiveData data: NSData,fromPeer peerID: MCPeerID)  {
            // Called when a peer sends an NSData to us
            
            // This needs to run on the main queue
            dispatch_async(dispatch_get_main_queue()) {
                
                let msg = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                self.updateChat(msg as! String, fromPeer: peerID)
            }
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(session: MCSession,didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, withProgress progress: NSProgress)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession,didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        atURL localURL: NSURL, withError error: NSError?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream,withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(session: MCSession, peer peerID: MCPeerID,didChangeState state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
            
    }
    
}