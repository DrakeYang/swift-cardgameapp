//
//  UIImageView+Size.swift
//  CardGameApp
//
//  Created by yuaming on 17/05/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit

extension UIImageView {
  func setFrame() -> CGRect {
    return CGRect(origin: .zero, size: CGSize(width: ViewSettings.cardWidth, height: ViewSettings.cardHeight))
  }
  
  func generateEmptyView() {
    self.frame = setFrame()
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 2
    self.layer.cornerRadius = 3
    self.layer.masksToBounds = true
  }
  
  func generateRefreshView() {
    self.frame = setFrame()
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 2
    self.layer.cornerRadius = 3
    self.layer.masksToBounds = true
    self.image = UIImage(imageLiteralResourceName: LiteralResoureNames.refresh)
  }
}
