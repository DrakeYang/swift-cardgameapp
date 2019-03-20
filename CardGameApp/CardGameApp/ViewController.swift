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
    static let manyCardMoved = Notification.Name("manyCardMoved")
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
    /// 카드이동 대기뷰 생성
    var watingDeckView = WatingDeckView()
    
    
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
    
    /// 더블탭 이벤트 플래그
    private var isDoubleTap = false
    
    /// 드래그 이벤트용 이미지뷰
    private var dragView = UIImageView()
    
    /// 카드 이동 애니메이션 하든 플래그
    private var isAnimationShowing = true
    
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
            // 드래그 이벤트도 추가한다
            cardView.addGestureRecognizer(makePanGetstureForCardView())
            
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
        
        // 로깅용 덱라인 문자로 변경
        let deckLine : String = String(openedCardView.cardViewModel.getDeckLine())
        
        // 터치된 카드 정보 로깅
        os_log("터치된 카드 : %@ 구역 %@ 라인 %@",openedCardView.cardViewModel.getDeckType().rawValue, deckLine, openedCardView.name())
        
        // 꺼낸 카드가 덱뷰의 마지막 카드가 맞는지 체크
        guard openedCardView == self.deckView.subviews.last else {
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
        // 리셋함수를 실행한다
        resetGame()
    }
    
    /// 게임 리스타트
    private func resetGame(){
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
        // 이동된 카드의 과거카드데이터를 받는다
        guard let pastCardData = notification.object as! PastCardData? else { return () }
        
        // 덱타입을 넣어서 이동해야되는 뷰 추출
        guard let cardView = getCardView(pastCardData: pastCardData) as? CardView else { return () }
        
        // 이전덱타입과 뷰를 넣어서 뷰 이동
        rePositinoCardView(pastCardData: pastCardData, cardView: cardView)
        
        // 결과 로깅
        let beforeDeckLine = String(pastCardData.deckLine)
        let presentDeckLine = String(cardView.cardViewModel.getDeckLine())
        os_log("뷰 이동 성공 - %@ 카드 : %@ 덱 %@ 라인에서 %@ 덱 %@ 라인으로.",cardView.name(), pastCardData.deckType.rawValue, beforeDeckLine, cardView.cardViewModel.getDeckType().rawValue, presentDeckLine)
        
        // 플레이덱 마지막 카드들 체크
        flipLastBackPlayCards()
        
        // 게임이 클리어 됬는지 체크
        if self.gameBoard.isAllPointDeckFull() {
            // 클리어 얼럿 실행
            victoryAlert()
        }
    }
    
    /// 웨이팅덱이 비었으면 이동이 종료된것이니 플레이덱 마지막 카드 체크
    func flipLastBackPlayCards(){
        // 웨이팅덱이 비었는지 체크
        guard self.watingDeckView.subviews.count == 0 else { return () }
        
        // 비었으면 체크함수 실행
        self.playDeckView.flipLastBackImageCardView()
    }
    
    /// 덱타입을 받아서 맞는 카드뷰를 리턴
    func getCardView(pastCardData: PastCardData) -> UIView? {
        switch pastCardData.deckType {
        case .deck : return self.deckView.subviews.last
        case .openedDeck : return self.openedDeckView.subviews.last
        case .playDeck : return self.playDeckView.getView(pastCardData: pastCardData)
        case .pointDeck : return self.pointDeckView.getCardView(pastCardData: pastCardData)
        case .watingDeck : return self.watingDeckView.subviews.last
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
        else if pastCardData.deckType == cardView.cardViewModel.getDeckType() && pastCardData.deckLine != cardView.cardViewModel.getDeckLine() {
            moveCardView(pastCardData: pastCardData, cardView: cardView)
        }
    }
    
    /// 뷰를 받아서 덱타입에 맞는 위치로 이동
    func moveCardView(pastCardData: PastCardData, cardView: CardView){
        // 임시뷰 선언
        let tempCardView = makeTempView(pastCardData: pastCardData, cardView: cardView)
        
        // 임시뷰 메인뷰에 추가
        addViewToMain(view: tempCardView)
        
        // 카드뷰 히든
        cardView.isHidden = true
        
        // 카드뷰 좌표 초기화
        cardView.frame.origin = CGPoint()
        
        // 임시뷰 목적지로 이동 후 삭제, 카드뷰 히든 해제
        moveTempView(cardView: cardView, tempCardView: tempCardView)
        
        // 카드 이미지 갱신
        cardView.refreshImage()
        
        // 이동 완료된 뷰 로깅
        os_log("뷰 이동완료. 위치 : %@ , 카드이름 : %@", cardView.cardViewModel.getDeckType().rawValue, cardView.cardViewModel.name())
    }
    
    /// 과거카드데이터, 뷰를 받아서 메인뷰 기준 같은 위치에 같은 모양의 뷰를 생성,추가한 후 리턴한다.
    func makeTempView(pastCardData: PastCardData, cardView: CardView) -> UIImageView {
        // 임시뷰 선언
        let tempCardView = makeTempViewWithoutPosition(cardView: cardView)
        
        // 임시뷰 위치 계산후 적용
        tempCardView.frame.origin.addPosition(point: calculatePositionInMain(pastCardData: pastCardData, cardView: cardView))
        
        // 생성된 임시뷰 리턴
        return tempCardView
    }
    
    /// 카드뷰를 받아서 좌표를 제외한 나머지 세팅을 한다
    func makeTempViewWithoutPosition(cardView: CardView) -> UIImageView{
        // 임시뷰 선언
        let tempCardView = UIImageView()
        
        // 임시뷰 이미지 설정. 더블탭이면 카드를 보여주고, 이외에는 뒷면
        if self.isDoubleTap {
            tempCardView.image = UIImage(named: cardView.name())
        }
        else {
            tempCardView.image = #imageLiteral(resourceName: "card-back")
        }
        
        // 사이즈는 카드와 동일
        tempCardView.frame.size = cardView.frame.size
        
        return tempCardView
    }
    
    /// 카드뷰 배열을 받아서 하나의 뷰로 러틴
    func makeTempViewFromCardViews(cardViews: [CardView]) -> UIImageView {
        let imageViews = makeManyTempViewsWithoutPosition(cardViews: cardViews)
        let result = combineImageViews(cardImageViews: imageViews)
        return result
    }
    
    /// 카드뷰들을 받아서 좌표를 제외한 나머지 세팅을 한 후 이미지뷰 배열로 리턴
    func makeManyTempViewsWithoutPosition(cardViews: [CardView]) -> [UIImageView]{
        // 결과 리턴용 변수
        var result : [UIImageView] = []
        
        // 두 카드뷰 사이의 거리를 이미지뷰 사이에도 적용한다
        let distance = cardViews[1].frame.origin.y - cardViews[0].frame.origin.y
        
        // 반복
        for cardView in cardViews {
            result.append(makeTempViewWithoutPosition(cardView: cardView))
        }
        
        // 거리를 적용해준다
        for count in 1..<result.count {
            result[count].frame.origin.y += CGFloat(count) * distance
        }
        
        return result
    }
    
    /// 이미지뷰 배열(카드이미지들)을 받아서 세로로 합친다
    func combineImageViews(cardImageViews: [UIImageView]) -> UIImageView {
        // 결과용 뷰 선언
        let resultView = UIImageView(frame: cardImageViews.first!.frame)
        
        // 모든 이미지뷰를 추가한다
        for cardView in cardImageViews {
            
            //이미지뷰를 살짝 겹쳐서 나열한다. 위치는 뷰마다 이미 적용되어 있음
            resultView.addSubview(cardView)
        }
        
        return resultView
    }
    
    /// 임시뷰 위치를 과거위치에 기반 계산해서 리턴한다
    func calculatePositionInMain(pastCardData: PastCardData, cardView: CardView) -> CGPoint {
        // 결과 리턴용 함수
        var point = CGPoint()
        
        // 출발점이 플레이덱 인 경우 y 좌표를 초기화 하기위해 y - 카드높이 해준다
        if cardView.cardViewModel.getDeckType() == .playDeck {
            point.y -= cardView.frame.size.height
        }
        
        // 임시뷰 위치 계산
        point = calculatePastCardViewPosition(pastCardData: pastCardData, cardView: cardView)
        
        // 결과 리턴
        return point
    }
    
    /// 카드뷰와 과거카드데이터를 받아서 과거위치를 리턴한다
    func calculatePastCardViewPosition(pastCardData: PastCardData, cardView: CardView) -> CGPoint {
        // 결과 리턴용 함수
        var point = CGPoint()
        
        // 임시뷰 위치 계산
        switch pastCardData.deckType {
        case .playDeck : point = self.playDeckView.origin(deckLine: pastCardData.deckLine)
        case .pointDeck : point = self.pointDeckView.origin(deckLine: pastCardData.deckLine)
            
        default : point =  cardView.superview!.frame.origin
        }
        
        // 결과리턴
        return point
    }
    
    /// 임시뷰 위치를 현재뷰에 기반 계산해서 리턴한다
    func calculatePositionInMain(cardView: CardView) -> CGPoint {
        // 결과 리턴용 함수
        var point = CGPoint()
        
        // 출발점이 플레이덱 인 경우 y 좌표를 초기화 하기위해 y - 카드높이 해준다
        if cardView.cardViewModel.getDeckType() == .playDeck {
            point.y -= cardView.frame.size.height
        }
        
        // 임시뷰 위치 계산
        point = calculatePresentCardViewPosition(cardView: cardView)
        
        // 결과 리턴
        return point
    }
    
    /// 카드뷰를 받아서 현재위치를 리턴한다
    func calculatePresentCardViewPosition(cardView: CardView) -> CGPoint {
        // 결과 리턴용 함수
        var point = CGPoint()
        
        // 임시뷰 위치 계산
        switch cardView.cardViewModel.getDeckType() {
        case .playDeck : point = self.playDeckView.origin(deckLine: cardView.cardViewModel.getDeckLine())
        case .pointDeck : point = self.pointDeckView.origin(deckLine: cardView.cardViewModel.getDeckLine())
        // 나머지 덱은 1라인 짜리들이라서 수퍼뷰와 같음
        default : point =  cardView.superview!.frame.origin
        }
        
        // 결과리턴
        return point
    }
    
    /// 원본뷰 와 임시뷰를 받아서 도착지점으로 임시뷰를 이동시킨 후 임시뷰 삭제,원본뷰 히든 해제
    func moveTempView(cardView: CardView, tempCardView: UIImageView){
        // 임시뷰 목적지 좌표 선언
        let goalPosition : CGPoint
        
        // 덱타입에 따라 다른 덱에 넣는다. 결과값으로 도착지점 위치를 구한다
        switch cardView.cardViewModel.getDeckType() {
        case .deck : goalPosition = self.deckView.addView(cardView: cardView)
        case .openedDeck : goalPosition = self.openedDeckView.addView(cardView: cardView)
        case .pointDeck : goalPosition = self.pointDeckView.addView(cardView: cardView)
        case .playDeck : goalPosition = self.playDeckView.addView(view: cardView, deckLine: cardView.cardViewModel.getDeckLine())
        case .watingDeck : goalPosition = self.watingDeckView.addView(cardView: cardView)
        }
        
        // 임시뷰 이동 애니메이션
        animate(tempView: tempCardView, originalView: cardView, goalPosition: goalPosition, duration: 0.3)
    }
    
    /// 임시뷰를 목표지점으로 이동시킨후 제거하고, 원본뷰 히든 오프 하는 함수
    func animate(tempView: UIView, originalView: UIView, goalPosition: CGPoint, duration: Double){
        // 애니메이션 쇼 플래그가 온이면
        if self.isAnimationShowing {
            // 임시뷰 이동 애니메이션            
            UIView.animate(withDuration: duration, animations: {
                tempView.frame.origin.x = goalPosition.x
                tempView.frame.origin.y = goalPosition.y
            }, completion: { (true) in
                
                // 임시뷰 삭제
                tempView.removeFromSuperview()
                
                // 원본뷰 히든 해제
                originalView.isHidden = false
            })
        }
            // 애니메이션 쇼 플래그가 오프면 애니메이션 없음.
        else {
            // 임시뷰 삭제
            tempView.removeFromSuperview()
        }
    }
    
    /// 임시뷰 배열을 받아서 목표지점으로 이동시킨후 제거하고, 원본뷰 히든 오프 하는 함수
    func animate(tempView: UIView, originalViews: [UIView], goalPosition: CGPoint, duration: Double){
        // 애니메이션 쇼 플래그가 온이면
        if self.isAnimationShowing {
            // 임시뷰 이동 애니메이션
            UIView.animate(withDuration: duration, animations: {
                tempView.frame.origin.x = goalPosition.x
                tempView.frame.origin.y = goalPosition.y
            }, completion: { (true) in
                
                // 임시뷰 삭제
                tempView.removeFromSuperview()
                
                // 원본뷰 히든 해제
                for originalView in originalViews {
                    originalView.isHidden = false
                }
            })
        }
            // 애니메이션 쇼 플래그가 오프면 애니메이션 없음.
        else {
            // 임시뷰 삭제
            tempView.removeFromSuperview()
        }
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
        
        // 더블탭 플래그 온
        self.isDoubleTap = true
        
        // 더블클릭된 카드의 카드인포를 게임보드로 전달
        os_log("더블탭 대상 카드인포 전달했습니다. %@ 의 %@", openedCardView.cardViewModel.getDeckType().rawValue, openedCardView.cardViewModel.name())
        // 카드를 모델내부에서 이동시킨다
        cardViewTryMove(cardInfo: openedCardView.cardViewModel)
        
        // 이벤트 종료. 플래그 오프
        self.isDoubleTap = false
        
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
        // 이벤트 실행된 뷰 확인
        guard let movingCardView = sender.view as? CardView else {
            os_log("드래그된 뷰가 카드뷰가 아닙니다")
            return ()
        }
        
        // 카드가 앞면인지 체크
        guard movingCardView.isFront() == true else {
            os_log("드래그된 뷰가 뒷면입니다")
            return ()
        }
        
        // 드래그뷰의 센터
        let initialCenter = self.dragView.center
        
        // 이벤트가 일어나는 뷰 기준점 이동 상태
        let translation = sender.translation(in: movingCardView.superview)
        
        // 이동카드가 여러장인경우 선언됨
        //        let cardsViewsResult = self.playDeckView.AllCardImagesAfter(cardView: movingCardView)
        
        // 드래그 이벤트 시작시
        if sender.state == .began {
            // 카드 이동 플래그 온
            self.isDoubleTap = true
            
            // 옮기려는 카드가 여러장일 경우
            if let cardsViewsResult = self.playDeckView.AllCardImagesAfter(cardView: movingCardView) {
                
                // 드래그 뷰 설정
                self.dragView = makeTempViewFromCardViews(cardViews: cardsViewsResult)
                
                // 원본카드들을 안보이게 처리한다
                for selectedCardView in cardsViewsResult {
                    selectedCardView.isHidden = true
                }
            }
                // 옮기려는 카드가 한장인 경우
            else {
                // 드래그 뷰 설정
                self.dragView = makeTempViewWithoutPosition(cardView: movingCardView)
                
                // 원본카드를 안보이게 처리한다
                movingCardView.isHidden = true
            }
            
            // 드래그뷰 센터를 커서 위치로 설정한다
            self.dragView.center = sender.location(in: self.view)
            
            // 로깅
            os_log("카드 드래그 시작 : %@", movingCardView.name())
            
            // 드래그뷰 메인뷰에 추가 및 유저인터랙션 허용
            addViewToMain(view: self.dragView)
            self.dragView.isUserInteractionEnabled = true
        }
        
        // 드래그 이동시
        if sender.state == .changed {
            // 터치 좌표가 변하는 만큼 드래그 뷰를 이동시켜준다
            self.dragView.center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
        }
        
        // 드래그 이벤트 종료시
        if sender.state == .ended || sender.state == .cancelled {
            os_log("카드 드래그 끝")
            
            // 임시뷰가 힛 테스트에 걸리기 때문에 유저 인터렉션 차단
            dragView.isUserInteractionEnabled = false
            
            // 타겟이 될 카드의 정보를 담는 모델 선언
            let targetCardViewModel = EmptyCardViewModel()
            
            // 드래그 종료 위치가 카드뷰인지 체크
            let endPositionView = self.view.hitTest(self.dragView.center, with: nil)
            if let endPositionCardView = endPositionView as? CardView  {
                os_log("드래그 종료 위치 카드 : %@",endPositionCardView.name())
                
                //타겟정보 설정
                targetCardViewModel.setting(deckType: endPositionCardView.cardViewModel.cardInfo.getDeckType(), deckLine: endPositionCardView.cardViewModel.cardInfo.getDeckLine())
            }
                // 드래그 종료 위치가 비어있는 뷰인지 체크
            else if let endPositionPlayDeckView = endPositionView as? PlayDeckView  {
                // 밑에 있는 빈뷰에세 힛테스트를 하기 위해 부모까지 유저인터렉션 해제
                endPositionPlayDeckView.superview!.isUserInteractionEnabled = false
                
                if let endPositionView = self.view.hitTest(self.dragView.center, with: nil) as? EmptyCardView  {
                    // 로그용 덱라인 문자화
                    let deckLine = String(endPositionView.model.deckLine)
                    os_log("드래그 종료 위치 카드 : 포인트덱뷰 %@ 라인 빈카드뷰",deckLine)
                    
                    //타겟정보 설정
                    targetCardViewModel.setting(deckType: endPositionView.model.deckType, deckLine: endPositionView.model.deckLine)
                }
                // 타겟카드뷰 모델 내용추가가 완료되면 유저인터렉션 다시 설정
                endPositionPlayDeckView.superview!.isUserInteractionEnabled = true
            }
            
            // 힛테스트가 끝나면 임시뷰 설정 원복
            dragView.isUserInteractionEnabled = true
            
            // 원본카드뷰가 이동하는 애니메이션이 보이지 않도록 애니메이션 쇼 플래그 오프
            self.isAnimationShowing = false
            
            // 카드 추가 시도. 추가시도 카드가 여러장이면
            let cardsViewsResult = self.playDeckView.AllCardImagesAfter(cardView: movingCardView)
            if cardsViewsResult != nil {
                // 카드뷰배열 내부의 카드인포들을 추출
                var cardInfos : [CardInfo] = []
                for selectedCardView in cardsViewsResult! {
                    cardInfos.append(selectedCardView.cardViewModel.cardInfo)
                }
                // 추출한 카드인보배열을 모두 이동
                let _ = self.gameBoard.addManyCardTo(deckType: targetCardViewModel.deckType, deckLine: targetCardViewModel.deckLine, cardInfos: cardInfos)
                
            } // 추가시도 카드가 한장이면
            else {
                let _ = self.gameBoard.addCardTo(deckType: targetCardViewModel.deckType, deckLine: targetCardViewModel.deckLine, cardInfo: movingCardView.cardViewModel.cardInfo)
            }
            
            // 애니메이션 이후 복구
            self.isAnimationShowing = true
            
            // 이동카드가 여러장일경우
            if let cardsViewsResult = self.playDeckView.AllCardImagesAfter(cardView: movingCardView) {
                // 임시뷰 다시 원위치 후 제거
                animate(tempView: dragView, originalViews: cardsViewsResult, goalPosition: calculatePositionInMain(cardView: movingCardView), duration: 0.1)
            } // 이동카드가 한장일 경우
            else {
                // 임시뷰 다시 원위치 후 제거
                animate(tempView: dragView, originalView: movingCardView, goalPosition: calculatePositionInMain(cardView: movingCardView), duration: 0.1)
            }
            // 카드 이동 플래그 false
            self.isDoubleTap = false
            
            // 드래그 이벤트 종료시점 마지막
        }
        // 지속적으로 드래그포인트 값을 초기화해준다. 안해주면 이동시 이동거리 이상으로 이동됨
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    /// 카드뷰 드래깅을 위한 pan 제스처 생성함수
    func makePanGetstureForCardView() -> UIPanGestureRecognizer {
        // 제스처 선언
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.dragCardView(_:)))
        
        // 제스처를 리턴한다
        return gesture
    }
    
    /// 빈카드 모양을 덱뷰마다 추가해준다
    private func makeEmptyDeckViews(cardSize: CardSize, xPositions: [CGFloat], yPositions: [CGFloat]){
        // 빈 카드 모양 추가
        for count in 0..<cardSize.maxCardCount {
            // 빈카드 모양 생성
            let emptyCardView = EmptyCardView(origin: CGPoint(x: xPositions[count], y: yPositions[1] + yPositions[0]), size: cardSize.cardSize)
            
            // 모델설정
            emptyCardView.model.setting(deckType: .playDeck, deckLine: count)
            
            // 추가
            addViewToMain(view: emptyCardView)
        }
    }
    
    /// 게임 클리어 얼럿을 띄운다
    private func victoryAlert(){
        // 얼럿 메세지를 설정
        let dialog = UIAlertController(title: "클리어!", message: "축하합니다! 모든 카드를 모으셨습니다!", preferredStyle: .alert)
        
        // 액션버튼 내용을 설정
        let action = UIAlertAction(title: "다시하기", style: UIAlertActionStyle.default){ (action: UIAlertAction) -> Void in
            // 다시하기 를 누르면 게임 리셋
            self.resetGame()
        }
        
        // 얼럿과 액션을 조합
        dialog.addAction(action)
        
        // 얼럿을 띄운다
        self.present(dialog, animated: true, completion: nil)
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
        
        // 플레이덱뷰 배경 빈카드뷰 생성
        makeEmptyDeckViews(cardSize: self.cardSize, xPositions: self.widthPositions, yPositions: self.heightPositions)
        
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

