//
//  Utils.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/06/04.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name:"Tutorial", bundle: Bundle.main)
    }
    
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
    
    //MARK:- alert코드 간소화 함수
    func alert(_ message: String, completion: (()->Void)? = nil ) {
        // 메인 스레드에서 실행되도록
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .cancel){
                (_) in
                completion?() // nil이 아닐때만 실행하도록
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
}

import Security
import Alamofire

class TokenUtils {
    //키 체인에 값을 저장하는 메소드
    func save(_ service: String, account: String, value: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account,
            kSecValueData : value.data(using: .utf8, allowLossyConversion: false)!
        ]
        
        //현재 저장되어있는 값 삭제
        SecItemDelete(keyChainQuery)
        
        //새로운 키 체인 아이템 등록
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "토큰 값 저장에 시래했습니다.")
        NSLog("status == \(status)")
    }
    
    //키 체인에 저장된 값을 읽어오는 메소드
    func load(_ service: String, account: String) -> String? {
        // 1. 키 체인 쿼리 정의
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account,
            kSecReturnData : kCFBooleanTrue! , //CFDataRef
            kSecMatchLimit : kSecMatchLimitOne
        ]
        
        // 2. 키 체인에 저장된 값을 읽어온다.
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        
        // 3. 처리 결과가 성공이라면 읽어온 값을 Data 타입으로 변환하고, 다시 String 타입으로 변환한다.
        if ( status == errSecSuccess ) {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: String.Encoding.utf8 )
            return value
        } else {
            //4. 처리 결과가 실패라면 nil을 반환한다.
            print("Nothing was retrieved from the keychain. status code \(status)")
            return nil
        }
        
    }
    
    //키 체인에 저장된 값을 삭제하는 메소드
    func delete(_ service: String, account: String ) {
        let keyChainQuery : NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account
        ]
        
        //현재 저장되어 있는 값 삭제
        let status = SecItemDelete(keyChainQuery)
        assert(status == noErr, "토큰 값 삭제에 실패 했습니다.")
        NSLog("status=\(status)")
    }
    
    //키 체인에 저장된 엑세스 토큰을 이용하여 헤더를 만들어 주는 메소드
    func getAuthorizationHeader() -> HTTPHeaders? {
        let serviceID = "com.rubypaper.Mymemory"
        if let accessToken = self.load(serviceID, account: "accessToken" ) {
            return [ "Authorization" : "Bearer \(accessToken)"] as HTTPHeaders
        } else {
            return nil
        }
    }
}
