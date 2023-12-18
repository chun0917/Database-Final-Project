//
//  TimerUIApplication.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/27.
//

import UIKit

class ScreenIdleTimerUIApplication: UIApplication {

    let kMaxIdleTimeSeconds: TimeInterval = 300 // 最多閒置 5 分鐘
        
    var idleTimer: Timer?

    var tappedCount: Int = 0

    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        let allTouchs = event.allTouches
        
        tappedCount += 1
        
        if (allTouchs?.count ?? 0) > 0 {
            let phase = (allTouchs?.first)?.phase
            if phase == .began && tappedCount == 1 {
                UserPreferences.shared.idleStartTime = Date()
                UserPreferences.shared.idleEndTime = UserPreferences.shared.idleStartTime.addingTimeInterval(kMaxIdleTimeSeconds)
//                #if DEBUG
//                print(UserPreferences.shared.idleStartTime, UserPreferences.shared.idleEndTime)
//                #endif
                resetIdleTimer()
            }
            tappedCount = 0
        }
    }

    func resetIdleTimer() {
        if idleTimer != nil {
            idleTimer = nil
            idleTimer?.invalidate()
        }
        
        let timeOut = kMaxIdleTimeSeconds
        
        DispatchQueue.main.async {
            self.idleTimer = Timer.scheduledTimer(timeInterval: timeOut,
                                                  target: self,
                                                  selector: #selector(self.idleTimerPostNotification),
                                                  userInfo: nil,
                                                  repeats: false)
        }
    }
    
    @objc func idleTimerPostNotification() {
        NotificationCenter.default.post(name: .kApplicationDidIdle10MinsNotification, object: nil)
    }
}
