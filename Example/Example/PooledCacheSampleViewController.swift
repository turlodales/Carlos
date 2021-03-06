import Foundation
import UIKit

import Carlos
import Combine

final class PooledCacheSampleViewController: BaseCacheViewController {
  private var cache: PoolCache<BasicCache<URL, NSData>>!
  private var cancellables = Set<AnyCancellable>()

  override func fetchRequested() {
    super.fetchRequested()
    let timestamp = Date().timeIntervalSince1970
    eventsLogView.text = "\(eventsLogView.text!)Request timestamp: \(timestamp)\n"
    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in
        self.eventsLogView.text = "\(self.eventsLogView.text!)Request with timestamp \(timestamp) succeeded\n"
      }).store(in: &cancellables)
  }

  override func titleForScreen() -> String {
    "Pooled cache"
  }

  override func setupCache() {
    super.setupCache()

    cache = delayedNetworkCache().pooled()
  }
}
