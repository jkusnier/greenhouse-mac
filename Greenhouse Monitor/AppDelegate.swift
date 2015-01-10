//
//  AppDelegate.swift
//  Greenhouse Monitor
//
//  Created by Jason Kusnier on 10/20/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let url:NSURL = NSURL(string: "http://api.weecode.com/greenhouse/v1/devices/50ff6c065067545628550887/environment")!
    let webUrl:NSURL = NSURL(string: "http://greenhouse.weecode.com/#/device/50ff6c065067545628550887")!

    var mainTimer:NSTimer?
    let statusBar = NSStatusBar.systemStatusBar()
    let statusBarItem : NSStatusItem
    let menu = NSMenu()
    let lastUpdatedItem : NSMenuItem = NSMenuItem()
    let lastHumidityItem: NSMenuItem = NSMenuItem()
    
    let messageDelay:Double = -300
    var allowMessage = true
    var lastMessage:NSDate?
    let floorTemp:Double = 34
    let ceilTemp:Double = 85
    
    override init () {
        statusBarItem = statusBar.statusItemWithLength(-1)
        super.init()
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusBarItem.menu = menu
        menu.addItem(lastUpdatedItem)
        menu.addItem(lastHumidityItem)
        menu.addItemWithTitle("Quit", action: Selector("terminate:"), keyEquivalent: "")
        
        lastUpdatedItem.action = Selector("openWebView")
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSSystemClockDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSWorkspaceDidWakeNotification, object: nil)
        
        updateTitle()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func resetTimer(aNotification: NSNotification) {
        mainTimer?.invalidate()
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
    }
    
    func updateTitle() {
        var tempString = "--°"
        var humidityString = "---%"
        var error: NSError?
        let jsonData = NSData(contentsOfURL: url)
        if (jsonData != nil) {
            let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as NSDictionary

        
            if (error == nil) {
                let fahrenheit = jsonDict["fahrenheit"] as Double
                tempString = String(format: "%.1f°", fahrenheit)
                humidityString = String(format: "%d%%", jsonDict["humidity"] as Int)
                lastUpdatedItem.title = NSDate(dateString: jsonDict["published_at"] as String).localFormat()

                if (!self.allowMessage && fahrenheit > floorTemp && fahrenheit < ceilTemp) {
                    self.allowMessage = true
                }
                
                let timeInterval:Double = (lastMessage == nil) ? 0 : lastMessage!.timeIntervalSinceNow
                if ((fahrenheit <= floorTemp || fahrenheit >= ceilTemp) && (timeInterval == 0 || timeInterval <= messageDelay) && self.allowMessage) {
                    var notification:NSUserNotification = NSUserNotification()
                    notification.title = "Temperature Alert!"
                    notification.informativeText = "Temperature at \(tempString)"
                    
                    notification.soundName = NSUserNotificationDefaultSoundName

                    if let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter() as NSUserNotificationCenter? {
                        notificationCenter.scheduleNotification(notification)
                    }
                    lastMessage = NSDate()
                    self.allowMessage = false
                }
            }
        }
        statusBarItem.title = tempString
        lastHumidityItem.title = humidityString
    }
    
    func openWebView() {
        NSWorkspace.sharedWorkspace().openURL(webUrl)
    }
}

