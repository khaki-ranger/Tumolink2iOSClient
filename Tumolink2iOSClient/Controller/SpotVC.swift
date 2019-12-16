//
//  SpotVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/13.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SpotVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var slideImageView: UICollectionView!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var yearTxt: UILabel!
    @IBOutlet weak var monthTxt: UILabel!
    @IBOutlet weak var dayTxt: UILabel!
    @IBOutlet weak var dayOfWeekTxt: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Valiables
    var spot: Spot!
    var spotImages = [String]()

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = spot.name
        spotImages = spot.images
        setupNavigation()
        setupCollectionView()
        setupPageControl()
        controlOfNextAndPrev()
        setupDateTxt()
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
    
    private func setupDateTxt() {
        let dayOfWeekStringJp: [Int: String] = [1: "日", 2: "月", 3: "火", 4: "水", 5: "木", 6: "金", 7: "土"]
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let dayOfWeek = calendar.component(.weekday, from: date)
        yearTxt.text = String(year)
        monthTxt.text = String(month)
        dayTxt.text = String(day)
        dayOfWeekTxt.text = dayOfWeekStringJp[dayOfWeek]
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
    
    private func setupNavigation() {
        let editSpotBtn = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(editSpot))
        let deleteSpotBtn = UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(deleteSpot))
        navigationItem.setRightBarButtonItems([editSpotBtn, deleteSpotBtn], animated: false)
    }
    
    @objc func editSpot() {
        performSegue(withIdentifier: Segues.ToEditSpot, sender: self)
    }
    
    @objc func deleteSpot() {
        let alert = UIAlertController(title: "削除", message: "\(spot.name)を削除しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.activityIndicator.startAnimating()
            self.changeIsActionValue()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Firestoreのスポットの値を変更する処理
    private func changeIsActionValue() {
        let docRef = Firestore.firestore().collection(FirestoreCollectionIds.Spots).document(self.spot.id)
        docRef.updateData(["isActive": false], completion: { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "スポットの削除に失敗しました")
                return
            }
            // 値の更新に成功したらホームのトップ画面に遷移する
            self.navigationController?.popToRootViewController(animated: true)
        })
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToEditSpot {
            if let destination = segue.destination as? CreateSpotVC {
                destination.spotToEdit = spot
            }
        }
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
