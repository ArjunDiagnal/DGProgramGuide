//
//  DGGuide.swift
//  
//
//  Created by Arjun Santhosh on 28/01/25.
//

import UIKit

public class DGGuide: UIView {
    
    private var collectionView: UICollectionView
    private let playerView = UIView()
    
    // Sample data
       private let items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    override init(frame: CGRect) {
        
        // Set up a UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        // Set item size (height = 50, width = full parent width)
        layout.itemSize = CGSize(width: frame.size.width, height: 50)
        
        // Initialize UICollectionView with the layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        super.init(frame: frame) // Now that collectionView is initialized, call super.init
        
        collectionView.dataSource = self
        
        // Register a cell class for the collection view
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        setupView() // Now we can call setupView() after initialization
    }
    
    required init?(coder: NSCoder) {
        // Set up a UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        // Set item size (height = 50, width = full parent width)
        layout.itemSize = CGSize(width: 320, height: 50) // Width should be a constant if you're using the coder initializer
        
        // Initialize UICollectionView with the layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        super.init(coder: coder) // Now that collectionView is initialized, call super.init
        
        collectionView.dataSource = self
        
        // Register a cell class for the collection view
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        setupView() // Now we can call setupView() after initialization
    }
    
    private func setupView() {
        
        // Add and configure the black subview
        playerView.backgroundColor = .black
        playerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playerView)
        
        // Add constraints to position the black subview
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: topAnchor),
            playerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            playerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3) // 30% height
        ])
        
        // Set background color for the custom view
        backgroundColor = .white
        
        // Set up collection view
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register a cell class for the collection view
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // Add collection view to the view
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints
        
        // Add constraints for restView
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor) // Covers remaining height
        ])
        
    }}

extension DGGuide: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Selected item UICollectionViewDelegate : \(items[indexPath.item])")
    }
    
}

extension DGGuide: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .systemBlue
        
        // Add a label to the cell
        let label = UILabel()
        label.text = items[indexPath.item]
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Clear previous subviews before adding new ones
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(label)
        
        // Center the label in the cell
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
    
}

extension DGGuide: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100) // Customize item size if needed
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item: \(items[indexPath.item])")
    }
}
