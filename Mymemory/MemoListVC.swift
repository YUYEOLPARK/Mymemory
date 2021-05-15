//
//  MemoListVC.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/05/02.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit

class MemoListVC: UITableViewController {
    //앱 델리게이트 객체의 참조 정보를 읽어온다.
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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

}
