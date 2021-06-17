//
//  UserInfoManager.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/06/03.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit
import Alamofire

struct UserInfoKey {
    //저장에 사용할 키
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL" // 튜로리얼 최초 한번만 key
}

class UserInfoManager {
    // 연산 프로퍼티 loginId 정의
    var loginId: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    var account: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    var profile: UIImage? {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile) {
                return UIImage(data: _profile)
            } else {
                return UIImage(named: "account.jpg")
            }
        }
        
        set(v) {
            if v != nil {
                let ud = UserDefaults.standard
                ud.set(v!.pngData(), forKey: UserInfoKey.profile)
                ud.synchronize()
            }
        }
    }
    
    var isLogin: Bool {
        if self.loginId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }
    
//    func login(account: String, passwd: String, success: (()->Void)? = nil, fail: ((String)->Void)? = nil ) -> Bool {
        // TODO: 이 부분은 나중에 로그인 API 서버와 연동되는 코드로 대체될 예정입니다.
//        if account.isEqual("sqlpro@naver.com") && passwd.isEqual("1234") {
//            let ud = UserDefaults.standard
//            ud.set(100, forKey: UserInfoKey.loginId)
//            ud.set(account, forKey: UserInfoKey.account)
//            ud.set("재은 씨", forKey: UserInfoKey.name)
//            ud.synchronize()
//            return true
//        } else {
//            return false
//        }
//    }
    
    //로그인 API 서버 연동
    func login(account: String, passwd: String, success: (()->Void)? = nil, fail: ((String)->Void)? = nil ) {
        //함수 매개변수 success, fail 추가, 필요없을때에 사용하지 않을 수 있도록 기본값 nil, 또한 반환값 타입 제거
        //1. URL과 전송할 값 준비
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
            "account": account,
            "passwd": passwd
        ]
        
        //2. API 호출
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        //3. API 호출 결과 처리
        call.responseJSON(){
            res in
            //3-1. JSON 형식으로 응답했늕 확인
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("잘못된 응답 형식 입니다.\(result)")
                return
            }
            
            //3-2. 응답코드확인. 0이면 성공
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                //로그인 성공
                //3-3 로그인 성공 처리 로직
                let user = jsonObject["user_info"] as! NSDictionary
                
                self.loginId = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String
                
                //3-4. user_info 항목 중에서 프로필 이미지 처리
                if let path = user["profile_path"] as? String {
                    if let imageData = try? Data(contentsOf: URL(string: path)!) {
                        self.profile = UIImage(data: imageData)
                    }
                }
                
                //토큰 정보 추출
                let accessToken = jsonObject["access_token"] as! String // 액세스 토큰 추출
                let refreshToken = jsonObject["refresh_token"] as! String//리프레시 토큰 추출
                print("accessToken : \(accessToken)")
                
                //토큰 정보 저장
                let tk = TokenUtils()
                tk.save("com.rubypaper.Mymemory", account: "accessToken", value: accessToken)
                tk.save("com.rubypaper.Mymemory", account: "refreshToken", value: refreshToken)
                
                //3-5. 인자값으로 입력된 success 클로저 블록을 실행한다.
                success?()
            } else {
                //로그인 실패
                let msg = (jsonObject["error_msg"] as? String) ?? "로그인이 실패했습니다."
                fail?(msg)
            }
        }
    }
    
//    func logout() -> Bool {
//        let ud = UserDefaults.standard
//        //프로퍼티 리스트에 저장된 모든값을 일괄로 지우는 방법
//        //단 이때에는 상관없는 데이터까지 모조리 삭제됨
//        //let domain = Bundle.main.bundleIdentifier
//        //ud.removePersistentDomain(forName: domain!)
//
//        //단일로 지우는 방법
//        ud.removeObject(forKey: UserInfoKey.loginId)
//        ud.removeObject(forKey: UserInfoKey.account)
//        ud.removeObject(forKey: UserInfoKey.name)
//        ud.removeObject(forKey: UserInfoKey.profile)
//        ud.synchronize()
//        return true
//    }
    
    //로그아웃 API 서버 연동
    func logout(completion: (()->Void)? = nil){
        // 1. 호출 URL
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/logout"
        
        // 2. 인증 헤더 구현
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        
        // 3. API 호출 및 응답 처리
        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON() {
            res in
            // 3-1. 서버로부터 응답이 온 후 처리할 동작
            // 디바이스 로그아웃
            self.deviceLogout()
            
            // 전달 받은 완료 클로저를 실행
            completion?()
        }
    }
    
    func deviceLogout() {
        //기본 저장소에 저장된 값을 모두 삭제
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        
        // 키 체인에 저장된 값을 모두 삭제
        let tokenUtils = TokenUtils()
        tokenUtils.delete("com.rubypaper.Mymemory", account: "refreshToken")
        tokenUtils.delete("com.rubypaper.Mymemory", account: "accessToken")
    }
    
    //MARK:- 프로필 이미지 업데이트
    func newProfile(_ profile: UIImage?, success: (()->Void)? = nil, fail: ((String)->Void)? = nil ) {
        // API 호출 URL
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/profile"
        
        // 인증 헤더
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        //전송할 프로필 이미지
        let profileData = profile!.pngData()?.base64EncodedString()
        let param: Parameters = [ "profile_image": profileData! ]
    
        //이미지 전송
        let call = AF.request(url, method: HTTPMethod.post, parameters: param,encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON(){
            res in
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                fail?("올바른 응답값이 아닙니다.")
                return
            }
            
            //응답 코드 확인 0이면 성공
            let resultCode = jsonObject["result_code"] as! Int
            
            if resultCode == 0 {
                self.profile = profile // 이미지가 업로드되었다면 UserDefault에 저장된 이미지도 변경한다.
                success?()
            } else {
                let msg = (jsonObject["error_msg"] as? String) ?? "이미지 프로필 변경이 실패 하였습니다."
                fail?(msg)
            }
        }
    }
}
