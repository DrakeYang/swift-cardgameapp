//
//  GameBoard.swift
//  CardGame
//
//  Created by Yoda Codd on 2018. 6. 19..
//  Copyright © 2018년 JK. All rights reserved.
//

import Foundation
import os

/// 카드정보배열을 리턴하는 프로토콜
protocol DeckInfo {
    func allInfo() -> [CardInfo]
}


/// 카드게임 진행을 하는 보드
class GameBoard : DeckInfo {
    
    /// 덱 선언
    private var deck = Deck()
    /// 사용자가 오픈한 카드가 모이는 덱
    private var openedDeck = OpenedDeck()
    /// 점수를 얻는 칸
    private var pointDeck = PointDeckManager()
    /// 펼쳐놓는 카드들
    private var playDeck : PlayDeckManager
    /// 플레이 카드 맥스 라인
    private let maxPlayCardLine : Int
    
    // 생성시 플레이카드가 몇열인지 받아서 생성
    init(slotCount: Int){
        self.maxPlayCardLine = slotCount
        self.playDeck = PlayDeckManager(playLineCount: self.maxPlayCardLine)
        reset()
    }
    
    /// 덱 초기화 함수. 외부에서 덱만 초기화 할수 없게 private
    private func newDeck(deckType: DeckType) -> [Card]{
        // 모든 넘버링, 마크를 리스트로 만든다
        let numberings = Numbering.allCases()
        let marks = Mark.allCases()
        
        // 덱을 비운다
        var cardList : [Card] = []
        
        // 모든종류의 카드를 덱에 추가한다
        for numbering in numberings {
            for mark in marks {
                cardList.append(Card(mark: mark, numbering: numbering, deckType: deckType))
            }
        }
        return cardList
    }
    
    /// 모든카드를 삭제하고 새 덱을 만드고 섞는다.
    func reset(){
        // 오픈덱 초기화
        self.openedDeck.reset()
        // 포인트덱 초기화
        self.pointDeck = PointDeckManager()
        // 플레이카드슬롯 리셋
        self.playDeck.resetPlayCard(playLineCount: self.maxPlayCardLine)
        
        // 덱에 전체 카드를 생성, 넣는다
        self.deck = Deck(cardList: newDeck(deckType: .deck))
        // 덱 섞기
        self.deck.shuffle()
    }
    
    
    /// 덱에서 플레이덱으로 카드를 뽑는다
    func pickPlayCards(){
        // 플레이덱 세팅
        do {
            // 플레이덱에 보낼 카드배열 생성
            let playDeck = try setPlayCards()
            // 생성된 덱 플레이덱에 삽입
            try self.playDeck.setting(playDeck: playDeck)
        }
        catch {
            os_log("플레이덱 생성실패")
        }
        
    }
    
    /// 플레이카드 초기배치
    func setPlayCards() throws -> [[Card]] {
        // 플레이덱에 전달할 배열 선언
        var popedDeck : [[Card]] = []
        
        // 덱을 펼친다. 생성된 가로배열 만큼 반복
        for x in 0..<self.maxPlayCardLine {
            // 1~ 가로배열 번호 만큼 카드를 추가. 실패시 닐 리턴
            let popedLine = try setPlayCardLine(lineNumber: x)
            // 뽑은 라인 추가
            popedDeck.append(popedLine)
        }
        // 덱을 전달
        return popedDeck
    }
    
    /// 플레이카드 한줄 세팅
    func setPlayCardLine(lineNumber: Int) throws -> [Card] {
        // 결과출력용 변수
        var result : [Card] = []
        
        // 횟수만큼 반복
        for _ in 0...lineNumber {
            // 덱에서 카드 한장 뽑는다
            guard let popedCard = deck.removeOne() else { throw ErrorMessage.notEnoughCardForPlayDeck }
            // 뽑은 카드를 플레이배열에 넣는다
            result.append(popedCard)
        }
        
        // 결과 리턴
        return result
    }
    
    
    /// 덱을 오픈
    func deckToOpened(cardInfo: CardInfo) -> CardInfo? {
        // 입력받은 카드인포가 덱의 마지막 카드와 같은지 체크
        guard cardInfo.name() == deck.info().last?.name() else { return nil}
        // 덱에서 한장 추출. 없으면 닐 리턴
        guard let popedCard = deck.removeOne()  else { return nil }
        // 카드 덱타입 수정
        popedCard.deckType = .openedDeck
        // 오픈덱은 뒤집혀야한다. 뒤집기
        popedCard.flip()
        // 추출한 카드를 열은덱 에 추가
        openedDeck.addCard(card: popedCard)
        
        
        // 카드가 떠난 덱타입 노티
        NotificationCenter.default.post(name: .cardMoved, object: DeckType.deck)
        
        // 추출한 카드의 정보를 리턴
        return popedCard
    }
    
//    /// 오픈된 덱 전부를 다시 덱에 포함. 삭제예정
//    func openedToDeck(){
//        // 오픈덱 전부를 덱에 추가한다
//        deck.addCards(cards: openedDeck.pickAllCard())
//        // 오픈덱을 비운다
//        self.openedDeck.reset()
//    }
    
