//
//  Music.swift
//  CoreKnowledge
//
//  Created by Onurcan Sever on 2022-01-16.
//

import Foundation
import UIKit

class Music {
    private var id: Int
    private var name: String
    private var image: UIImage?
    private var path: String?
    
    init(id: Int, name: String, image: UIImage?, path: String?) {
        self.id = id
        self.name = name
        self.image = image
        self.path = path
    }
    
    public func getMusicName() -> String {
        return self.name
    }
    
    public func getCurrentPath() -> String? {
        return self.path
    }
    
    public func getMusicImage() -> UIImage? {
        return self.image
    }
    
}
