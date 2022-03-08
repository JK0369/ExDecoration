//
//  DecorationCollectionViewFlowLayout.swift
//  ExDecoration
//
//  Created by Jake.K on 2022/03/08.
//

import UIKit

protocol DecorationCollectionViewFlowLayoutDataSource: AnyObject {
  /// cellSize
  func collectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
}

final class DecorationCollectionViewFlowLayout: UICollectionViewFlowLayout {
  private let numberOfColumns: Int
  private let maximumWidth: CGFloat
  private let cellSpacing: CGFloat
  private let backgroundMargin: CGFloat
  private var cachedAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
  weak var dataSource: DecorationCollectionViewFlowLayoutDataSource?
  
  init(numberOfColumns: Int, maximumWidth: CGFloat, cellSpacing: CGFloat, backgroundMargin: CGFloat) {
    self.numberOfColumns = numberOfColumns
    self.maximumWidth = maximumWidth
    self.cellSpacing = cellSpacing
    self.backgroundMargin = backgroundMargin
    super.init()
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func prepare() {
    super.prepare()
    guard let collectionView = collectionView else { return }
    guard let dataSource = self.dataSource else { fatalError("Confirm DecorationCollectionViewFlowLayoutDataSource") }
    self.cachedAttributes.removeAll()
    self.minimumLineSpacing = self.cellSpacing
    self.minimumInteritemSpacing = self.cellSpacing
    
    // 1. DecorationView 등록
    self.register(BackgroundDecorationView.self, forDecorationViewOfKind: BackgroundDecorationView.id)
    
    var originX = 0.0
    var originY = 0.0
    let numberOfsections = collectionView.numberOfSections
    
    (0..<numberOfsections)
      .map { section in return (collectionView.numberOfItems(inSection: section), section) }
      .forEach { (numberOfItems, section) in
        (0..<numberOfItems)
          .forEach { [weak self] item in
            guard let ss = self else { return }
            let indexPath = IndexPath(item: item, section: section)
            let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: BackgroundDecorationView.id, with: indexPath)

            let cellSize = dataSource.collectionView(collectionView, indexPath: indexPath)
            let nextOriginX = originX + cellSize.width + (ss.cellSpacing * 2)
            let nextOriginY = originY + cellSize.height + (ss.cellSpacing * 2)
            if nextOriginX + cellSize.width > ss.maximumWidth {
              originX = 0
              originY = nextOriginY
            } else {
              originX = nextOriginX
            }
            attributes.frame = CGRect(
              x: originX,
              y: originY,
              width: cellSize.width + ss.backgroundMargin,
              height: cellSize.height + ss.backgroundMargin
            )
            
            ss.cachedAttributes[indexPath] = attributes
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
