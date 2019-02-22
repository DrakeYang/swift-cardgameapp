//
//  Deck.swift
//  CardGame
//
//  Created by Yoda Codd on 2018. 6. 20..
//  Copyright © 2018년 JK. All rights reserved.
//

import Foundation
/// 카드들을 가지고 있는 구조체
class Deck {
    // 덱 선언
    private var cardList : [Card] = []
    
    // 이니셜라이저는 두종류
    init(){ }
    init(cardList: [Card]){
        self.cardList = cardList
    }
    
    
    /// 카드수 리턴
    func count() -> Int {
        return cardList.count
    }
    
    /// 카드 한장을 빼서 리턴
    func removeOne() -> Card? {
        // 카드가 있으면 마지막 팝, 없으면 닐 리턴
        return cardList.popLast()
    }
    
    /// 카드를 섞는다
    func shuffle(){
        // 임시 덱 생성
        var tempDeck : [Card] = []
        // 카운트 프로퍼티 생성
        var cardCount = count()
        // 반복문으로 셔플을 시작한다
        while cardCount > 0 {
            // 0 ~ 카운트 까지중 랜덤수자를 생성한다
            let randomNumberingNumber = Int(arc4random_uniform(UInt32(cardCount)))
            // 덱의 렌덤위치를 임시덱으로 옮긴다. 이과정에서 기존덱의 항목은 빠진다.
            tempDeck.append(self.cardList.remove(at: randomNumberingNumber))
            // 작업이 끝나면 카운트를 줄인다
            cardCount -= 1
        }
        // 기존덱을 셔플이 끝난 임시덱으로 바꾼다
        cardList = tempDeck
    }
    
    /// 카드를 입력받은 수만큼 배열로 리턴하는 함수
    func removeCards(_ number: Int) -> Slot? {
        // 리턴용 배열 선언
        var result : [Card] = []
        // 입력받은만큼 카드를 빼서 추가한다
        for _ in 0..<number {
            // 한장을 뺴서 임시카드를 만든다
            if let tempCard = removeOne() {
                // 임시카드를 결과배열에 추가한다
                result.append(tempCard) 
            } // 뽑을 카드가 없으면 닐 리턴
            else {
                return nil
            }
        }
        // 결과배열 리턴
        return Slot(result)
    }
    
    /// 전체 카드를 정보로 표현
    func info() -> [CardInfo] {
        return cardList
    }
    
    /// 카드배열을 받아서 추가. 오픈덱 -> 덱
    func addCards(cards: [Card]){
        // 모든 카드가 대상
        for card in cards {
            // 이동 전의 과거카드데이터 생성
            let pastCardData = PastCardData(cardInfo: card)
            // 덱 타입 수정
            card.deckType = .deck
            // 카드 추가
            cardList.append(card)
            // 카드가 추가되었음을 알리는 노티
            NotificationCenter.default.post(name: .cardMoved, object: pastCardData)
        }
    }
}
