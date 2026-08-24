//
//  NotificationScheduler.swift
//  PortfolioManager
//
//  Created by Chidubem Obinwanne on 19/08/2026.
//

import UserNotifications

struct NotificationScheduler {

    static func requestPermission() async {
        try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    static func scheduleCheckInReminder(from lastConfirmed: Date) {
        schedule(
            id: "checkin-reminder",
            title: "Time for a financial check-in",
            body: "Your income and expenses haven't been confirmed in a while.",
            fireDate: Calendar.current.date(byAdding: .day, value: 90, to: lastConfirmed) ?? .now
        )
    }

    static func scheduleRiskReminder(from lastAssessed: Date) {
        schedule(
            id: "risk-reminder",
            title: "Review your risk profile",
            body: "It's been 6 months - check your risk tolerance still fits.",
            fireDate: Calendar.current.date(byAdding: .month, value: 6, to: lastAssessed) ?? .now
        )
    }

    private static func schedule(id: String, title: String, body: String, fireDate: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])   // cancel any old one first

        let interval = fireDate.timeIntervalSinceNow
        guard interval > 0 else { return }   // don't schedule something already in the past

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
}
