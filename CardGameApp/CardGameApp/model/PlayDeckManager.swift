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
        for playDeck in playDeckList {
            // 추가성공시 추가된 카드 정보를 리턴
            if let addedCard = playDeck.addCard(card: card) {
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
    
    /// 카드배열을 받아서 플레이덱 세팅을 한다
    func setting(playDeck: [[Card]]) throws {
        // 들어온 덱 라인과 이미 생성된 라인이 맞는지 체크
        if playDeck.count != self.playDeckList.count {
            // 다르면 에러
            throw ErrorMessage.playDeckSettingFail
        }
        
        // 라인이 같으면 받아서 생성
        for count in 0..<self.playDeckList.count {
            self.playDeckList[count].seting(cards: playDeck[count])
        }
    }
    
    
}
