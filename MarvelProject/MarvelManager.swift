//
//  MarvelManager.swift
//  MarvelProject
//
//  Created by tomer on 16/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit
import CryptoSwift
import Alamofire

class MarvelManager: NSObject {
    
    static let manager = MarvelManager()
    
    private let baseURL = "https://gateway.marvel.com/v1/public/"
    private let privateKey = "b8fcab014172804adbe7c54f98068c0ec20eb6a5"
    private let publicKey = "aafca0489da97492acc924be7026a3f3"
    
    private func defaultParams() -> JSON{
        let timeStamp = Int(Date().timeIntervalSince1970)
        let hashString = "\(timeStamp)" + privateKey + publicKey
    
        let md5String = hashString.md5()
        
        return [
            "hash":md5String,
            "apikey":publicKey,
            "ts":timeStamp
        ]
    }
    
    typealias JSON = [String:Any]
    typealias DictionaryResultCompletion = ([JSON]?, Error?) -> Void
    
    private func sendGetRequest(startPoint : String, params : JSON, completion : @escaping DictionaryResultCompletion){
        var url : String = ""
        
        if startPoint.contains("http"){
            url = startPoint
        }else{
            url = baseURL + startPoint
        }
        
        Alamofire.request(url, method: .get, parameters: params).responseJSON { (dataRes) in
            guard let json = dataRes.result.value as? JSON else{
                //toast
                dataRes.error?.localizedDescription.toast()
                completion(nil, dataRes.error)
                return
            }
            guard let code = json["code"] as? Int else{
                "Unknown error".toast()
                print("code error - no code")
                return
            }
            
            guard code >= 200 && code <= 299 else{
                print("code number: \(code) error")
                let status = json["status"] as? String ?? ""
                //toast
                status.toast()
                let err = NSError(domain: "marvel", code: code, userInfo: [
                    NSLocalizedDescriptionKey:status
                    ])
                completion(nil, err as Error)
                return
            }
            
            let data = json["data"] as? JSON ?? [:]
            
            let jsonArr = data["results"] as? [JSON] ?? []
            
            completion(jsonArr, nil)
        }
    }
    
    func getItems(isMarvel : Bool,
                  startPoint : String,
                  type : Item.Type,
                  defaultParameter : String ,
                  charName : String,
                  recsPerPage : UInt,
                  page : UInt,
                  orderBy: String,
                  completion : @escaping ([Item]? , Error?)->Void)
    {
        var params = defaultParams()
        if !orderBy.isEmpty{
            params["orderBy"] = orderBy
        }
        params[defaultParameter] = charName
        params["limit"] = recsPerPage
        params["offset"] = recsPerPage * page
        
        sendGetRequest(startPoint: startPoint, params: params) { (jsonArr, err) in
            let arr = jsonArr?.flatMap{type.init($0, isMarvel: isMarvel)}
            completion(arr,err)
        }
    }
    
    func getDetailsFor(isMarvel : Bool,
                       charID : String,
                       startPoint : String,
                       type : Item.Type,
                       endPoint : String,
                       recsPerPage : UInt,
                       page : UInt,
                       orderBy : String,
                       completion : @escaping ([Item]?, Error?, Item.Type) -> Void){
        let finalEndPoint : String
        if charID.isEmpty{
            finalEndPoint = startPoint
        }else{
            finalEndPoint = startPoint + "/" + charID + endPoint
        }
        var params = self.defaultParams()
        if !orderBy.isEmpty{
            params["orderBy"] = orderBy
        }
        params["limit"] = recsPerPage
        params["offset"] = recsPerPage * page
        sendGetRequest(startPoint: finalEndPoint, params: params) { (jsonArr, err) in
            
            let arr = jsonArr?.flatMap { type.init($0, isMarvel: isMarvel)}
            completion(arr,err,type)
        }
    }
    
    func getUrlsFor(charID : String,
                    startPoint : String,
                    recsPerPage : UInt,
                    page : UInt,
                    completion : @escaping ([URL], Error?) -> Void){
        
        let finalEndPoint = startPoint + "/" + charID
        var params = self.defaultParams()
        params["limit"] = recsPerPage
        params["offset"] = recsPerPage * page
        sendGetRequest(startPoint: finalEndPoint, params: params) { (jsonArr, err) in
            
            let dictArray = jsonArr?.first?["urls"] as? [JSON]
            
            let arr = dictArray?.flatMap({ (dict : JSON) -> URL? in
                if let type = dict["type"] as? String, type == "purchase", let urlString = dict["url"] as? String{
                    return URL(string: urlString)
                } else {
                    return nil
                }
            })
            completion(arr ?? [],err)
        }
    }
}
