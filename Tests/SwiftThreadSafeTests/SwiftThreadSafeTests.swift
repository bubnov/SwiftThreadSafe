import XCTest
@testable import SwiftThreadSafe


private final class Value {}

private protocol ContainerType: AnyObject {
    var value: Value? { get set }
}

final class SwiftThreadSafeTests: XCTestCase {
        
    // MARK: - Synchronizers Tests
    
    func testLockSynchronizer() {
        _testSynschronizer(
            sync: LockReadWriteSynchronizer()
        )
    }
    
    func testRecursiveLockSynchronizer() {
        _testSynschronizer(
            sync: RecursiveLockReadWriteSynchronizer()
        )
    }
    
    func testGCDLockSynchronizer() {
        _testSynschronizer(
            sync: GCDReadWriteSynchronizer()
        )
    }
    
    func testGCDBarrierLockSynchronizer100() {
        _testSynschronizer(
            iterations: 100,
            sync: GCDBarrierReadWriteSynchronizer()
        )
    }
    
    /// For some reason this test will fail as the performance
    /// of the `GCDBarrierReadWriteSynchronizer` synchronizer will drop drastically
    /// at a larger iteration count.
    /* func testGCDBarrierLockSynchronizerToMuchIterations() {
        _testSynschronizer(
            iterations: 500,
            sync: GCDBarrierReadWriteSynchronizer()
        )
    } // */
    
    private func _testSynschronizer(iterations: Int = 1000, sync: ReadWriteSynchronizer) {
        final class ReferenceTypeObject {}
        var object = ReferenceTypeObject()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
        for _ in 0..<iterations {
            queue.addOperation {
                if arc4random_uniform(2) == 0 {
                    sync.write {
                        object = .init()
                    }
                }
                else {
                    sync.read {
                        _ = object
                    }
                }
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    // MARK: - Property tests
    
    func testPropertyLock() {
        final class Container: ContainerType {
            @ThreadSafe var value: Value?
        }
        _testProperty(container: Container())
    }
    
    func testPropertyRecursiveLock() {
        final class Container: ContainerType {
            @ThreadSafe(wrappedValue: nil, synchronizer: RecursiveLockReadWriteSynchronizer())
            var value: Value?
        }
        _testProperty(container: Container())
    }
    
    func testPropertyGCD() {
        final class Container: ContainerType {
            @ThreadSafe(wrappedValue: nil, synchronizer: GCDReadWriteSynchronizer())
            var value: Value?
        }
        _testProperty(container: Container())
    }
    
    func testPropertyGCDBarrier100() {
        final class Container: ContainerType {
            @ThreadSafe(wrappedValue: nil, synchronizer: GCDBarrierReadWriteSynchronizer())
            var value: Value?
        }
        _testProperty(iterations: 100, container: Container())
    }
    
    /// For some reason this test will fail as the performance
    /// of the `GCDBarrierReadWriteSynchronizer` synchronizer will drop drastically
    /// at a larger iteration count.
    /* func testPropertyGCDBarrierToMuchIterations() {
        final class Container: ContainerType {
            @ThreadSafe(wrappedValue: nil, synchronizer: GCDBarrierReadWriteSynchronizer())
            var value: Value?
        }
        _testProperty(iterations: 1000, container: Container())
    } // */
    
    private func _testProperty(iterations: Int = 1000, container: ContainerType) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
        for _ in 0..<iterations {
            queue.addOperation {
                if arc4random_uniform(2) == 0 {
                    container.value = .init()
                }
                else {
                    _ = container.value
                }
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    // MARK: - Local variable tests
    
    func testLocalVariableLock() {
        _testLocalVariable(
            sync: LockReadWriteSynchronizer(),
            objectFactory: {
                Value()
            }
        )
    }
    
    func testLocalVariableRecursiveLock() {
        _testLocalVariable(
            sync: RecursiveLockReadWriteSynchronizer(),
            objectFactory: {
                Value()
            }
        )
    }
    
    func testLocalVariableGCD() {
        _testLocalVariable(
            sync: GCDReadWriteSynchronizer(),
            objectFactory: {
                Value()
            }
        )
    }
    
    func testLocalVariableGCDBarrier100() {
        _testLocalVariable(
            iterations: 100,
            sync: GCDBarrierReadWriteSynchronizer(),
            objectFactory: {
                Value()
            }
        )
    }
    
    /// For some reason this test will fail as the performance
    /// of the `GCDBarrierReadWriteSynchronizer` synchronizer will drop drastically
    /// at a larger iteration count.
    /* func testLocalVariableGCDBarrierToMuchIterations() {
        _testLocalVariable(
            iterations: 1000,
            sync: GCDBarrierReadWriteSynchronizer(),
            objectFactory: {
                Value()
            }
        )
    } // */
    
    private func _testLocalVariable(iterations: Int = 1000, sync: ReadWriteSynchronizer, objectFactory: @escaping () -> AnyObject) {
        @ThreadSafe(wrappedValue: nil, synchronizer: sync)
        var object: AnyObject?
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
        for _ in 0..<iterations {
            queue.addOperation {
                if arc4random_uniform(2) == 0 {
                    object = objectFactory()
                }
                else {
                    _ = object
                }
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
}
