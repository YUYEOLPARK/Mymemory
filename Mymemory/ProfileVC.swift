//
//  ProfileVC.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/05/31.
//  Copyright © 2021 rubypaper. All rights reserved.
//
import UIKit
class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let profileImage = UIImageView()// 프로필 사진 이미지
    let tv = UITableView()// 프로필 목록
    let uinfo = UserInfoManager() //개인정보 관리 매니저
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
        
        //알림창에 들어갈 입력폼 추가.
        loginAlert.addTextField(){
            $0.placeholder = "Your Account"
        }
        
        loginAlert.addTextField(){
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
        }
        
        //알림창 버튼 추가.
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive){ (_) in
            let account = loginAlert.textFields?[0].text ?? "" //첫번쨰 필드 계정
            let passwd = loginAlert.textFields?[1].text ?? "" // password
            
            if self.uinfo.login(account: account, passwd: passwd) {
                //TODO: (로그인 성공시 처리할 내용)
                self.tv.reloadData() // 유저정보 테이블 뷰 갱신
                self.profileImage.image = self.uinfo.profile // 이미지 프로필을 갱신한다.
                
                self.drawBtn() //로그인 상태에 따라 로그인/로그아웃 버튼 출력
            } else {
                let msg = "로그인에 실패했습니다."
                let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self.present(alert, animated: false, completion: nil)
            }
        })
        
        self.present(loginAlert, animated: false, completion: nil)
    }
    
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive){
            (_) in
            if self.uinfo.logout() {
                //TODO: 로그아웃 시 처리될 내용
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
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uinfo.profile = img//프로퍼티 리스트 유저정보 프로파일 변경
            self.profileImage.image = img //현재 눈에 보이는 프로파일 뷰 변경
        }
        
        //피커 닫기
        picker.dismiss(animated: true, completion: nil)
    }
}
