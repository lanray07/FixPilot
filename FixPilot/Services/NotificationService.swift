import Foundation
import UserNotifications

final class NotificationService {
    func requestAuthorization() async throws {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleReminder(for task: RecurringMaintenanceTask) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Maintenance due"
        content.body = "\(task.title) is due for review."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.nextDueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}
