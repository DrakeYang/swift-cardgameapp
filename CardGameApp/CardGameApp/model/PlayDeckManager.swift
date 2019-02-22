//
//  PlayDeckManager.swift
//  CardGameApp
//
//  Created by Yoda Codd on 2019. 2. 3..
//  Copyright © 2019년 Drake. All rights reserved.
//

import Foundation

class PlayDeckManager {
    /// 플레이덱 배열화
    var playDeckList : [PlayDeck] = []
    
    /// 플레이카드 열을 받아서 생성
    init(playLineCount: Int){
        resetPlayCard(playLineCount: playLineCount)
    }
    
    /// 카드를 받아서 추가
    func addCard(card: Card) -> CardInfo? {
        // 모든 덱 대상
        for count in 0..<playDeckList.count {
            // 추가성공시 추가된 카드 정보를 리턴
            if let addedCard = playDeckList[count].addCard(card: card) {
                // 라인변경 적용
                card.deckLine = count
                // 카드인포 리턴
                return addedCard
            }
        }
        // 추가 실패리 닐리턴
        return nil
    }
    
    /// 플레이카드 초기화 함수
    func resetPlayCard(playLineCount: Int){
        // 플레이 카드 초기화
        self.playDeckList = []
        // 플레이카드 라인만큼 배열 추가
        for _ in 0..<playLineCount {
            self.playDeckList.append(PlayDeck())
        }
    }
    
    /// 게임시작시 카드배열을 받아서 플레이덱 세팅을 한다
    func setting(playDeck: [[Card]]) throws {
        // 들어온 덱 라인과 이미 생성된 라인이 맞는지 체크
        if playDeck.count != self.playDeckList.count {
            // 다르면 에러
            throw ErrorMessage.playDeckSettingFail
        }
        
        // 라인이 같으면 받아서 생성
        for count in 0..<self.playDeckList.count {
            // 카드배열과 덱라인을 보낸다
            self.playDeckList[count].seting(cards: playDeck[count], deckLine: count)
        }
    }
    
    /// 카드인포를 받아서 해당 라인의 마지막 카드가 인포와 맞는지 체크. 맞으면 카드 리턴
    func pickCard(cardInfo: CardInfo) -> Card? {
        return self.playDeckList[cardInfo.getDeckLine()].pickCard(cardInfo:cardInfo)
    }
    
    /// 라인을 받아서 플레이덱 라인의 카드인포 배열 리턴
    func getLineCardInfos(line: Int) -> [CardInfo] {
        return self.playDeckList[line].getAllCardInfo()
    }
    
    /// 카드인포를 받아서 뽑을수 있는 카드인지 체크
    func checkPickable(cardInfo: CardInfo) -> Card? {
        // 덱 라인을 받아서 배열에 매칭한다
        let count = cardInfo.getDeckLine()
        return self.playDeckList[count].checkPickable(cardInfo: cardInfo)
    }
    
    /// 카드 강제추가. 카드를 되돌리는 역할
    func undoCard(card: Card){
        self.playDeckList[card.getDeckLine()].undoCard(card: card)
    }
}
