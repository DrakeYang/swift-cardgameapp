//
//  Card.swift
//  CardGame
//
//  Created by Yoda Codd on 2018. 6. 19..
//  Copyright © 2018년 JK. All rights reserved.
//

import Foundation

/// 카드 모양
enum Mark : String {
    case spade = "s"
    case clover = "c"
    case heart = "h"
    case diamond = "d"
    
    /// 출력값 리턴을 위한 함수
    func getValue() -> String {
        return self.rawValue
    }
}

/// 카드 넘버링
enum Numbering : String {
    case ace = "A"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    
    /// 출력값 리턴용
    func getValue() -> String {
        return self.rawValue
    }
}

/// 카드 객체를 만든다
class Card {
    // 카드 정보 선언
    private let numbering : Numbering
    private let mark : Mark
    
    init(mark: Mark, numbering: Numbering){
        self.mark = mark
        self.numbering = numbering
    }
    
    /// 카드정보 리턴
    func name() -> String {
        return mark.getValue() + numbering.getValue()
    }
    
    /// 카드 뒷면 리턴
    var backImage : String = {
        return "card-back"
    }()
}
