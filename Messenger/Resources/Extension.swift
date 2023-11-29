//
//  Extension.swift
//  Messenger
//
//  Created by Arslan Raza on 22/11/2023.
//

import Foundation
import UIKit

extension UIView {
    
    public var width: CGFloat {
        return self.frame.width
    }
    
    public var height: CGFloat {
        return self.frame.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat {
        return self.frame.size.width + self.frame.origin.y
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
}
