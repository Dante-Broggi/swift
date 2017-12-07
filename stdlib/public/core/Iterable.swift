//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A type that supplies the values of an iterable one at a time.
///
/// The `IteratorProtocol` protocol is tightly linked with the `Iterable` and
/// `Sequence` protocols. Iterables provide access to their elements by
/// creating an iterator, which keeps track of its iteration process and
/// returns one element at a time as it advances through the iterable.
///
/// Whenever you use a `for`-`in` loop with an array, set, or any other
/// collection, sequence or iterable, you're using that type's iterator.
/// Swift uses a sequence's, collection's or iterable's iterator
/// internally to enable the `for`-`in` loop language construct.
///
/// Using a iterable's iterator directly gives you access to the same elements
/// in the same order as iterating over that iterable using a `for`-`in` loop.
/// For example, you might typically use a `for`-`in` loop to print each of
/// the elements in an array.
///
///     let animals = ["Antelope", "Butterfly", "Camel", "Dolphin"]
///     for animal in animals {
///         print(animal)
///     }
///     // Prints "Antelope"
///     // Prints "Butterfly"
///     // Prints "Camel"
///     // Prints "Dolphin"
///
/// Behind the scenes, Swift uses the `animals` array's iterator to loop over
/// the contents of the array.
///
///     var animalIterator = animals.makeIterator()
///     while let animal = animalIterator.next() {
///         print(animal)
///     }
///     // Prints "Antelope"
///     // Prints "Butterfly"
///     // Prints "Camel"
///     // Prints "Dolphin"
///
/// The call to `animals.makeIterator()` returns an instance of the array's
/// iterator. Next, the `while` loop calls the iterator's `next()` method
/// repeatedly, binding each element that is returned to `animal` and exiting
/// when the `next()` method returns `nil`.
///
/// Using Iterators Directly
/// ========================
///
/// You rarely need to use iterators directly, because a `for`-`in` loop is the
/// more idiomatic approach to traversing a sequence in Swift. Some
/// algorithms, however, may call for direct iterator use.
///
/// One example is the `reduce1(_:)` method. Similar to the `reduce(_:_:)`
/// method defined in the standard library, which takes an initial value and a
/// combining closure, `reduce1(_:)` uses the first element of the sequence as
/// the initial value.
///
/// Here's an implementation of the `reduce1(_:)` method. The sequence's
/// iterator is used directly to retrieve the initial value before looping
/// over the rest of the sequence.
///
///     extension Sequence {
///         func reduce1(
///             _ nextPartialResult: (Element, Element) -> Element
///         ) -> Element?
///         {
///             var i = makeIterator()
///             guard var accumulated = i.next() else {
///                 return nil
///             }
///
///             while let element = i.next() {
///                 accumulated = nextPartialResult(accumulated, element)
///             }
///             return accumulated
///         }
///     }
///
/// The `reduce1(_:)` method makes certain kinds of sequence operations
/// simpler. Here's how to find the longest string in a sequence, using the
/// `animals` array introduced earlier as an example:
///
///     let longestAnimal = animals.reduce1 { current, element in
///         if current.count > element.count {
///             return current
///         } else {
///             return element
///         }
///     }
///     print(longestAnimal)
///     // Prints "Butterfly"
///
/// Using Multiple Iterators
/// ========================
///
/// Whenever you use multiple iterators (or `for`-`in` loops) over a single
/// iterable, be sure you know that the specific iterable supports
/// repeated iteration, either because you know its concrete type or because
/// the iterable is also constrained to the `Collection` protocol.
///
/// Obtain each separate iterator from separate calls to the sequence's
/// `makeIterator()` method rather than by copying. Copying an iterator is
/// safe, but advancing one copy of an iterator by calling its `next()` method
/// may invalidate other copies of that iterator. `for`-`in` loops are safe in
/// this regard.
///
/// Adding IteratorProtocol Conformance to Your Type
/// ================================================
///
/// Implementing an iterator that conforms to `IteratorProtocol` is simple.
/// Declare a `next()` method that advances one step in the related sequence
/// and returns the current element. When the iterable has been exhausted, the
/// `next()` method returns `nil`.
///
/// For example, consider a custom `Countdown` sequence. You can initialize the
/// `Countdown` sequence with a starting integer and then iterate over the
/// count down to zero. The `Countdown` structure's definition is short: It
/// contains only the starting count and the `makeIterator()` method required
/// by the `Iterable` protocol.
///
///     struct Countdown: Sequence {
///         let start: Int
///
///         func makeIterator() -> CountdownIterator {
///             return CountdownIterator(self)
///         }
///     }
///
/// The `makeIterator()` method returns another custom type, an iterator named
/// `CountdownIterator`. The `CountdownIterator` type keeps track of both the
/// `Countdown` sequence that it's iterating and the number of times it has
/// returned a value.
///
///     struct CountdownIterator: IteratorProtocol {
///         let countdown: Countdown
///         var times = 0
///
///         init(_ countdown: Countdown) {
///             self.countdown = countdown
///         }
///
///         mutating func next() -> Int? {
///             let nextNumber = countdown.start - times
///             guard nextNumber > 0
///                 else { return nil }
///
///             times += 1
///             return nextNumber
///         }
///     }
///
/// Each time the `next()` method is called on a `CountdownIterator` instance,
/// it calculates the new next value, checks to see whether it has reached
/// zero, and then returns either the number, or `nil` if the iterator is
/// finished returning elements of the sequence.
///
/// Creating and iterating over a `Countdown` sequence uses a
/// `CountdownIterator` to handle the iteration.
///
///     let threeTwoOne = Countdown(start: 3)
///     for count in threeTwoOne {
///         print("\(count)...")
///     }
///     // Prints "3..."
///     // Prints "2..."
///     // Prints "1..."
public protocol IteratorProtocol : Swift.IteratorProtocol {
    /// The type of element traversed by the iterator.
    associatedtype Element
    
