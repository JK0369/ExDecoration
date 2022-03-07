//
//  ColumnFlowLayout.swift
//  ExDecoration
//
//  Created by Jake.K on 2022/03/08.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
  
  private let minColumnWidth: CGFloat = 300.0
  private let cellHeight: CGFloat = 70.0
  
  private var deletingIndexPaths = [IndexPath]()
  private var insertingIndexPaths = [IndexPath]()
  
  // MARK: Layout Overrides
  
  override func prepare() {
    super.prepare()
    self.register(BackgroundDecorationView.self, forDecorationViewOfKind: BackgroundDecorationView.id)
    guard let collectionView = collectionView else { return }
    
    let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
    let maxNumColumns = Int(availableWidth / minColumnWidth)
    let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
    
    self.itemSize = CGSize(width: cellWidth, height: cellHeight)
    self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
    self.sectionInsetReference = .fromSafeArea
  }
  
  override func layoutAttributesForDecorationView(
    ofKind elementKind: String,
    at indexPath: IndexPath
  ) -> UICollectionViewLayoutAttributes? {
    super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    attributes.frame = CGRect(x: 0, y: 0, width: 120, height: 300)
    return attributes
  }
}

class DecorationFlow: UICollectionViewFlowLayout {
  private var cache = [IndexPath: UICollectionViewLayoutAttributes]()
  
  override func prepare() {
    super.prepare()
    self.cache.removeAll()
    self.register(BackgroundDecorationView.self, forDecorationViewOfKind: BackgroundDecorationView.id)
    let originX = 15.0
    let widH = UIScreen.main.bounds.width - originX * 2
    guard let collectionView = collectionView else{ return }
    let sections = collectionView.numberOfSections
    var originY = 0.0
    for sect in 0..<sections{
      let sectionFirst = IndexPath(item: 0, section: sect)
      let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: BackgroundDecorationView.id, with: sectionFirst)
      let itemCount = collectionView.numberOfItems(inSection: sect)
      originY = originY + 80
      let h: CGFloat = 50 * CGFloat(itemCount)
      attributes.frame = CGRect(x: originX, y: originY, width: widH, height: h)
      originY = originY + h + 15
      self.cache[sectionFirst] = attributes
    }
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
  override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath]
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var array = super.layoutAttributesForElements(in: rect)
    guard let collection = collectionView, collection.numberOfSections > 0 else{
      return array
    }
    var z = 0
    array?.forEach({
      $0.zIndex = z + 100
      z += 1
    })
    z = 0
    for (_, attributes) in cache {
      
      if attributes.frame.intersects(rect){
        attributes.zIndex = z + 10
        array?.append(attributes)
      }
      z += 1
    }
    return array
  }
}
