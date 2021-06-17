//
//  JoinVC.swift
//  Mymemory
//
//  Created by dongadevp1 on 2021/06/16.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit
import Alamofire

class JoinVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate{
   
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // 테이블뷰에 들어갈 텍스트 필드들
    var fieldAccount: UITextField! {
        didSet {
            fieldAccount.delegate = self
        }
    }
    var fieldPassword: UITextField! {
        didSet {
            fieldPassword.delegate = self
        }
    }
    var fieldName: UITextField! {
        didSet {
            fieldName.delegate = self
        }
    }
    
    //API 호출 중복 방지 변수
    var isCalling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //테이블 뷰의 dataSource, delegate 속성 지정
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //프로필 이미지를 원형으로 설정
        self.profile.layer.cornerRadius = self.profile.frame.width / 2
        self.profile.layer.masksToBounds = true
        
        //프로필 이미지에 탭 제스처 및 액션 이벤트 설정
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfile(_:)))
        self.profile.addGestureRecognizer(gesture)
        
        //인디케이터뷰를 화면 맨 앞으로
        self.view.bringSubviewToFront(self.indicatorView)
    }
    
    @objc func tappedProfile(_ sender: Any) {
        // 전반부) 원하는 소스 타입을 선택할 수 있는 액션 시트 구현
        let msg = "프로필 이미지를 읽어올 곳을 선택하세요."
        let sheet = UIAlertController(title: msg, message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        sheet.addAction(UIAlertAction(title: "저장된 앨범", style: .default){(_) in
            selectLibrary(src: .savedPhotosAlbum)
        })
        
        sheet.addAction(UIAlertAction(title: "포토 라이브러리", style: .default){(_) in
            selectLibrary(src: .photoLibrary)
            
        })
        
        sheet.addAction(UIAlertAction(title: "카메라", style: .default){(_) in
            selectLibrary(src: .camera)
            
        })
        
        self.present(sheet, animated: false)
        
        // 후반부) 전달된 소스 타입에 맞게 이미지 피커 창을 여는 내부 함수
        func selectLibrary(src: UIImagePickerController.SourceType) {
            if UIImagePickerController.isSourceTypeAvailable(src) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                
                self.present(picker, animated: false)
            } else {
                self.alert("사용할 수 없는 타입니다.")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    //이미지피커에서 이미지 선택 했을때 실행될 델리게이트 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let rawVal = UIImagePickerController.InfoKey.editedImage.rawValue
        if let img = info[UIImagePickerController.InfoKey(rawValue: rawVal)] as? UIImage {
            self.profile.image = img
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func submit(_ sender: Any) {
        //API 중복 호출 방지
        if self.isCalling == true {
            self.alert("진행 중입니다. 잠시만 기다려주세요.")
            return
        } else {
            self.isCalling = true
        }
        
        //인디케이터 뷰 애니메이션 시작
        self.indicatorView.startAnimating()
        
        //1. 전달할 값 준비
        //1-1. 이미지를 Base64 인코딩 처리
        let profile = self.profile.image!.pngData()?.base64EncodedString()
        //1-2. 전달값을 Parameters 타입의 객체로 정의
        let param: Parameters = [
            "account" : self.fieldAccount.text! ,
            "passwd" : self.fieldPassword.text! ,
            "name" : self.fieldName.text!,
            "profile_image" : profile!
        ]
        
        //2.API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/join"
        let call = AF.request(url, method: HTTPMethod.post, parameters: param, encoding: JSONEncoding.default)
        
        //3. 서버 응답값 처리
        call.responseJSON(){
            response in
            
            //인디케이터 뷰 애니메이션 종료
            self.indicatorView.stopAnimating()
            
            //3.-1 JSON 형식으로 값이 제대로 전달되었는지 확인
            guard let jsonObject = try! response.result.get() as? [String: Any] else {
                self.alert("서버 호출 과정에서 오류가 발생했습니다.")
                return
            }
            
            //3-2. 응답 코드 확인. 0이면 성공
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                self.alert("가입이 완료 되었습니다.") {
                    self.performSegue(withIdentifier: "backProfileVC", sender: self)
                }
            } else {
                //0이 아닐때 실패
                let errorMsg = jsonObject["error_msg"] as! String
                self.alert("오류발생 : \(errorMsg)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        //각 테이블 뷰 셀 모두에 공통으로 적용될 프레임 객체
        let tfFrame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 37)
        
        switch indexPath.row{
        case 0:
            self.fieldAccount = UITextField(frame: tfFrame)
            self.fieldAccount.placeholder = "계정(이메일)"
            self.fieldAccount.borderStyle = .none
            self.fieldAccount.autocapitalizationType = .none
            self.fieldAccount.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldAccount)
        case 1:
            self.fieldPassword = UITextField(frame: tfFrame)
            self.fieldPassword.placeholder = "비밀번호"
            self.fieldPassword.borderStyle = .none
            self.fieldPassword.isSecureTextEntry = true
            self.fieldPassword.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldPassword)
        case 2:
            self.fieldName = UITextField(frame: tfFrame)
            self.fieldName.placeholder = "이름"
            self.fieldName.borderStyle = .none
            self.fieldName.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldName)
        default:
            ()
        }
        
        return cell
    }
    
    //테이블 셀이 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}