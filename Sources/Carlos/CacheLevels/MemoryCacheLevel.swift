import Combine
import Foundation

/// This class is a memory cache level. It internally uses NSCache, and has a configurable total cost limit that defaults to 50 MB.
public final class MemoryCacheLevel<K: StringConvertible, T: AnyObject>: CacheLevel where T: ExpensiveObject {
  /// At the moment the memory cache level only accepts String keys
  public typealias KeyType = K
  public typealias OutputType = T

  private let internalCache: NSCache<NSString, AnyObject>

  /**
   Initializes a new memory cache level

   - parameter cost: The total cost limit for the memory cache. Defaults to 50 MB
   */
  public init(capacity: Int = 50 * 1024 * 1024) {
    internalCache = NSCache()
    internalCache.totalCostLimit = capacity
  }

  /**
   Synchronously gets a value for the given key

   - parameter key: The key for the value

   - returns: A Future where you can call onSuccess and onFailure to be notified of the result of the fetch
   */
  public func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    AnyPublisher.create { [weak self] promise in
      if let result = self?.internalCache.object(forKey: key.toString() as NSString) as? T {
        Logger.log("MemoryCacheLevel| Fetched \(key.toString()) on memory level.", .info)
        promise(.success(result))
      } else {
        Logger.log("MemoryCacheLevel| Failed fetching \(key.toString()) on the memory cache.", .info)
        promise(.failure(FetchError.valueNotInCache))
      }
    }
    .eraseToAnyPublisher()
  }

  /**
   Clears the contents of the cache
   */
  public func onMemoryWarning() {
    clear()
  }

  /**
   Sets a value for the given key

   - parameter value: The value to set
   - parameter key: The key for the value
   */
  public func set(_ value: T, forKey key: K) -> AnyPublisher<Void, Error> {
    Logger.log("MemoryCacheLevel| Setting a value for the key \(key.toString()) on the memory cache \(self).", .info)
    internalCache.setObject(value, forKey: key.toString() as NSString, cost: value.cost)

    return Just(())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  /**
   Clears the contents of the cache
   */
  public func clear() {
    internalCache.removeAllObjects()
  }
}
