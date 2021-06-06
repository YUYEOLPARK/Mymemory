//
//  SideBarVC.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/05/31.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit

class SideBarVC: UITableViewController {
    
    let uinfo = UserInfoManager()//개인정보 관리 매니저
    //목록 데이터 배열
    let titles = [
        "새글 작성하기",
        "친구 새글",
        "달력으로 보기",
        "공지사항",
        "통계",
        "계정 관리",
    ]
    
    //아이콘 데이터 배열
    let icons = [
        UIImage(named: "icon01.png"),
        UIImage(named: "icon02.png"),
        UIImage(named: "icon03.png"),
        UIImage(named: "icon04.png"),
        UIImage(named: "icon05.png"),
        UIImage(named: "icon06.png"),
    ]
    
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let profileImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //테이블 뷰의 헤더 역할을 할 뷰를 정의한다.
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        headerView.backgroundColor = .brown
        
        // 테이블 뷰의 헤더 뷰로 지정.
        self.tableView.tableHeaderView = headerView
        
        //이름 레이블의 속성을 정의하고, 헤더 뷰에 추가한다.
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        self.nameLabel.textColor = UIColor.white
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.nameLabel.backgroundColor = .clear
        
        headerView.addSubview(self.nameLabel)
        
        //이메일 레이블의 속성을 정의하고, 헤더 뷰에 추가한다.
        self.emailLabel.frame = CGRect(x: 70, y: 30, width: 100, height: 30)
        self.emailLabel.textColor = .white
        self.emailLabel.font = UIFont.systemFont(ofSize: 11)
        self.emailLabel.backgroundColor = .clear
        
        headerView.addSubview(self.emailLabel)
        
        //프로파일 이미지.
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        //이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.width / 2) //반원형태로 라운딩
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true //마스크 효과
        headerView.addSubview(self.profileImage)
    }
    
    //사이드바가 표시될 때마다 로그인 정보를 읽어와 갱신하도록 willappear메소드에 작성.
    override func viewWillAppear(_ animated: Bool) {
        self.nameLabel.text = self.uinfo.name ?? "Guest"
        self.emailLabel.text = self.uinfo.account ?? ""
        self.profileImage.image = self.uinfo.profile
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //재사용 큐에서 테이블 셀을 꺼내 온다. 없으면 새로 생성한다.
        let id = "menucell" //테이블 뷰 식별자
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        //타이틀과 이미지를 대입한다.
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //선택된 행이 새글 작성 메뉴일 때
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "MemoForm")
            let target = self.revealViewController().frontViewController as! UINavigationController
            target.pushViewController(uv!, animated: true)
            //사이드바 메뉴 닫아준다.
            self.revealViewController().revealToggle(self)
        } else if indexPath.row ==  5 {
            //계정 관리
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_Profile")
            uv?.modalPresentationStyle = .fullScreen
            self.present(uv!, animated: true){
                self.revealViewController().revealToggle(self)
            }
        }
    }
}