    /// 덱 전체 정보를 리턴
    func allInfo() -> [CardInfo] {
        return deck.info()
    }

    /// 오픈덱 -> 덱 으로 카드전체이동. 순서 유지를 위해서 오픈덱 순서를 뒤집는다
    func openedDeckToDeck(){
        // 순서를 뒤집어줄 임시 배열
        var tempDeck : [Card] = []
        // 오픈덱 전체 리턴
        var poppedDeck = self.openedDeck.pickAllCard()
        // 오픈덱의 모든 카드가 대상.
        for _ in 0..<poppedDeck.count {
            // 뒤에서부터 카드 추출
            guard let poppedCard = poppedDeck.popLast() else { return () }
            // 카드를 뒤집는다
            poppedCard.flip()
            // 카드를 임시배열에 넣는다
            tempDeck.append(poppedCard)
        }
        // 임시배열을 덱에 추가
        deck.addCards(cards: tempDeck)
    }
    
    
    /// 카드정보를 받아서 해당 카드를 이동 가능한 위치로 이동시킨다. 이동할 곳이 없으면 이동 안함.
    func moveCard(cardInfo: CardInfo) -> CardInfo? {
        // 카드를 옮길 곳이 있는지 체크
        guard checkAddable(cardInfo: cardInfo) == true else { return nil }
        
        // 카드인포를 받아서 해당 카드를 추출한다
        guard let pickedCard = self.pickCard(cardInfo: cardInfo) else { return nil }
    
        // 이동된 카드 정보 노티 포스트
        NotificationCenter.default.post(name: .cardMoved, object: pickedCard.getDeckType())
        
        // 추출한 카드를 추가 성공시 카드인포 리턴
        return addCard(card: pickedCard)
    }
    
    /// 카드를 받아서 우선순위에 따라 추가시도한다.
    func addCard(card: Card) -> CardInfo? {
        switch card.getDeckType() {
        // 우선순위 : 포인트덱 - 플레이덱. 그 이외는 이동불가
        case .pointDeck : return self.pointDeck.addCard(card: card)
        case .playDeck : return self.pointDeck.addCard(card: card)
        default : return nil
        }
    }
    
    /// 카드인포를 받아서 해당되는 카드를 추출한다
    func pickCard(cardInfo: CardInfo) -> Card? {
        // 대상카드 체크를 위한 카드인포변수
        var pickedCard : Card?
        let cardDeckType = cardInfo.getDeckType()
        switch cardDeckType {
        case .openedDeck : pickedCard = self.openedDeck.pickCard(cardInfo: cardInfo)
        case .playDeck : pickedCard = self.playDeck.pickCard(cardInfo: cardInfo)
        // 오픈덱,플레이덱 이외의 경우 움직일수 없어야 하므로 닐 리턴 : 덱, 포인트덱 등
        default : return nil
        }
        
        // 카드픽 결과가 있으면 카드리턴, 없으면 닐 리턴
        return pickedCard
    }
    
    /// 카드 인포를 받아서 추가 가능한지 체크
    func checkAddable(cardInfo: CardInfo) -> Bool {
        switch cardInfo.getDeckType() {
            // 추가 가능 대상은 오픈덱, 포인트덱. 이외에는 불가능
        case .openedDeck : return self.openedDeck.checkPickable(cardInfo: cardInfo)
        case .pointDeck : return self.pointDeck.checkAddable(cardInfo: cardInfo)
        default : return false
        }
    }
    
    /// 라인을 받아서 플레이덱 라인의 카드인포 배열 리턴
    func getPlayDeckLineCardInfos(line: Int) -> [CardInfo] {
        return self.playDeck.getLineCardInfos(line: line)
    }
    
    func lastCardInfosInOpenedDeck() -> [CardInfo] {
        return self.openedDeck.cardList
    }
}



/// 카드 배열의 경우를 위한 확장
extension Array where Element : Card{
    /// 카드배열에 카드 추가. 처음 추가할땐 앞면. 추가되면서 마지막을 뒷면처리. 따라서 마지막만 앞면 나머지는 뒷면
    mutating func addCard(_ newElement: Element) {
        // 배열에 카드가 있으면
        if let lastCard = last {
            // 마지막 카드를 뒤집는다.
            lastCard.flip()
        }
        // 마지막 추가카드를 뒤집는다
        newElement.flip()
        // 카드추가
        append(newElement)
    }
}
