//
//  File.swift
//  
//
//  Created by Arjun Santhosh on 06/02/25.
//

import UIKit

public class UIConfig {
    public static let shared = UIConfig()  // Now accessible globally
    
    // View Properties
    public var backgroundColor: UIColor = .white
    public var cornerRadius: CGFloat = 10.0
    public var borderWidth: CGFloat = 1.0
    public var borderColor: UIColor = .gray
    
    private init() {} // Prevent external instantiation
}
