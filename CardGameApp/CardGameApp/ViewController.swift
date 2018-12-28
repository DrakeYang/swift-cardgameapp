//
//  ViewController.swift
//  CardGameApp
//
//  Created by Yoda Codd on 2018. 12. 24..
//  Copyright © 2018년 Drake. All rights reserved.
//

import UIKit

struct CardSize {
    init(){}
    init(width: CGFloat, MaxCount: Int ){
        // 입력값 원본
        self.originWidth = width / CGFloat(MaxCount)
        self.originHeight = self.originWidth * 1.25
        
        // 패딩 좌우 0.1 * 2 를 제외한 0.8
        self.width = self.originWidth * 0.8
        // 가로세로 비율 1.25
        self.height = self.width  * 1.25
        
        // 한쪽 패딩 사이즈 * 0.1
        self.widthPadding = self.originWidth * 0.1
        self.heightPadding = self.originHeight * 0.1
    }
    
    /// 입력받은 가로값
    var originWidth : CGFloat = 0
    /// 입력받은 가로 * 1.25
    var originHeight : CGFloat = 0
    /// 카드 가로값. origin * 0.9
    var width : CGFloat = 0
    /// 카드 세로값
    var height : CGFloat = 0
    /// originWidth * 0.1
    var widthPadding : CGFloat = 0
    /// originHeight * 0.1
    var heightPadding : CGFloat = 0
}


class ViewController: UIViewController {
    
    /// status var height
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    /// 카드 개수
    let maxCardCount = 7
    
    /// 카드 덱
    var cardDeck = Deck()
    
    /// 카드 전체 위치 배열
    var widthPositions : [CGFloat] = []
    
    var cardSize = CardSize()
    
    /// 앱 배경화면 설정
    func setBackGroundImage() {
        // 배경이미지 바둑판식으로 출력
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "bg_pattern"))
    }
    
    /// 전체 위치를 설정
    func calculateRawPosition(cardSize: CardSize) {
        // 0 ~ maxCardCount -1 추가
        for x in 0..<maxCardCount {
            widthPositions.append(cardSize.originWidth * CGFloat(x))
        }
    }
    
    /// 뷰 테두리 생성
    func makeViewBorder(imageView: UIImageView){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.white.cgColor
        
    }
    
    /// 최대 카드 수량 체크
    func checkMaxCardCount(startNumber: Int, cardCount: Int) -> Bool {
        return startNumber > maxCardCount || cardCount > maxCardCount
    }
    
    /// 첫줄 카드배경 출력
    func setObjectPositions(height: CGFloat, cardSize: CardSize){
        // 원하는 빈칸은 4칸
        for x in 1...4 {
        // 카드 빈자리 4장 출력
            addCardView(widthPosition: x, height: 20, cardSize: cardSize, cardImage: nil)
        }
    }
    
    
    /// 카드 * cardCount 출력
    func addCardViews(startNumber: Int, cardCount: Int, height: CGFloat, cardSize: CardSize, cards: Slot){
        // 최대 카드 수량을 넘어가면 강제리턴
        if checkMaxCardCount(startNumber: startNumber, cardCount: startNumber) {
            return ()
        }
        
        // 0 ~ cardCount-1 까지
        for x in startNumber..<(startNumber + cardCount) {
            // slot 인덱스를 넘어가면 리턴
            guard let card = cards.pop() else { return () }
            // 카드 이름으로 카드이미지 연결
            let cardImage = UIImage(named: card.name())
            // 이미지를 뷰로 출력
            addCardView(widthPosition: x, height: height, cardSize: cardSize, cardImage: cardImage)
        }
    }
    
    /// 뷰를 받아서 패딩 적용된 이미지뷰를 추가한다
    func addSubImageVIew(superView: UIView, cardSize: CardSize, image: UIImage?){
        // 카드사이즈로 뷰 생성
        let cardImageView : UIImageView = UIImageView(frame: CGRect(x: superView.bounds.origin.x + cardSize.widthPadding, y: superView.bounds.origin.y + cardSize.heightPadding, width: cardSize.width, height: cardSize.height))
        
        // 뒷 테두리 추가
        makeViewBorder(imageView: cardImageView)
        
        
        // 카드사이즈 뷰에 이미지 생성
        cardImageView.image = image
        
        // 카드사이즈 뷰를 배경뷰에 추가
        superView.addSubview(cardImageView)
        
        
    }
    
    /// 카드 이미지 출력
    func addCardView(widthPosition: Int, height: CGFloat, cardSize: CardSize, cardImage: UIImage?){
        // 배경 뷰 생성
        let cardView : UIImageView = UIImageView(frame: CGRect(x: widthPositions[widthPosition - 1], y: height, width: cardSize.originWidth, height: cardSize.originHeight))
        // 카드사이즈로 뷰 생성
        addSubImageVIew(superView: cardView, cardSize: cardSize, image: cardImage)
        
        // 서브뷰 추가
        self.view.addSubview(cardView)
        
    }
    
    /// 랜덤카드 7장 출력
    func drawFirstCards(){
        guard var randomCards = cardDeck.removeCards(7) else { return ()}
        
        for x in 1...randomCards.count {
            guard let card = randomCards.popLast() else { return () }
            let cardImage = UIImage(named: card.name())
            addCardView(widthPosition: x, height: 20, cardSize: cardSize, cardImage: cardImage)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 카드 사이즈 계산
        cardSize = CardSize(width: UIScreen.main.bounds.width, MaxCount: maxCardCount)
        
        calculateRawPosition(cardSize: cardSize)
        
        // 앱 배경 설정
        setBackGroundImage()
        
        // 카드덱 초기화
        cardDeck.reset()
        
        // 카드 빈자리 4장 출력
        setObjectPositions(height: 20, cardSize: cardSize)
        
        // 카드 뒷면 생성
        addCardView(widthPosition: 7, height: 20, cardSize: cardSize, cardImage: #imageLiteral(resourceName: "card-back"))
        
        // 랜덤카드 7장 생성
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

// Configure StatusBar
extension ViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
