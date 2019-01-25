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
    
    /// 전체값 출력
    static func allCases() -> [Mark] {
        var result : [Mark] = []
        result.append(.spade)
        result.append(.heart)
        result.append(.clover)
        result.append(.diamond)
        return result
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
    
    /// 전체 내용 출력
    static func allCases() -> [Numbering] {
        var result : [Numbering] = []
        result.append(.ace)
        result.append(.two)
        result.append(.three)
        result.append(.four)
        result.append(.five)
        result.append(.six)
        result.append(.seven)
        result.append(.eight)
        result.append(.nine)
        result.append(.ten)
        result.append(.jack)
        result.append(.queen)
        result.append(.king)
        return result
    }
}

protocol CardInfo {
    func image() -> String
    func flip()
    func name() -> String
    func getMarkRank() -> Int
    func getNumberingRank() -> Int
}

/// 카드 객체를 만든다
class Card : CardInfo {
    // 카드 정보 선언
    private let numbering : Numbering
    private let mark : Mark
    
    // 카드가 앞면인지
    private var front = false
    
    // 카드정보의 순위
    private let numberingRank : Int
    private let markRank : Int
    
    /// 기본형 생성자
    init(mark: Mark, numbering: Numbering){
        self.mark = mark
        self.numbering = numbering
        self.markRank = Mark.allCases().index(of: mark)!
        self.numberingRank = Numbering.allCases().index(of: numbering)!
        // allCases 에 해당 값이 없으면 안되므로 ! 사용
    }
    
    /// 카드 뒤집기
    func flip(){
        front = !front
    }
    
    /// 앞뒤상태에 따라 다른 카드 모양 리턴
    func image() -> String {
        // 카드가 앞면이면
        if front {
            return name()
        }
            // 뒷면이면
        else {
            return backImage
        }
    }
    
    /// 카드정보 리턴
    func name() -> String {
        return mark.getValue() + numbering.getValue()
    }
    
    /// 카드 뒷면 리턴
    private let backImage : String = {
        return "card-back"
    }()
    
    /// 랭크값 리턴
    func getMarkRank() -> Int {
        return self.markRank
    }
    func getNumberingRank() -> Int {
        return self.numberingRank
    }
    
    
    
    /// 카드객체를 받아서 자신과의  마크랭크차이를 리턴한다. self - input
    func markRankDifference(cardInfo: CardInfo) -> Int {
        return cardInfo.getMarkRank() - self.markRank
    }
    
    /// 카드객체를 받아서 자신과의 넘버링랭크차이를 리턴한다. self - input
    func markNumberingDifference(cardInfo: CardInfo) -> Int {
        return cardInfo.getNumberingRank() - self.numberingRank
    }
}
