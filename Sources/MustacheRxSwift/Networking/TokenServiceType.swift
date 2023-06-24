//
// Created by Tommy Hinrichsen on 2019-05-01.
//

import Foundation
import MustacheServices
import RxSwift

public protocol TokenServiceType {

    func updateToken() -> Observable<Void>

}
