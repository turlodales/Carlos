import Combine
import Foundation

/// Abstract an object that can transform values to another type and back to the original one
public protocol TwoWayTransformer: OneWayTransformer {
  /**
   Apply the inverse transformation from B to A

   - parameter val: The value to inverse transform

   - returns: A Future that will contain the original value, or fail if the transformation failed
   */
  func inverseTransform(_ val: TypeOut) -> AnyPublisher<TypeIn, Error>
}

extension TwoWayTransformer {
  /**
   Inverts a TwoWayTransformer

   - returns: A TwoWayTransformationBox that takes the output type of the original transformer and returns the input type of the original transformer
   */
  public func invert() -> TwoWayTransformationBox<TypeOut, TypeIn> {
    TwoWayTransformationBox(
      transform: inverseTransform,
      inverseTransform: transform
    )
  }
}

/// Simple implementation of the TwoWayTransformer protocol
public final class TwoWayTransformationBox<I, O>: TwoWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = I

  /// The output type of the transformation box
  public typealias TypeOut = O

  private let transformClosure: (I) -> AnyPublisher<O, Error>
  private let inverseTransformClosure: (O) -> AnyPublisher<I, Error>

  /**
   Initializes a new instance of a 2-way transformation box

   - parameter transform: The transformation closure to convert a value of type TypeIn to a value of type TypeOut
   - parameter inverseTransform: The transformation closure to convert a value of type TypeOut to a value of type TypeIn
   */
  public init(transform: @escaping ((I) -> AnyPublisher<O, Error>), inverseTransform: @escaping ((O) -> AnyPublisher<I, Error>)) {
    transformClosure = transform
    inverseTransformClosure = inverseTransform
  }

  /**
   Converts a value of type TypeIn to a value of type TypeOut

   - parameter val: The value to convert

   - returns: A Future that will contain the converted value, or fail if the transformation fails
   */
  public func transform(_ val: I) -> AnyPublisher<O, Error> {
    transformClosure(val)
  }

  /**
   Converts a value of type TypeOut to a value of type TypeIn

   - parameter val: The value to convert

   - returns: A Future that will contain the converted value, or fail if the inverse transformation fails
   */
  public func inverseTransform(_ val: O) -> AnyPublisher<I, Error> {
    inverseTransformClosure(val)
  }
}
