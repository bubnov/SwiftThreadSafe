import Foundation


public protocol ReadSynchronizer {
    func read<T>(closure: @escaping () -> T) -> T
}

public protocol WriteSynchronizer {
    func write(closure: @escaping () -> Void)
}

public protocol ReadWriteSynchronizer: ReadSynchronizer, WriteSynchronizer {}

// MARK: - ThreadSafe property wrapper

@propertyWrapper
public final class ThreadSafe<Value> {
    
    private let _synchronizer: ReadWriteSynchronizer
    private var _value: Value

    public init(wrappedValue: Value, synchronizer: ReadWriteSynchronizer = LockReadWriteSynchronizer()) {
        _value = wrappedValue
        _synchronizer = synchronizer
    }
    
    public var projectedValue: ThreadSafe { self }
    
    public var wrappedValue: Value {
        get {
            _synchronizer.read {
                self._value
            }
        }
        set {
            _synchronizer.write {
                self._value = newValue
            }
        }
    }
    
    public func mutate(closure: @escaping (Value) -> Value) {
        _synchronizer.write {
            self._value = closure(self._value)
        }
    }
}

// MARK: - Lock read/write synchronizer

public struct LockReadWriteSynchronizer: ReadWriteSynchronizer {
    
    private let _lock: NSLock = .init()
    
    public init() {}
    
    public func read<T>(closure: @escaping () -> T) -> T {
        _lock.lock()
        defer { _lock.unlock() }
        return closure()
    }
    
    public func write(closure: @escaping () -> Void) {
        _lock.lock()
        defer { _lock.unlock() }
        closure()
    }
}

// MARK: - Recursive lock read/write synchronizer

public struct RecursiveLockReadWriteSynchronizer: ReadWriteSynchronizer {
    
    private let _lock: NSRecursiveLock = .init()
    
    public init() {}
    
    public func read<T>(closure: @escaping () -> T) -> T {
        _lock.lock()
        defer { _lock.unlock() }
        return closure()
    }
    
    public func write(closure: @escaping () -> Void) {
        _lock.lock()
        defer { _lock.unlock() }
        closure()
    }
}

// MARK: - GCD read/write synchronizer

public struct GCDReadWriteSynchronizer: ReadWriteSynchronizer {
    
    private let _queue = DispatchQueue(label: "rw-synchronizer")
    
    public init() {}
    
    public func read<T>(closure: @escaping () -> T) -> T {
        _queue.sync(execute: closure)
    }
    
    public func write(closure: @escaping () -> Void) {
        _queue.sync(execute: closure)
    }
}

// MARK: - GCD Barrier read/write synchronizer

public struct GCDBarrierReadWriteSynchronizer: ReadWriteSynchronizer {
    
    private let _queue = DispatchQueue(label: UUID().uuidString, attributes: .concurrent)
    
    public init() {}
    
    public func read<T>(closure: @escaping () -> T) -> T {
        _queue.sync(execute: closure)
    }
    
    public func write(closure: @escaping () -> Void) {
        _queue.async(flags: .barrier, execute: closure)
    }
}