    /// Advances to the next element and returns it, or `nil` if no next element
    /// exists.
    ///
    /// Repeatedly calling this method returns, in order, all the elements of the
    /// underlying sequence. As soon as the sequence has run out of elements, all
    /// subsequent calls return `nil`.
    ///
    /// You must not call this method if any other copy of this iterator has been
    /// advanced with a call to its `next()` method.
    ///
    /// The following example shows how an iterator can be used explicitly to
    /// emulate a `for`-`in` loop. First, retrieve a sequence's iterator, and
    /// then call the iterator's `next()` method until it returns `nil`.
    ///
    ///     let numbers = [2, 3, 5, 7]
    ///     var numbersIterator = numbers.makeIterator()
    ///
    ///     while let num = numbersIterator.next() {
    ///         print(num)
    ///     }
    ///     // Prints "2"
    ///     // Prints "3"
    ///     // Prints "5"
    ///     // Prints "7"
    ///
    /// - Returns: The next element in the underlying sequence, if a next element
    ///   exists; otherwise, `nil`.
    mutating func next() -> Element?
}

/// A type that provides iterated access to its elements.
///
/// An iterable abstractly contains values that you can step through. The
/// most common way to iterate over the elements of a sequence is to use a
/// `for`-`in` loop:
///
///     let oneTwoThree = 1...3
///     for number in oneTwoThree {
///         print(number)
///     }
///     // Prints "1"
///     // Prints "2"
///     // Prints "3"
///
/// While seemingly simple, this capability gives you access to a large number
/// of operations that you can perform on any iterable. As an example, to
/// check whether an iterable includes a particular value, you can test each
/// value sequentially until you've found a match or reached the end of the
/// Iterable's iterator. This example checks to see whether a particular
/// insect is in an array.
///
///     let bugs = ["Aphid", "Bumblebee", "Cicada", "Damselfly", "Earwig"]
///     var hasMosquito = false
///     for bug in bugs {
///         if bug == "Mosquito" {
///             hasMosquito = true
///             break
///         }
///     }
///     print("'bugs' has a mosquito: \(hasMosquito)")
///     // Prints "'bugs' has a mosquito: false"
///
/// The `Iterable` protocol provides default implementations for many common
/// operations that depend on sequential access to a sequence's values. For
/// clearer, more concise code, the example above could use the array's
/// `contains(_:)` method, which performs the iteration for you
/// as every iterable inherits it from `Iterable` instead of iterating manually:
///
///     if bugs.contains("Mosquito") {
///         print("Break out the bug spray.")
///     } else {
///         print("Whew, no mosquitos!")
///     }
///     // Prints "Whew, no mosquitos!"
///
/// Ordered Access
/// ===============
///
/// The `Iterable` protocol makes no requirement on conforming types regarding
/// whether they have a standardized, or even deterministic iteration order.
/// However, it does gaurantee that if it's iterator's `.next()` is caled until
/// it returns `nil` it will return each element exactly once for each time the
/// iterable contains that element. As a consequence, don't assume that whether
/// or not one element preceeds annother is a sensible question. for example, even
/// if a `.copy()` method exists with expected semantics (and Element is Equatable):
///
///     let a, b: type(of: iterable).Element
///
///     for element in iterable.copy() {
///         a = element
///         break
///     }
///
///     for element in iterable {
///         b = element
///         break
///     }
///
///     // No defined behavior
///     if a == b {
///         ...
///     } else {
///         ...
///     }
///
/// In this case, you cannot assume either an iterable is a sequence and the
/// elements will be equal, or that an iterable will have been reordered and
/// the elements will be unequal. A conforming iterable that is
/// not a sequence is allowed to produce elements in an arbitrary order.
///
/// To establish that a type you've created has an iteration order that is
/// preserved by equality, add conformance to the `Sequence` protocol.
///
/// Repeated Access
/// ===============
///
/// The `Iterable` protocol makes no requirement on conforming types regarding
/// whether they will be destructively consumed by iteration. As a
/// consequence, don't assume that multiple `for`-`in` loops on a iterable
/// will either resume iteration or restart from the beginning:
///
///     for element in sequence {
///         if ... some condition { break }
///     }
///
///     for element in sequence {
///         // No defined behavior
///     }
///
/// In this case, you cannot assume either that an iterable will be consumable
/// and will resume iteration, or that an iterable is a collection and will
/// restart iteration from the first element. A conforming iterable that is
/// not a collection is allowed to produce arbitrary elements
/// in the second `for`-`in` loop.
///
/// To establish that a type you've created supports nondestructive iteration,
/// add conformance to a collection protocol.
///
/// Conforming to the Iterable Protocol
/// ===================================
///
/// Making your own custom types conform to `Iterable` enables many useful
/// operations, like `for`-`in` looping and the `contains` method, without
/// much effort. To add `Sequence` conformance to your own custom type, add a
/// `makeIterator()` method that returns an iterator.
///
/// Alternatively, if your type is a sequence and can act as its own iterator,
/// implementing the requirements of the `Sequence` and `IteratorProtocol`
/// protocols are sufficient.
///
/// Here's a definition of a `Countdown` sequence that serves as its own
/// iterator. The `makeIterator()` method is provided as a default
/// implementation.
///
///     struct Countdown: Sequence, IteratorProtocol {
///         var count: Int
///
///         mutating func next() -> Int? {
///             if count == 0 {
///                 return nil
///             } else {
///                 defer { count -= 1 }
///                 return count
///             }
///         }
///     }
///
///     let threeToGo = Countdown(count: 3)
///     for i in threeToGo {
///         print(i)
///     }
///     // Prints "3"
///     // Prints "2"
///     // Prints "1"
///
/// Expected Performance
/// ====================
///
/// An iterable should provide its iterator in O(1). The `Iterable` protocol
/// makes no other requirements about element access.
public protocol Iterable : Swift.Sequence {
    /// A type representing the iterable elements.
    associatedtype Element
    
