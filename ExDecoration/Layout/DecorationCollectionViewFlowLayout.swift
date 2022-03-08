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
  private enum Threshold {
    static let cellStartZIndex = 100
    static let decorationStartZIndex = 0
  }
  private var cachedDecorationViewAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
  weak var dataSource: DecorationCollectionViewFlowLayoutDataSource?
  
  override func prepare() {
    super.prepare()
    guard let collectionView = collectionView else { return }
    guard let dataSource = dataSource else { fatalError("Conform DecorationCollectionViewFlowLayoutDataSource") }
    self.cachedDecorationViewAttributes.removeAll()
    
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
          self?.cachedDecorationViewAttributes[indexPath] = attributes
        }
      }
  }
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    // 1. DecorationView가 아닌 것들(Cell)을 획득
    var array = super.layoutAttributesForElements(in: rect)
    guard self.collectionView?.numberOfSections ?? 0 > 0 else { return array }
    
    // 2. DecorationView가 아닌 것
    var cellZIndex = 0
    array?.forEach {
      $0.zIndex = cellZIndex + Threshold.cellStartZIndex
      cellZIndex += 1
    }

    // 3. DecorationView인 것
    var decorationZIndex = 0
    for (_, attributes) in self.cachedDecorationViewAttributes {
      if attributes.frame.intersects(rect){
        attributes.zIndex = decorationZIndex + Threshold.decorationStartZIndex
        array?.append(attributes)
      }
      decorationZIndex += 1
    }
    return array
  }
  override func layoutAttributesForDecorationView(
    ofKind elementKind: String,
    at indexPath: IndexPath
  ) -> UICollectionViewLayoutAttributes? {
    self.cachedDecorationViewAttributes[indexPath]
  }
}
