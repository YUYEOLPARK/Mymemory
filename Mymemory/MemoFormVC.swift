//
//  MemoFormVC.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/05/02.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit

class MemoFormVC: UIViewController {
    var subject: String!

    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var preview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contents.delegate = self //텍스트뷰 위임
        // Do any additional setup after loading the view.
    }
    
    @IBAction func save(_ sender: Any) {
        // 내용을 입력하지 않았을 경우, 경고한다.
        guard self.contents.text?.isEmpty == false else{
            
            let alert = UIAlertController(title:nil, message: "내용을 입력해주세요", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title:"OK", style: .default, handler: nil))
            
            return
        }
        
        // MemoData 객체를 생성하고, 데이터를 담는다.
        let data = MemoData()
        
        data.title = self.subject
        data.contents = self.contents.text
        data.image = self.preview.image
        data.regdate = Date()
        
        // 앱 델리게이트 객체를 읽어온 다음, memolist 배열에 MemoData 객체를 추가한다.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memolist.append(data)
        
        // 작성폼 화면을 종료하고, 이전 화면으로 되돌아간다.
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //카메라 버튼을 클릭 했을때 호출되는 메서드
    @IBAction func pick(_ sender: Any) {
//        // 이미지 피커 인스턴스를 생성한다.
//        let picker = UIImagePickerController()
//        picker.delegate = self //이미지 피커 위임
//        picker.allowsEditing = true
//
//        // 이미지 피커를 화면에 표시
//        self.present(picker,animated: false)
        
        //픽 버튼을 클릭했을 때 앨범, 또는 카메라 선택
        let alert = UIAlertController(title: nil, message: "이미지를 가져올 곳을 선택해주세요", preferredStyle: .actionSheet)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "앨범", style: .default) { (_) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - 이미지 피커 컨트롤러 프로토콜 구현
extension MemoFormVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택된 이미지를 비리보기에 출력한다.
        self.preview.image = info[.editedImage] as? UIImage
        
        // 이미지피커 컨트롤러를 닫는다.
        picker.dismiss(animated: false, completion: nil)
    }
}

extension MemoFormVC: UINavigationControllerDelegate {
    
}

// MARK: - 텍스트뷰 프로토콜 구현
extension MemoFormVC: UITextViewDelegate{
    // 텍스트 뷰에 입력하면 호출
    func textViewDidChange(_ textView: UITextView) {
        // 내용의 최대 15자리까지 읽어 subject 변수에 저장
        let contents = textView.text as NSString
        let length = ((contents.length > 15) ? 15 : contents.length)
        self.subject = contents.substring(with:NSRange(location:0, length:length))
        
        //내비게이션 타이틀에 표시한다.
        self.navigationItem.title = self.subject
        
    }
}