    /// A type that provides the iterable's iteration interface and
    /// encapsulates its iteration state.
    associatedtype Iterator : IteratorProtocol where Iterator.Element == Element
    
    /// Returns an iterator over the elements of this sequence.
    func makeIterator() -> Iterator
    
    /// A value less than or equal to the number of iterable elements,
    /// calculated nondestructively.
    ///
    /// - Complexity: O(1)
    var underestimatedCount: Int { get }
    
    /// Calls the given closure on each element in the sequence in the same order
    /// as a `for`-`in` loop would.
    ///
    /// The two loops in the following example produce the same output:
    ///
    ///     let numberWords = ["one", "two", "three"]
    ///     for word in numberWords {
    ///         print(word)
    ///     }
    ///     // Prints "one"
    ///     // Prints "two"
    ///     // Prints "three"
    ///
    ///     numberWords.forEach { word in
    ///         print(word)
    ///     }
    ///     // Same as above
    ///
    /// Using the `forEach` method is distinct from a `for`-`in` loop in two
    /// important ways:
    ///
    /// 1. You cannot use a `break` or `continue` statement to exit the current
    ///    call of the `body` closure or skip subsequent calls.
    /// 2. Using the `return` statement in the `body` closure will exit only from
    ///    the current call to `body`, not from any outer scope, and won't skip
    ///    subsequent calls.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a
    ///   parameter.
    func forEach(_ body: (Element) throws -> Void) rethrows
    
