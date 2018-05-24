//
//  UIImageView+.swift
//  CardGameApp
//
//  Created by yuaming on 17/05/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit

extension UIImageView {
  func generateEmptyView(widthPosition: Int = 0, heightPosition: Int = 0) {
    self.frame = UIView.setFrame(widthPosition: widthPosition, heightPosition: heightPosition)
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 2
    self.layer.cornerRadius = 3
    self.layer.masksToBounds = true
  }
  
  func generateRefreshView() {
    self.frame = UIView.setFrame()
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 2
    self.layer.cornerRadius = 3
    self.layer.masksToBounds = true
    self.image = UIImage(imageLiteralResourceName: LiteralResoureNames.refresh)
  }
}
