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
    let statusBar = NSStatusBar.systemStatusBar()
    let statusBarItem : NSStatusItem
    let menu = NSMenu()
    let lastUpdatedItem : NSMenuItem = NSMenuItem()
    
    override init () {
        statusBarItem = statusBar.statusItemWithLength(-1)
        super.init()
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusBarItem.menu = menu
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
        let jsonDict = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: nil, error: &error) as NSDictionary
        
        if (error != nil) {
            statusBarItem.title = "--°"
        } else {
            statusBarItem.title = String(format: "%.1f°", jsonDict["fahrenheit"] as Double)
            lastUpdatedItem.title = NSDate(dateString: jsonDict["published_at"] as String).localFormat()
        }
    }
}

