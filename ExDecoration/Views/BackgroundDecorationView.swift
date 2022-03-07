//
//  BackgroundDecorationView.swift
//  ExDecorationView
//
//  Created by Jake.K on 2022/03/07.
//

import UIKit
import SnapKit

final class BackgroundDecorationView: UICollectionReusableView {
  static let id = "BackgroundDecorationView"
  static var kind: String { Self.id }
  
  override var reuseIdentifier: String? {
    Self.id
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.3)
    view.layer.cornerRadius = 8.0
    view.layer.masksToBounds = true
    view.layer.borderColor = UIColor.clear.cgColor
    view.layer.borderWidth = 1.0
    self.addSubview(view)
    view.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.size.equalTo(50).priority(999)
    }
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
  }
  override func prepareForReuse() {
    super.prepareForReuse()
    self.prepare()
  }
  
  func prepare() {
    
  }
}

