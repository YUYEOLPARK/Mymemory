//
//  CGLogButton.swift
//  Mymemory
//
//  Created by dongadevp1 on 2021/05/27.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit

public enum CSLogType: Int {
    case basic //기본 로그 타입
    case title //버튼의 타이틀을 출력
    case tag // 버튼의 태그값을 출력
}

public class CSLogButton: UIButton {
    //로그 출력 타입
    public var logType: CSLogType = .basic
    
    //스토리보드 에서 호출할 초기화 메소드
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        //버튼에 스타일 적용
        self.setBackgroundImage(UIImage(named:"button-bg"), for: .normal)
        self.tintColor = .white
        
        // 버튼이 클릭 이벤트에 메소드 연결
        self.addTarget(self, action: #selector(loggin(_:)), for: .touchUpInside)
    }
    
    @objc func loggin(_ sender: UIButton) {
        switch self.logType {
            case .basic: //단순히 로그만 출력함
                NSLog("버튼이 클릭되었습니다.")
            case .title:
                let btnTitle = sender.titleLabel?.text ?? "타이틀 없는"
                NSLog("\(btnTitle) 버튼이 클릭 되었습니다.")
            case .tag:
                NSLog("\(sender.tag) 버튼이 클릭되었습니다.")
        }
    }
}
