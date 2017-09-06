//
//  ViewController.swift
//  BikeMapMVCDemo
//
//  Created by LoyaltyWu on 17/8/11.
//  Copyright © 2017年 LoyaltyWu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func btnTapped(_ sender: Any) {
        tapped()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.vc = self
        // Do any additional setup after loading the view, typically from a nib.
//        let button:UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
//        button.addTarget(self, action: #selector(self.tapped), for: UIControlEvents.touchUpInside)
    }

    func tapped(){
        let new:WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        new.redirectURI = kRedirectURI
        new.scope = "all"
        new.userInfo = [
            "SSO_From" : "SendMessageToWeiboViewController",
            "Other_Info_1" :
            123,
            "Other_Info_2" :
            ["objc1","objc2"],
            "Other_Info_3" :
            ["key1":"objc1","key2":"objc2"]
        ]
        WeiboSDK.send(new)
    }
    
    @IBAction func getIconTapped(_ sender: Any) {
        
    }
    
    @IBAction func getUIDTapped(_ sender: Any) {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if (appDelegate.wbToken != nil && appDelegate.wbCurrentUserID != nil){
            asyncGetUserInfo(acToken: appDelegate.wbToken, uid: appDelegate.wbCurrentUserID)
            asyncGetFollowers(acToken: appDelegate.wbToken, uid: appDelegate.wbCurrentUserID)
            asyncGetFriends(acToken: appDelegate.wbToken, uid: appDelegate.wbCurrentUserID)
        }
        else{
            print("you haven't log in maybe")
        }
    }
    
    @IBAction func getNameTapped(_ sender: Any) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func asyncGetFriends(acToken:String,uid:String){
        // https://api.weibo.com/2/friendships/friends.json
        let urlStr:String = "https://api.weibo.com/2/friendships/friends.json?access_token=\(acToken)&uid=\(uid)"
        asynchronousGet(urlStr: urlStr)
    }
    func asyncGetFollowers(acToken:String,uid:String){
        let urlStr:String = "https://api.weibo.com/2/friendships/followers.json?access_token=\(acToken)&uid=\(uid)"
        asynchronousGet(urlStr: urlStr)
    }
    
    func asyncGetUserInfo(acToken:String,uid:String){
        let urlStr:String = "https://api.weibo.com/users/show.json?access_token=\(acToken)&uid=\(uid)"
        asynchronousGet(urlStr: urlStr)
    }
    
    //MARK: - 异步Get方式
    func asynchronousGet(urlStr:String){
        
        // 1、创建URL对象；
        let url:URL! = URL(string:urlStr);
        
        // 2、创建Request对象
        // url: 请求路径
        // cachePolicy: 缓存协议
        // timeoutInterval: 网络请求超时时间(单位：秒)
        let urlRequest:URLRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        // 3、连接服务器
        let connection:NSURLConnection? = NSURLConnection(request: urlRequest, delegate: self)
        connection?.schedule(in: .current, forMode: .defaultRunLoopMode)
        connection?.start()
    }
    
    //MARK: - 异步Post方式
    func asynchronousPost(){
        
        // 1、创建URL对象；
        let url:URL! = URL(string:"http://api.3g.ifeng.com/clientShortNews");
        
        // 2、创建Request对象
        // url: 请求路径
        // cachePolicy: 缓存协议
        // timeoutInterval: 网络请求超时时间(单位：秒)
        var urlRequest:URLRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        // 3、设置请求方式为POST，默认是GET
        urlRequest.httpMethod = "POST"
        
        // 4、设置参数
        let str:String = "type=beauty"
        let data:Data = str.data(using: .utf8, allowLossyConversion: true)!
        urlRequest.httpBody = data;
        
        // 3、连接服务器
        let connection:NSURLConnection? = NSURLConnection(request: urlRequest, delegate: self)
        connection?.schedule(in: .current, forMode: .defaultRunLoopMode)
        connection?.start()
    }
    var receivedData:Data!
    var dealingURL:URL!
}
extension ViewController: NSURLConnectionDataDelegate{
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        dealingURL = response.url
        print("now we are dealing with \(dealingURL.absoluteString)")
        //接收响应
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        receivedData = data
        //收到数据
        // self.jsonData.append(data);
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        let str = String(data: receivedData, encoding: String.Encoding.utf8)
        print(str!)
        do {
            let dic = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,Any>
            if let imageURL = dic["profile_image_url"]{
                print(dic["profile_image_url"]as!String)
                print(dic["screen_name"]as!String)
            }
            else if let usersss = dic["users"]{
                let arr:Array<Dictionary<String,Any>> = usersss as! Array<Dictionary<String,Any>>
                for item in arr{
                    // print("friendID\(item["id"])")
                    print("id\(item["idstr"])")
                    print("name\(item["name"])")
                    print("profile_image_url\(item["profile_image_url"])")
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        //请求结束
        //let jsonStr = String(data: self.jsonData as Data, encoding:String.Encoding.utf8);
        //print(jsonStr)
//        do {
//            let dic = try JSONSerialization.jsonObject(with: self.jsonData as Data, options: JSONSerialization.ReadingOptions.allowFragments)
//            print(dic)
//        } catch let error{
//            print(error.localizedDescription);
//        }
        
    }
}

