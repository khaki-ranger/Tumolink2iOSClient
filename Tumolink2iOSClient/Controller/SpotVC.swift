//
//  SpotVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/13.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit

class SpotVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var slideImageView: UICollectionView!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: Valiables
    var spot: Spot!
    var spotImages = [String]()

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = spot.name
        spotImages = spot.images
        setupCollectionView()
        setupPageControl()
        controlOfNextAndPrev()
    }
    
    private func setupCollectionView() {
        slideImageView.delegate = self
        slideImageView.dataSource = self
        slideImageView.register(UINib(nibName: Identifiers.SpotImageCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.SpotImageCell)
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = spotImages.count
        pageControl.currentPage = 0
    }
    
    // nextボタンとprevボタンの表示非表示を制御するメソッド
    private func controlOfNextAndPrev() {
        if spotImages.count > 1 {
            switch pageControl.currentPage {
            case 0:
                nextBtn.isHidden = false
                prevBtn.isHidden = true
            case spotImages.count - 1:
                nextBtn.isHidden = true
                prevBtn.isHidden = false
            default:
                nextBtn.isHidden = false
                prevBtn.isHidden = false
            }
        } else {
            nextBtn.isHidden = true
            prevBtn.isHidden = true
        }
    }
    
    // MARK: Actions
    @IBAction func prevTapped(_ sender: Any) {
        let prev = max(0, pageControl.currentPage - 1)
        let index = IndexPath(item: prev, section: 0)
        pageControl.currentPage = prev
        slideImageView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        controlOfNextAndPrev()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        let next = min(pageControl.currentPage + 1, spotImages.count - 1)
        let index = IndexPath(item: next, section: 0)
        pageControl.currentPage = next
        slideImageView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        controlOfNextAndPrev()
    }
}

extension SpotVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spotImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = slideImageView.dequeueReusableCell(withReuseIdentifier: Identifiers.SpotImageCell, for: indexPath) as? SpotImageCell {
            cell.configureCell(imageUrl: spotImages[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    // セルのサイズを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = view.frame.width
        let cellHeight = cellWidth * 0.5625
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // scrollの位置とpageControlのページを合わせるためのメソッド
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        let index = Int(x / view.frame.width)
        pageControl.currentPage = index
        controlOfNextAndPrev()
    }
}
