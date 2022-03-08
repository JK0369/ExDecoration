//
//  DecorationCollectionViewFlowLayout.swift
//  ExDecoration
//
//  Created by Jake.K on 2022/03/08.
//

import UIKit

protocol DecorationCollectionViewFlowLayoutDataSource: AnyObject {
  func getDecorationViewRect(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGRect
}

final class DecorationCollectionViewFlowLayout: UICollectionViewFlowLayout {
  private var cachedAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
  weak var dataSource: DecorationCollectionViewFlowLayoutDataSource?
  
  override func prepare() {
    super.prepare()
    guard let collectionView = collectionView else { return }
    guard let dataSource = dataSource else { fatalError("Conform DecorationCollectionViewFlowLayoutDataSource") }
    self.cachedAttributes.removeAll()
    
    // 1. DecorationView 등록
    self.register(BackgroundDecorationView.self, forDecorationViewOfKind: BackgroundDecorationView.id)
    
    // 2. [Section, [Item]]
    let numberOfItemsListForSection = (0..<collectionView.numberOfSections)
      .map { section in return (section, collectionView.numberOfItems(inSection: section)) }
      .map { ($0, (0..<$1).map { $0 }) }
    
    numberOfItemsListForSection
      .forEach { (section, itemList) in
        itemList.forEach { [weak self] item in
          let indexPath = IndexPath(item: item, section: section)
          let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: BackgroundDecorationView.id, with: indexPath)
          attributes.frame = dataSource.getDecorationViewRect(collectionView, indexPath: indexPath)
          self?.cachedAttributes[indexPath] = attributes
        }
      }
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
    for (_, attributes) in self.cachedAttributes {
      if attributes.frame.intersects(rect){
        attributes.zIndex = z + 10
        array?.append(attributes)
      }
      z += 1
    }
    return array
  }
  override func layoutAttributesForDecorationView(
    ofKind elementKind: String,
    at indexPath: IndexPath
  ) -> UICollectionViewLayoutAttributes? {
    self.cachedAttributes[indexPath]
  }
}
