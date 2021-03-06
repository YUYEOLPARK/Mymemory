//
//  MemoListVC.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/05/02.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit

class MemoListVC: UITableViewController, UISearchBarDelegate {
    //앱 델리게이트 객체의 참조 정보를 읽어온다.
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var dao = MemoDAO()
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // SWRevealViewController 라이브러리의 revealViewController 객체를 읽어온다.
        if let revealVC = self.revealViewController() {
    
            //바 버튼 아이템 객체를 정의한다.
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "sidemenu.png")
            btn.target = revealVC // 버튼 클릭시 이벤트 함수가 정의된 객체를 지정
            btn.action = #selector(revealVC.revealToggle(_:))
            
            //정의된 바 버튼을 내비게이션 바의 왼쪽 아이템으로 등록한다.
            self.navigationItem.leftBarButtonItem = btn
            
            //제스처 객체를 뷰에 추가한다.
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        //검색 바의 키보드에서 리턴 키가 항상 활성화 되어 있도록 처리
        searchBar.enablesReturnKeyAutomatically = false
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //튜토리얼의 최초 확인(프로퍼티 리스트)하여 튜토리얼을 노출한다.
        //viewDidLoad는 뷰가 메모리만 로드된 상태이기 때문에 뷰 전환을 할 수 없다.
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial ) == false {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: false, completion: nil)
            return
        }
        
        //코어데이터의 데이터를 memolist로 저장한다.
        self.appDelegate.memolist = self.dao.fetch()
        
        //테이블 데이터를 다시 읽어들인다. 이에 따라 행을 구성하는 로직이 실행된다.
        self.tableView.reloadData()
    }

    // 테이블 뷰의 셀 개수를 결정 하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.appDelegate.memolist.count
        return count
    }
    
    // 테이블 셀 설정 메소드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //1. memolist 배열 데이터에서 주어진 행에 맞는 데이터를 꺼낸다.
        let row = self.appDelegate.memolist[indexPath.row]
        
        //2. 이미지 속성이 비어 있을 경우 "memoCell", 아니면 "memoCellWithImage"
        let cellId = row.image == nil ? "memoCell" : "memoCellWithImage"
        
        //3. 재사용 큐로부터 프로토타입 셀의 인스턴스를 생성한다.
        //옵셔널 처리를 통해 캐스팅 미스시 앱이 다운되는 현상 예방하기
        let cell = (tableView.dequeueReusableCell(withIdentifier: cellId) as? MemoCell) ?? MemoCell()
        
        //4.memoCell의 내용을 구성한다.
        cell.subject?.text = row.title
        cell.contents?.text = row.contents
        cell.img?.image = row.image
        
        //5. date 타입의 날짜를 yyyy-mm-dd HH:mm:ss 포맷에 맞게 변경한다.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.regdate?.text = formatter.string(from: row.regdate!)
        
        //6. cell 객체를 리턴한다.
        
        return cell
    }
    
    // MARK: - 셀선택시 값 전달 화면전환
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1. memolist 배열에서 선택된 행에 맞는 데이터를 꺼낸다.
        let row = self.appDelegate.memolist[indexPath.row]

        //2. 상세 화면의 인스턴스를 생성한다.
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MemoRead") as? MemoReadVC else{
            return
        }

        //3. 값을 전달한 다음 상세화면으로 이동한다.
        vc.param = row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 셀선택시 세그웨이를 통한 값 전달.
    //1. 각각의 Cell과 상세화면을 Segue로 연결하고 각 세그웨이 Identifier를 설정한다.
    //2. prepare을 사용하여 값을 전달해 줄것이다.
    //   해당 identifier를 체크하고
    //   MemoReadVC를 불러온다.
    //   선택된 Cell의 index를 저장한다.
    //   MemoReadVC 내부에 있는 변수 param의 값을 변경한다.
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if ( segue.identifier == "memoCellSegue" || segue.identifier == "memoCellWithImageSegue" ){
//            let vc = segue.destination as? MemoReadVC
//            let selectedIndex = self.tableView.indexPathForSelectedRow!.row
//            vc?.param = self.appDelegate.memolist[selectedIndex]
//        }
//
//    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.appDelegate.memolist[indexPath.row]
        
        //코어 데이터에서 삭제한 다음, 배열 내 데이터 및 테이블 뷰 행을 차례로 삭제한다.
        if dao.delete(data.objectID!) {
            self.appDelegate.memolist.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade
            )
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text //검색 바에 입력된 값
        
        //키워드를 적용하여 데이터를 검색하고, 테이블 뷰를 갱신한다.
        self.appDelegate.memolist = self.dao.fetch(keyword: keyword)
        self.tableView.reloadData()
    }

}
