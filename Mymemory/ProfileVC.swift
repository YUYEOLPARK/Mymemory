//
//  ProfileVC.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/05/31.
//  Copyright © 2021 rubypaper. All rights reserved.
//
import UIKit
class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let profileImage = UIImageView()// 프로필 사진 이미지
    let tv = UITableView()// 프로필 목록
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
        let image = UIImage(named: "account.jpg")
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
            cell.detailTextLabel?.text = "꼼꼼한재은 씨"
        case 1 :
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = "sqlpro@naver.com"
        default :
            ()
        }
        
        return cell
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
