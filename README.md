# SwiftThreadSafe
This package contains:
- a property wrapper `@ThreadSafe` that helps to make local variables and object properties thread-safe;
- four Read/Write synchronizers, utilized by the `@ThreadSafe` property wrapper:
	- `LockReadWriteSynchronizer` (the default `@ThreadSafe`'s synchronizer);
	- `RecursiveLockReadWriteSynchronizer`;
	- `GCDReadWriteSynchronizer`;
	- `GCDBarrierLockReadWriteSynchronizer`.

## Installation

This is a SPM package. You know what to do :-)

## Synchronizer

```swift
public class SomeObject {
	
    public var threadSafeProperty: Any? {
        get { _sync.read { _threadUnsafeInternalObject } }
        set { _sync.write { _threadUnsafeInternalObject = newValue } }
    }

    private lazy var _sync: ReadWriteSynchronizer = LockReadWriteSynchronizer()
    private var _threadUnsafeInternalObject: Any?
}
```

## @ThreadSafe property wrapper

### For local variables

```swift
func threadUnsafeCase() {
    var threadUnsafeObject: AnyObject?
    
    for _ in 0..<1000 {
        DispatchQueue.global(qos: .default).async {
            if arc4random_uniform(2) == 0 {
                // Possible race condition: other processes might be trying to access this object
                // while we are trying to assign new value to the variable:
                threadUnsafeObject = SomeObject() // Thread 4: EXC_BAD_ACCESS (code=1, address=0xc1b21be741e0)
            }
            else {
                // Possible race condition: other processes might be trying to assign new value
                // to this variable while we are trying to read the variable's value:
                _ = threadUnsafeObject // Thread 4: signal SIGABRT
            }
        }
    }
}

```

In order to make this local variable thread-safe we can wrap it with the `@ThreadSafe` property wrapper:

```swift
func threadSafeCase() {
    @ThreadSafe var threadUnsafeObject: AnyObject?
    
    for _ in 0..<1000 {
        DispatchQueue.global(qos: .default).async {
            if arc4random_uniform(2) == 0 {
                // A thread-safe write
                threadUnsafeObject = SomeObject()
            }
            else {
                // A thread-safe read
                _ = threadUnsafeObject
            }
        }
    }
}
```

### For object properties

```swift
class RaceConditionsNest {
    var threadUnsafeObject: AnyObject? // gonna crash someday
}

class ThreadSafeObject {
    @ThreadSafe var threadSafeObject: AnyObject?
}
```

## @ThreadSafe + GCDBarrierReadWriteSynchronizer

Don't use this combo as it's faulty  ¯\\\_(ツ)_/¯.

P.S. Use the **async/await** instead. It's awesome!