//
//  ProfileVC.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/05/31.
//  Copyright © 2021 rubypaper. All rights reserved.
//
import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    let profileImage = UIImageView()// 프로필 사진 이미지
    let tv = UITableView()// 프로필 목록
    let uinfo = UserInfoManager() //개인정보 관리 매니저
    
    var isCalling = false // api호출 중복방지 변수
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "프로필"
        self.navigationController?.navigationBar.isHidden = true
        //뒤로 가기 버튼 처리
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //배경 이미지 설정
        let bg = UIImage(named: "profile-bg")
        let bgImg = UIImageView(image: bg)
        bgImg.frame.size = CGSize(width: bgImg.frame.size.width, height: bgImg.frame.size.height )
        bgImg.center = CGPoint(x: self.view.frame.width / 2, y: 40)
        bgImg.layer.cornerRadius = bgImg.frame.size.width / 2
        bgImg.layer.borderWidth = 0
        bgImg.layer.masksToBounds = true
        self.view.addSubview(bgImg)
        
        //개인 프로필 영역 구현
        //1. 프로필 사진에 들어갈 기본 이미지
        let image = self.uinfo.profile
        //2. 프로필 이미지 처리
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 270)
        //3. 프로필 이미지 둥글게 처리
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        //4. 루트 뷰에 추가
        self.view.addSubview(self.profileImage)
        
        //테이블뷰( 개인정보 뷰 ).  y = 프로필이미지의 y좌표위치 + 높이 + 여백20
        self.tv.frame = CGRect(x: 0, y: self.profileImage.frame.origin.y + self.profileImage.frame.height + 20 , width: self.view.frame.width, height: 100)
        self.tv.dataSource = self //데이터 소스와
        self.tv.delegate = self //테이블뷰의 위임 받을 객체를 지정
        self.view.addSubview(self.tv)
        
        //최초 화면 로딩 시 로그인 상태에 따라 로그인/로그아웃 버튼 출력
        self.drawBtn()
        
        //프로필 뷰에 탭 제스처 등록
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true//유저와 상호 작용 허용
        
        //인디케이터 뷰를 화면 맨 앞으로
        self.view.bringSubviewToFront(self.indicatorView)
        
        //키 체인 저장 여부 확인을 위한 임시 코드
        let tk = TokenUtils()
        if let accessToken = tk.load("com.rubypaper.Mymemory", account: "accessToken") {
            print("accessToken = \(accessToken)")
        } else {
            print("accessToken is nil ")
        }
        
        if let refreshToken = tk.load("com.rubypaper.Mymemory", account: "refreshToken") {
            print("refreshToken = \(refreshToken)")
        } else {
            print("refreshToken is nil ")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //토큰 인증 여부 체크
        self.tokenValidate()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0 :
            cell.textLabel?.text = "이름"
            //cell.detailTextLabel?.text = "꼼꼼한재은 씨"
            cell.detailTextLabel?.text = self.uinfo.name ?? "Login please"
        case 1 :
            cell.textLabel?.text = "계정"
            //cell.detailTextLabel?.text = "sqlpro@naver.com"
            cell.detailTextLabel?.text = self.uinfo.account ?? "Login please"
        default :
            ()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uinfo.isLogin == false {
            //로그인 안되어있으면 로그인 창 띄어라
            self.doLogin(self.tv)
        }
    }
    
    func drawBtn() {
        //버튼을 감쌀 뷰를 정의한다.
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        self.view.addSubview(v)
        
        // 버튼을 정의한다.
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        
        //로그인 상태일 때는 로그아웃 버튼을, 로그아웃 상태일 때에는 로그인 버튼을 만들어준다.
        if self.uinfo.isLogin == true {
            btn.setTitle("로그아웃", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("로그인", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        
        v.addSubview(btn)
    }
    
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func doLogin(_ sender: Any) {
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        if self.isCalling == true {
            self.alert("응답을 기다리는 중입니다. \n 잠시만 기다려 주세요.")
            return
        } else {
            self.isCalling = true
        }
        
        //알림창에 들어갈 입력폼 추가.
        loginAlert.addTextField(){
            $0.placeholder = "Your Account"
        }
        
        loginAlert.addTextField(){
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
        }
        
        //알림창 버튼 추가.
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel){
            (_) in
            self.isCalling = false
        })
        
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive){ (_) in
            
            //인디케이터 실행
            self.indicatorView.startAnimating()
            
            let account = loginAlert.textFields?[0].text ?? "" //첫번쨰 필드 계정
            let passwd = loginAlert.textFields?[1].text ?? "" // password
            
            // 로그인 API 서버 호출 방식 (비동기 방식)
            self.uinfo.login(account: account, passwd: passwd, success: {
                //인디케이터 종료
                self.indicatorView.stopAnimating()
                self.isCalling = false
                
                self.tv.reloadData() // 테이블 뷰 개신
                self.profileImage.image = self.uinfo.profile // 이미지 프로필을 갱신
                self.drawBtn() //로그인 상태에 따라 로그인/로그아웃 버튼 출력
            }, fail: {
                msg in
                //인디케이터 종료
                self.indicatorView.stopAnimating()
                self.isCalling = false
                
                self.alert(msg)
            })
        })
        
        self.present(loginAlert, animated: false, completion: nil)
    }
    
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive){
            (_) in
            //인디케이터 실행
            self.indicatorView.startAnimating()
            
            self.uinfo.logout() {
                //TODO: 로그아웃 시 처리될 내용
                self.indicatorView.stopAnimating() //인디케이터 스탑
            
                self.tv.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn() //로그인 상태에 따라 로그인/로그아웃 버튼 출력
            }
        })
        
        self.present(alert, animated: false, completion: nil)
    }
    
    //이미지 피커 호출
    //매개변수 인자값이 이미지 피커 컨트롤러의 이미지 소스 타입이다. 라이브러리, 카메라 등
    func imgPicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    // 프로파일 이미지 뷰 선택시 연결될 액션 메소드
    @objc func profile(_ sender: UIButton) {
        //로그인 되어있지 않을 경우 - 로그인 창 띄움
        guard self.uinfo.isLogin != false else {
            self.doLogin(self)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요", preferredStyle: .actionSheet)
        
        //카메라를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default){
                (_) in
                self.imgPicker(.camera)
            })
        }
        
        //저장된 앨범을 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default){
                (_) in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        
        //포토 라이브러리를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default){
                (_) in
                self.imgPicker(.photoLibrary)
            })
        }
        
        //취소 버튼 추가
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // 이미지피커에서 이미지 선택하면 자동으로 호출되는 델리게이트 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //인디케이터 실행
        self.indicatorView.startAnimating()
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uinfo.newProfile(img , success: {
                //인디케이터 종료
                self.indicatorView.stopAnimating()
                self.profileImage.image = img
            }, fail: {
                msg in
                //인디케이터 종료
                self.indicatorView.stopAnimating()
                self.alert(msg)
            })
        }
        
        //피커 닫기
        picker.dismiss(animated: true, completion: nil)
    }
    
    //unwind
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue) {
        //단지 프로필 화면으로 되돌아오기 위한 표식
    }
}

