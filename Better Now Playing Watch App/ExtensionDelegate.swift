//import WatchKit
//
//class ExtensionDelegate: NSObject, WKExtensionDelegate {
//    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
//        for task in backgroundTasks {
//            if let refreshTask = task as? WKApplicationRefreshBackgroundTask {
//                WatchConnectivityManager.shared.handleBackgroundRefresh(task: refreshTask)
//            } else {
//                // Complete unhandled tasks
//                print("Actually Tasks: Figure it out")
//                task.setTaskCompletedWithSnapshot(false)
//            }
//        }
//    }
//    
////    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any]) async -> WKBackgroundFetchResult {
////        print("Received remote notification: \(userInfo)")
////        return .newData
////    }
//    
//    func applicationWillEnterForeground() {
//        // This method is called when the app is about to enter the foreground
//        print("App is about to enter the foreground.")
//    }
//
//    func applicationDidBecomeActive() {
//        // This method is called when the app transitions to the foreground
//        print("App has become active (woken up).")
//    }
//}