    func _customContainsEquatableElement(
        _ element: Element
        ) -> Bool?
    
    /// If `self` is multi-pass (i.e., a `Collection`), invoke `preprocess` and
    /// return its result.  Otherwise, return `nil`.
    func _preprocessingPass<R>(
        _ preprocess: () throws -> R
        ) rethrows -> R?
    
    /// Create a native array buffer containing the elements of `self`,
  /// in the same order as a `for in` loop.
  func _copyToContiguousArray() -> ContiguousArray<Element>

  /// Copy `self` into an unsafe buffer, returning a partially-consumed
  /// iterator with any elements that didn't fit remaining.
  func _copyContents(
    initializing ptr: UnsafeMutableBufferPointer<Element>
  ) -> (Iterator,UnsafeMutableBufferPointer<Element>.Index)
}

//===----------------------------------------------------------------------===//
// Default implementations for Iterable
//===----------------------------------------------------------------------===//

extension Iterable {
    
    /// Returns a value less than or equal to the number of elements in
    /// the sequence, nondestructively.
    ///
    /// - Complexity: O(*n*)
    @_inlineable
    public var underestimatedCount: Int {
        return 0
    }
    
    @_inlineable
    public func _preprocessingPass<R>(
        _ preprocess: () throws -> R
        ) rethrows -> R? {
        return nil
    }
    
    @_inlineable
    public func _customContainsEquatableElement(
        _ element: Iterator.Element
        ) -> Bool? {
        return nil
    }
    
    /// Calls the given closure on each element in the sequence in the same order
    /// as a `for`-`in` loop would (otherwise not defined).
    ///
    /// The two loops in the following example produce the same output:
    ///
    ///     let numberWords = ["one", "two", "three"]
    ///     for word in numberWords {
    ///         print(word)
    ///     }
    ///     // Prints "one"
    ///     // Prints "two"
    ///     // Prints "three"
    ///
    ///     numberWords.forEach { word in
    ///         print(word)
    ///     }
    ///     // Same as above
    ///
    /// Using the `forEach` method is distinct from a `for`-`in` loop in two
    /// important ways:
    ///
    /// 1. You cannot use a `break` or `continue` statement to exit the current
    ///    call of the `body` closure or skip subsequent calls.
    /// 2. Using the `return` statement in the `body` closure will exit only from
    ///    the current call to `body`, not from any outer scope, and won't skip
    ///    subsequent calls.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a
    ///   parameter.
    @_inlineable
    public func forEach(
        _ body: (Element) throws -> Void
        ) rethrows {
        for element in self {
            try body(element)
        }
    }
}