//MARK:- 토큰 갱신 관련 메소드
extension ProfileVC {
    //인증 토큰 인증(유효성) 메소드
    func tokenValidate() {
        //0. 응답 캐시를 사용하지 않도록
        //IOS는 HTTP 호출의 성능을 높일 목적으로 응답 캐시를 사용합니다. 저장된 값을 반환하므로
        //캐시를 사용하지 않도록 캐시 삭제합니다.
        URLCache.shared.removeAllCachedResponses()
        
        //1. 키 체인에 액세스 토큰이 없을 경우 유효성 검증을 진행하지 않음.
        //nil이면 로그아웃되었거나 로그인한 적이 없는 것을 의미.
        let tk = TokenUtils()
        guard let header = tk.getAuthorizationHeader() else {
            return
        }
        
        //인디케이터 시작
        self.indicatorView.startAnimating()
        
        //2. tokenValidate API를 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method:.post, encoding: JSONEncoding.default, headers: header)
        
        validate.responseJSON(){
            res in
            
            self.indicatorView.stopAnimating()
            let responseBody = try! res.result.get()
            print(responseBody) // 2-1. 응답 결과를 확인하기 위해 메시지 본문 전체를 출력
            
            guard let jsonObject = responseBody as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            //3. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode != 0 {
                //3-1. 응답결과가 실패 일때 (즉, 토큰이 만료 일때 )
                //로컬 인증 실행
                self.touchID()
            }
        } // end of response closure
        
    }//end of func tokenValidate()
    
    //터치 아이디 인증 메소드
    func touchID() {
        //1. LAContext 인스턴스 생성
        let context = LAContext()
        
        //2. 로컬 인증에 사용할 변수 정의
        var error:NSError?
        let msg = "인증이 필요합니다."
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics //인증 정책
        
        //3. 로컬 인증이 사용 가능한지 여부 판단
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            //4. 터치 아이디 인증창 실행
            context.evaluatePolicy(deviceAuth, localizedReason: msg, reply: {
                (success, e) in
                if success {
                    //5. 인증 성공 : 토큰 갱신 로직
                    //5-1. 토큰 갱신 로직 실행
                    self.refresh()
                } else {
                    //6. 인증 실패
                    //인증 실패 원인에 대한 대응 로직
                    print( (e?.localizedDescription)! )
                    
                    switch (e!._code) {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의해 인증이 취소 되었습니다.")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소 되었습니다.") {
                            self.commonLogout(true)
                        }
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    }
                }
            })
        } else {
            //7. 인증창이 실행되지 못한 경우
            //인증창 실행 불가 원인에 대한 대응 로직
            print(error!.localizedDescription)
            switch (error!.code) {
            case LAError.biometryNotEnrolled.rawValue:
                print("터치 아이디가 등록되어 있지 않습니다.")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드가 설정되어 있지 않습니다.")
            default://LAError.touchIDNotAvailablew 포함
                print("터치 아이디를 사용할 수 없습니다.")
                OperationQueue.main.addOperation {
                    self.commonLogout(true)
                }
            }
        }
    }
    
    //토큰 갱신 메소드
    func refresh() {
        DispatchQueue.main.async {
            self.indicatorView.startAnimating() //인디케이터 시작
        }
        //1. 인증 헤더
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        //2. 리프레쉬 토큰 전달 준비
        let refreshToken = tk.load("com.rubypaper.Mymemory", account: "refreshToken")
        
        let param:Parameters = ["refresh_token": refreshToken! ]
        
        //3. 호출 및 응답.
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        refresh.responseJSON(){ res in

            self.indicatorView.stopAnimating() //인디케이터 중지
            
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            //4. 응답 처리 결과
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {//성공 : 액세스 토큰이 갱신 되었다는 의미
                //4-1. 키 체인에 저장된 액세스 토큰 교체
                let accessToken = jsonObject["access_token"] as! String
                tk.save("com.rubypaper.Mymemory", account: "accessToken", value: accessToken)
            } else { //실패 : 리프레쉬 토큰도 폐기됨.
                self.alert("인증이 만료되었으므로 다시 로그인해야 합니다.") {
                    //4-2. 로그아웃 처리
                    OperationQueue.main.addOperation {
                        self.commonLogout(true)
                    }
                }
            }
        }
    }
    
    func commonLogout(_ isLogin: Bool = false ) {
        //1. 저장된 기존 개인정보 & 키 체인 데이터를 삭제하여 로그아웃 상태로 전환
        let userInfo = UserInfoManager()
        userInfo.deviceLogout()
        
        //2. 현재의 화면이 프로필 화면이라면 바로 UI를 갱신한다.
        self.tv.reloadData() // 테이블 뷰 갱신
        self.profileImage.image = userInfo.profile // 이미지프로필을 갱신한다.
        self.drawBtn()
        
        //3. 기본 로그인 창 실행 여부
        if isLogin {
            self.doLogin(self)
        }
    }
}
