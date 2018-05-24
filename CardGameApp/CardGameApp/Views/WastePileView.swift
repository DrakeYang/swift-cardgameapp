//
//  WastePileView.swift
//  CardGameApp
//
//  Created by yuaming on 17/05/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import Foundation

class WastePileView: UIView {
  func addView(_ cardViewModel: CardViewModel?) {
    guard let cardViewModel = cardViewModel else {
      ViewUtility.addEmptyView(in: self)
      return
    }
    
    ViewUtility.addCardView(in: self, with: cardViewModel)
  }
  
  func removeAllViews() {
    subviews.forEach { $0.removeFromSuperview() }
  }
}
