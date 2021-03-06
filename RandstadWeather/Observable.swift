//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/7/16.
//  Copyright © 2016 Randstad. All rights reserved.
//

import Foundation

class Observable<T> {
  typealias Observer = (T) -> Void
  var observer: Observer?
  
  func observe(_ observer: Observer?) {
    self.observer = observer
    observer?(value)
  }
  
  var value: T {
    didSet {
      observer?(value)
    }
  }
  
  init(_ v: T) {
    value = v
  }
}
