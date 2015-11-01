//
//  ViewController.swift
//  RunLoops
//
//  Created by A S on 10/15/15.
//  Copyright © 2015 A S. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    var thread : NSThread! = nil
    var timer : NSTimer! = nil
    
    @IBAction func tapped(sender: AnyObject) {
        NSThread.detachNewThreadSelector("entry", toTarget: self, withObject: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func entry()
    {
        thread = NSThread.currentThread();
        NSThread.currentThread().name = NSDate().description;
        print("Thread entered")
        let rl = NSRunLoop.currentRunLoop()
        let w = RunLoopObserver()
//        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "printMsg", userInfo: nil, repeats: true)
        self.timer = NSTimer.init(fireDate: NSDate(), interval: 1, target: self, selector: "printMsg2", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSDefaultRunLoopMode);
        print("\(NSRunLoop.currentRunLoop())")

        
//        rl.runUntilDate(NSDate().dateByAddingTimeInterval(15))
        
        var result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 15, true)
        
        self.printResult(result)
        print("thread exit")
    }
    
    func printMsg() {
        print("msg \(NSDate())")
    }
    
    func printMsg2() {
//        sleep(10)
        print("printMsg2 \(NSDate())\n")
        var runloop =  CFRunLoopGetCurrent()
        self.timer.invalidate()
//        CFRunLoopStop(CFRunLoopGetCurrent())
        
    }
    
    func printResult(result : CFRunLoopRunResult) {
        print("CFRunLoopRunResult: ", terminator:"")

        switch (result){
            
        case CFRunLoopRunResult.Finished:
            print("Finished")
        case CFRunLoopRunResult.Stopped:
            print("Stopped")
        case CFRunLoopRunResult.TimedOut:
            print("TimedOut")
        case CFRunLoopRunResult.HandledSource:
            print("HandledSource")
        default:
            print("otherrr")
        }
    }
}

