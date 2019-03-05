//
//  ViewController.swift
//  CardGameApp
//
//  Created by Yoda Codd on 2018. 12. 24..
//  Copyright © 2018년 Drake. All rights reserved.
//

import UIKit
import os

extension Notification.Name {
    static let cardMoved = Notification.Name("cardMoved")
}

class ViewController: UIViewController {
    /// 플레이카드가 들어가는 스택뷰
    var playDeckView = PlayDeckViewManager()
    /// 포인트덱뷰
    var pointDeckView = PointDeckView()
    /// 덱뷰 생성
    var deckView = DeckView()
    /// 오픈덱뷰 생성
    var openedDeckView = OpenedDeckView()
    
    
    
    /// 최대 카드 개수 장수로 카드사이즈 세팅
    private var cardSize = CardSize(maxCardCount: 7)
    
    /// 카드 전체 위치 배열
    private var widthPositions : [CGFloat] = []
    /// 플레이카드 Y 좌표
    private var heightPositions : [CGFloat] = []
    
    /// 카드뷰 전체 배열
    private var allCardView : [CardView] = []
    
    
    /// 게임보드 생성
    private var gameBoard = GameBoard(slotCount: 7)
    
    /// 앱 배경화면 설정
    private func setBackGroundImage() {
        // 배경이미지 바둑판식으로 출력
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "bg_pattern"))
    }
    
    /// 전체 위치를 설정
    private func calculateWidthPosition(cardSize: CardSize){
        // 0 ~ maxCardCount -1 추가
        for x in 0..<cardSize.maxCardCount {
            widthPositions.append(cardSize.originWidth * CGFloat(x) + cardSize.widthPadding)
        }
    }
    private func calculateHeightPosition(cardSize: CardSize){
        // 첫 지점은 20
        heightPositions.append(20 + cardSize.heightPadding)
        // 트럼프 카드의 종류는 13종
        for x in 0..<Numbering.allCases().count {
            // 시작지점 높이 100
            heightPositions.append(cardSize.originHeight * 0.25 * CGFloat(x) + 100 + cardSize.heightPadding)
        }
    }
    
    
    /// 최대 카드 수량 체크
    private func checkMaxCardCount(startNumber: Int, cardCount: Int) -> Bool {
        return startNumber > cardSize.maxCardCount || cardCount > cardSize.maxCardCount
    }
    
    /// 카드 이미지 출력
    private func makeCardView(widthPosition: Int, heightPosition: Int, cardSize: CardSize, cardInfo: CardInfo) -> CardView {
        // 배경 뷰 생성
        let cardView = CardView(cardInfo: cardInfo, frame: CGRect(origin: CGPoint(x: widthPositions[widthPosition - 1], y: heightPositions[heightPosition - 1]), size: cardSize.cardSize))
        // 서브뷰 추가
        return cardView
    }
    
    /// 뷰를 받아서 메인 뷰에 추가
    func addViewToMain(view: UIView){
        self.view.addSubview(view)
        return ()
    }
    
    /// 덱인포를 받아서 카드인포배열을 리턴
    func getDeckInfo(deckInfo: DeckInfo) -> [CardInfo] {
        return deckInfo.allInfo()
    }
    
    
    /// 덱을 카드뷰로 출력
    func drawDeckView(){
        // 덱을 카드객체가 아닌 프로토콜로 받는다
        let cardInfos = getDeckInfo(deckInfo: self.gameBoard)
        
        // 각 카드정보를 모두 카드뷰로 전환
        for cardInfo in cardInfos {
            // 카드뷰 생성
            let cardView = CardView(cardInfo: cardInfo, size: cardSize.cardSize)
            // 덱을 위한 탭 제스쳐를 생성, 추가한다
            cardView.addGestureRecognizer(makeTapGetstureForDeck())
            // 더블탭 이벤트도 추가한다
            cardView.addGestureRecognizer(makeDoubleTapGetstureForCardView())
            
            // 덱카드뷰에 넣는다
            self.deckView.addSubview(cardView)
            self.allCardView.append(cardView)
        }
    }
    
    /// 카드뷰 1탭 제스처시 발생하는 이벤트
    @objc func deckTapEvent(_ sender: UITapGestureRecognizer) {
        // 옮겨진 뷰가 카드뷰가 맞는지 체크
        guard let openedCardView = sender.view as? CardView else {
            os_log("터치된 객체가 카드뷰가 아닙니다.")
            return ()
        }
        
        // 꺼낸 카드가 덱뷰의 마지막 카드가 맞는지 체크
        guard openedCardView == self.deckView.subviews.last else {
            os_log("덱뷰의 마지막 카드가 아닙니다")
            return ()
        }
        
        // 카드가 뒷면인지 체크
        if openedCardView.cardViewModel.isFront() {
            // 앞면이면 종료
            os_log("카드가 앞면입니다. %@", openedCardView.cardViewModel.name() )
            return ()
        }
        
        let _ = openDeck(cardInfo: openedCardView.cardViewModel)
        
        // 이동 성공 로그
        os_log("%@",self.gameBoard.allCheck())
    }
    
    /// 덱을 오픈한다
    func openDeck(cardInfo: CardInfo) -> CardInfo? {
        // 덱의 카드를 오픈덱으로 이동
        guard let openedCardInfo = gameBoard.deckToOpened(cardInfo: cardInfo) else { return nil }
        
        // 카드인포 리턴
        return openedCardInfo
    }
    
    /// 덱을 위한 탭 제스처
    func makeTapGetstureForDeck() -> UITapGestureRecognizer {
        // 탭 제스처 선언
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.deckTapEvent(_:)))
        // 작동에 필요한 탭 횟수
        gesture.numberOfTapsRequired = 1
        // 작동에 필요한 터치 횟수
        gesture.numberOfTouchesRequired = 1
        // 제스처를 리턴한다
        return gesture
    }
    
    /// 덱 가장 밑부분의 리프레시 아이콘뷰
    func makeRefreshIconView(){
        // 뷰 기준점 설정.
        let viewPoint = CGPoint(x: widthPositions[6], y: heightPositions[0])
        // 기준점에서 카드사이즈로 이미지뷰 생성
        self.deckView.setPosotion(origin: viewPoint, size: cardSize.cardSize)
        // 제스처를 적용
        let refreshGesture = makeRefreshGesture()
        self.deckView.addGestureRecognizer(refreshGesture)
        // 뷰를 메인뷰에 추가
        addViewToMain(view: self.deckView)
    }
    
    /// 리프레시 아이콘 함수. 오픈덱 카드뷰를 역순으로 뒤집어서 덱뷰에 삽입
    @objc func refreshDeck(_ sender: UITapGestureRecognizer){
        // 게임보드도 이동해 준다
        gameBoard.openedDeckToDeck()
    }
    
    /// 리프레시 아이콘 용 제스처 생성
    func makeRefreshGesture() -> UITapGestureRecognizer {
        // 탭 제스처 선언
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.refreshDeck(_:)))
        // 작동에 필요한 탭 횟수
        gesture.numberOfTapsRequired = 1
        // 작동에 필요한 터치 횟수
        gesture.numberOfTouchesRequired = 1
        // 제스처를 리턴한다
        return gesture
    }
    
    /// 카드게임 시작시 카드뷰 전체 배치 함수
    func gameStart(){
        // 덱뷰들 출력
        drawDeckView()
        
        // 덱 드로우
        self.gameBoard.pickPlayCards()
        }
    
    /// shake 함수.
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        // 모든 카드뷰 삭제
        self.allCardView.forEach { $0.removeFromSuperview() }
        
        // 게임보드 카드들제초기화 - 카드를 덱으로 모음
        gameBoard.reset()
        
        // 카드배치를 뷰로 생성
        gameStart()
    }
    
    /// 오픈덱뷰 생성
    func makeOpenedDeckView(){
        // 뷰 기준점 설정. 5,6번째 카드 중간값 위치
        let xPosition = (widthPositions[4] + widthPositions[5]) / 2
        let viewPoint = CGPoint(x: xPosition, y: heightPositions[0])
        // 기준점에서 카드사이즈로 이미지뷰 생성
        self.openedDeckView.setPosotion(origin: viewPoint, size: cardSize.cardSize)
        addViewToMain(view: self.openedDeckView)
    }
    
    /// 노티 생성 함수
    func makeNoti(){
        NotificationCenter.default.addObserver(self, selector: #selector(afterCardMovedNoti(notification:)), name: .cardMoved, object: nil)
    }
    
    /// 카드 이동 노티를 받으면 뷰이동 함수를 실행
    @objc func afterCardMovedNoti(notification: Notification){
        /// 이동된 카드에 맞게 카드뷰를 이동시킨다
        if let pastCardData = notification.object as! PastCardData? {
            /// 덱타입을 넣어서 이동해야되는 뷰 추출
            guard let cardView = getCardView(pastCardData: pastCardData) as? CardView else { return () }
            
            /// 이전덱타입과 뷰를 넣어서 뷰 이동
            rePositinoCardView(pastCardData: pastCardData, cardView: cardView)
            
        }
    }
    
    /// 덱타입을 받아서 맞는 카드뷰를 리턴
    func getCardView(pastCardData: PastCardData) -> UIView? {
        switch pastCardData.deckType {
        case .deck : return self.deckView.subviews.last
        case .openedDeck : return self.openedDeckView.subviews.last
        case .playDeck : return self.playDeckView.getView(pastCardData: pastCardData)
        default : return nil
        }
    }
    
    /// 덱타입, 카드뷰를 받아서 카드뷰 타입과 다르면 위치이동 함수 실행
    func rePositinoCardView(pastCardData: PastCardData, cardView: CardView){
        // 노티가 온 덱타입과 받은 카드뷰 덱타입이 다르면 이동시켜준다
        if pastCardData.deckType != cardView.cardViewModel.getDeckType() {
            // 이동함수 실행
            moveCardView(pastCardData: pastCardData, cardView: cardView)
        }
        
        // 이동전과 이동후가 같은데 덱타입이 플레이덱이고 라인이 다르면 이동
        else if pastCardData.deckType == .playDeck && pastCardData.deckLine != cardView.cardViewModel.getDeckLine() {
            moveCardView(pastCardData: pastCardData, cardView: cardView)
        }
    }
    
    /// 뷰를 받아서 덱타입에 맞는 위치로 이동
    func moveCardView(pastCardData: PastCardData, cardView: CardView){
        // 임제뷰 선언
        let tempCardView = UIImageView(image: UIImage(named: cardView.name()))
        tempCardView.frame.size = cardView.frame.size
        
        // 임시뷰 용 좌표선언
        var tempPoint = cardView.origin()
        tempCardView.frame.origin = tempPoint
        
        // 임시뷰 위치 계산
        switch pastCardData.deckType {
        case .playDeck : tempPoint.addPosition(point: self.playDeckView.origin(deckLine: pastCardData.deckLine))
        case .pointDeck : tempPoint.addPosition(point: self.pointDeckView.origin(deckLine: pastCardData.deckLine))
            
        default : tempPoint.addPosition(point: cardView.superview!.frame.origin)
        }
        
        // 임시뷰 메인뷰에 추가
        addViewToMain(view: tempCardView)
        
        
        // 카드뷰 히든설정
        cardView.isHidden = true
        
        // 임시뷰 목적지 좌표 계산
        let goalPosition : CGPoint
        
        
        // 좌표 초기화
        cardView.frame.origin = CGPoint()
        
        // 덱타입에 따라 다른 덱에 넣는다
        switch cardView.cardViewModel.getDeckType() {
        case .deck : goalPosition = self.deckView.addView(cardView: cardView)
        case .openedDeck : goalPosition = self.openedDeckView.addView(cardView: cardView)
        case .pointDeck : goalPosition = self.pointDeckView.addView(cardView: cardView)
        case .playDeck : goalPosition = self.playDeckView.addView(view: cardView, deckLine: cardView.cardViewModel.getDeckLine())
        }
        
        
        // 임시뷰 이동 애니메이션
        UIView.animate(withDuration: 0.5, animations: {
            tempCardView.frame.origin.x = goalPosition.x
            tempCardView.frame.origin.y = goalPosition.y
        }, completion: { (true) in
            
            // 임시뷰 삭제
            tempCardView.removeFromSuperview()
        })
        
        
        
        // 카드 이미지 갱신
        cardView.refreshImage()
        cardView.isHidden = false
        
        
        // 이동 완료된 뷰 로깅
        os_log("뷰 이동완료. 위치 : %@ , 카드이름 : %@", cardView.cardViewModel.getDeckType().rawValue, cardView.cardViewModel.name())
    }

    /// 포인트덱뷰 위치 설정
    func setPointDeckView(){
        // 시작점은 1첫번쨰 카드 기준
        let viewPoint = CGPoint(x: widthPositions[0], y: heightPositions[0])
        self.pointDeckView.setPointDeckView(origin: viewPoint, cardSize: self.cardSize)
        addViewToMain(view: self.pointDeckView)
    }
    
    /// 더블탭 제스처시 발생하는 이벤트
    @objc func doubleTapEvent(_ sender: UITapGestureRecognizer) {
        // 옮겨진 뷰가 카드뷰가 맞는지 체크
        guard let openedCardView = sender.view as? CardView else {
            os_log("터치된 객체가 카드뷰가 아닙니다.")
            return ()
        }
        
        // 카드가 앞면인지 체크
        if openedCardView.cardViewModel.isFront() == false {
            os_log("더블탭 대상이 뒷면입니다.")
            // 뒷면이면 종료
            return ()
        }
        
        // 더블클릭된 카드의 카드인포를 게임보드로 전달
        os_log("더블탭 대상 카드인포 전달했습니다. %@ 의 %@", openedCardView.cardViewModel.getDeckType().rawValue, openedCardView.cardViewModel.name())
        cardViewTryMove(cardInfo: openedCardView.cardViewModel)
        
    }
    
    /// 덱을 위한 탭 제스처
    func makeDoubleTapGetstureForCardView() -> UITapGestureRecognizer {
        // 탭 제스처 선언
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapEvent(_:)))
        // 작동에 필요한 탭 횟수
        gesture.numberOfTapsRequired = 2
        // 제스처를 리턴한다
        return gesture
    }
    
    /// 터치에 연결되어 선택된 카드뷰의 카드인포를 게임보드에 전달
    func cardViewTryMove(cardInfo: CardInfo){
        do {
            let _ = try self.gameBoard.moveCard(cardInfo: cardInfo)
        } catch let error as ErrorMessage{
            os_log("%@", error.rawValue)
        } catch {
            os_log("카드 인도 실패 ")
        }
        
    }
    
    /// 플레이덱뷰매니저 초기세팅
    func settingPlayDeckViewManager(){
        self.playDeckView.setting(cardSize: self.cardSize, xPositions: self.widthPositions, yPositions: self.heightPositions)
        addViewToMain(view: self.playDeckView)
    }
    
    /// 뷰 드래그시 실행할 함수
    @objc func dragCardView(_ sender: UIPanGestureRecognizer){
        
    }
    
    
    /// 카드뷰 드래깅을 위한 pan 제스처 생성함수
    func makeCardViewPanGetsture() -> UIPanGestureRecognizer {
        // 제스처 선언
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.dragCardView(_:)))
        let gesture = UIPanGestureRecognizer(target: self, action: nil)
        
        
        
        
        // 제스처를 리턴한다
        return gesture
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 노티 생성
        makeNoti()
        // 카드 사이즈 계산
        cardSize.calculateCardSize(screenWidth: UIScreen.main.bounds.width)
        
        // 화면 가로사이즈를 받아서 카드출력 기준점 계산
        calculateWidthPosition(cardSize: cardSize)
        // 세로 위치 설정
        calculateHeightPosition(cardSize: cardSize)
        
        // 앱 배경 설정
        setBackGroundImage()
        
        // 리프레시 아이콘 뷰 생성
        makeRefreshIconView()
        
        // 오픈덱뷰 생성
        makeOpenedDeckView()
        
        // 포인트덱뷰 생성
        setPointDeckView()
        
        // 플레이덱뷰 생성
        settingPlayDeckViewManager()
        
        // 카드배치 시작
        gameStart()
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

