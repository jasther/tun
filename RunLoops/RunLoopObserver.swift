import Foundation

@objc public class RunLoopObserver: NSObject {

    private var threshold: Double
    
    private var runLoop: CFRunLoopRef = CFRunLoopGetCurrent()
    private var observer: CFRunLoopObserverRef!
    private var startTime: UInt64 = 0
    private var lastTime: UInt64 = 0
    private var handler: ((Double) -> ())? = nil
    private var secondsPerMachine: NSTimeInterval = 0
    public init(threshold: Double = 0.2, handler: ((Double) -> ())? = nil) {
        
        self.threshold = threshold
        self.handler = handler
        super.init()
        
        var timebase: mach_timebase_info_data_t = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&timebase)
        self.secondsPerMachine = NSTimeInterval(Double(timebase.numer) / Double(timebase.denom) / Double(1e9))

        observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
            CFRunLoopActivity.AllActivities.rawValue,
            true,
            0) { [weak self] (observer, activity) in
                
                guard let weakSelf = self else {
                    return
                }
                
                switch(activity) {
                    
                case CFRunLoopActivity.Entry, CFRunLoopActivity.BeforeTimers,
                CFRunLoopActivity.AfterWaiting, CFRunLoopActivity.BeforeSources:
                    
                    if weakSelf.startTime == 0 {
                        weakSelf.startTime = mach_absolute_time()
                        
                    }
                    
                    self!.printActivity(activity)
                    self?.printLastTime()

                case CFRunLoopActivity.BeforeWaiting:
                    self!.printActivity(activity)
                    self?.printLastTime()
                    
                    let elapsed = mach_absolute_time() - weakSelf.startTime
                    let duration: NSTimeInterval = NSTimeInterval(elapsed) * weakSelf.secondsPerMachine
                    print("Main thread was blocked for " + String(format:"%.4f\n", duration))
                    
                    weakSelf.startTime = 0
                    
                case CFRunLoopActivity.Exit:
                    
                    self!.printActivity(activity)
                    self?.printLastTime()
                    
                default:
                    self!.printActivity(activity)
                    self?.printLastTime()
                }
        }
        
        print("\(self.runLoop)")
        CFRunLoopAddObserver(self.runLoop, observer, kCFRunLoopDefaultMode)
    }
    
    func printLastTime() {
        if self.lastTime == 0 {
            self.lastTime = mach_absolute_time()
            print("First time observer called")
        }
        
        let elapsed = mach_absolute_time() - self.lastTime;
        let duration: NSTimeInterval = NSTimeInterval(elapsed) * self.secondsPerMachine
        print("Since last time " + String(format:"%.4f\n", duration))
        self.lastTime = mach_absolute_time()
    }
    
    deinit {
        CFRunLoopObserverInvalidate(observer)
    }
    
    func printActivity(activity: CFRunLoopActivity) {
        print(">>>>>>>>>>>")

        switch (activity){
        
        case CFRunLoopActivity.Entry:
            print("Entry")
        case CFRunLoopActivity.BeforeTimers:
            print("BeforeTimers")
        case CFRunLoopActivity.AfterWaiting:
            print("AfterWaiting")
        case CFRunLoopActivity.BeforeSources:
            print("BeforeSources")
        case CFRunLoopActivity.BeforeWaiting:
            print("BeforeWaiting")
        case CFRunLoopActivity.Exit:
            print("Exit")
        default:
            print("otherrr")
        }
    }
}