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
    
    let url = NSURL(string: "http://api.weecode.com/greenhouse/v1/devices/50ff6c065067545628550887/environment")

    var mainTimer:NSTimer?
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var lastUpdatedItem : NSMenuItem = NSMenuItem()

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.title = "--°"
        
        menu.addItem(lastUpdatedItem)
        menu.addItemWithTitle("Quit", action: Selector("terminate:"), keyEquivalent: "")
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateTitle"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSSystemClockDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetTimer:", name: NSWorkspaceDidWakeNotification, object: nil)
        
        updateTitle()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func resetTimer(notification: NSNotification) {
        mainTimer?.invalidate()
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateTitle:"), userInfo: nil, repeats: true)
    }
    
    func updateTitle() {
        var error: NSError?
        let jsonData = NSData(contentsOfURL: url!)
        let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as NSDictionary
        
        if (error != nil) {
            statusBarItem.title = "--°"
        } else {
            let fahrenheit:Double = jsonDict["fahrenheit"] as Double
            statusBarItem.title = String(format: "%.1f°", fahrenheit)
            var date:NSDate = NSDate(dateString: jsonDict["published_at"] as String)
            lastUpdatedItem.title = date.localFormat()
        }
    }
}

