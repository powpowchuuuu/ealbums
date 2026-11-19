import Foundation
import Observation

/// Which music service the add sheet searches, kept between launches.
@Observable
final class ServiceStore {
    var service: MusicService {
        didSet { service.save(in: defaults) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
        service = MusicService.saved(in: defaults)
    }
}
