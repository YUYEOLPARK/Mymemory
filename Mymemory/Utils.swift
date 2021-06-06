//
//  Utils.swift
//  Mymemory
//
//  Created by Joung Kisang on 2021/06/04.
//  Copyright © 2021 rubypaper. All rights reserved.
//

import UIKit

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name:"Tutorial", bundle: Bundle.main)
    }
    
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
}