extension Iterable {
    /// Returns an array containing the results of mapping the given closure
  /// over the sequence's elements.
  ///
  /// In this example, `map` is used first to convert the names in the array
  /// to lowercase strings and then to count their characters.
  ///
  ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
  ///     let lowercaseNames = cast.map { $0.lowercased() }
  ///     // 'lowercaseNames' == ["vivien", "marlon", "kim", "karl"]
  ///     let letterCounts = cast.map { $0.count }
  ///     // 'letterCounts' == [6, 6, 3, 4]
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an
  ///   element of this sequence as its parameter and returns a transformed
  ///   value of the same or of a different type.
  /// - Returns: An array containing the transformed elements of this
  ///   sequence.
  @_inlineable
  public func map<T>(
    _ transform: (Element) throws -> T
  ) rethrows -> [T] {
    let initialCapacity = underestimatedCount
    var result = ContiguousArray<T>()
    result.reserveCapacity(initialCapacity)

    var iterator = self.makeIterator()

    // Add elements up to the initial capacity without checking for regrowth.
    for _ in 0..<initialCapacity {
      result.append(try transform(iterator.next()!))
    }
    // Add remaining elements, if any.
    while let element = iterator.next() {
      result.append(try transform(element))
    }
    return Array(result)
  }

  /// Returns an array containing, in `for in` order, the elements of the sequence
  /// that satisfy the given predicate.
  ///
  /// In this example, `filter(_:)` is used to include only names shorter than
  /// five characters.
  ///
  ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
  ///     let shortNames = cast.filter { $0.count < 5 }
  ///     print(shortNames)
  ///     // Prints "["Kim", "Karl"]"
  ///
  /// - Parameter isIncluded: A closure that takes an element of the
  ///   sequence as its argument and returns a Boolean value indicating
  ///   whether the element should be included in the returned array.
  /// - Returns: An array of the elements that `isIncluded` allowed.
  @_inlineable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> [Element] {
    return try _filter(isIncluded)
  }

  @_transparent
  public func _filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> [Element] {

    var result = ContiguousArray<Element>()

    var iterator = self.makeIterator()

    while let element = iterator.next() {
      if try isIncluded(element) {
        result.append(element)
      }
    }

    return Array(result)
  }

  /// Returns a value less than or equal to the number of elements in
  /// the sequence, nondestructively.
  ///
  /// - Complexity: O(*n*)
  @_inlineable
  public var underestimatedCount: Int {
    return 0
  }

  @_inlineable
  public func _preprocessingPass<R>(
    _ preprocess: () throws -> R
  ) rethrows -> R? {
    return nil
  }

  @_inlineable
  public func _customContainsEquatableElement(
    _ element: Iterator.Element
  ) -> Bool? {
    return nil
  }

  /// Calls the given closure on each element in the sequence in the same order
  /// as a `for`-`in` loop.
  ///
  /// The two loops in the following example produce the same output:
  ///
  ///     let numberWords = ["one", "two", "three"]
  ///     for word in numberWords {
  ///         print(word)
  ///     }
  ///     // Prints "one"
  ///     // Prints "two"
  ///     // Prints "three"
  ///
  ///     numberWords.forEach { word in
  ///         print(word)
  ///     }
  ///     // Same as above
  ///
  /// Using the `forEach` method is distinct from a `for`-`in` loop in two
  /// important ways:
  ///
  /// 1. You cannot use a `break` or `continue` statement to exit the current
  ///    call of the `body` closure or skip subsequent calls.
  /// 2. Using the `return` statement in the `body` closure will exit only from
  ///    the current call to `body`, not from any outer scope, and won't skip
  ///    subsequent calls.
  ///
  /// - Parameter body: A closure that takes an element of the sequence as a
  ///   parameter.
  @_inlineable
  public func forEach(
    _ body: (Element) throws -> Void
  ) rethrows {
    for element in self {
      try body(element)
    }
  }
}
}
