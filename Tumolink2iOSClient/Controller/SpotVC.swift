//
//  SpotVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/13.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class SpotVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var slideImageView: UICollectionView!
    @IBOutlet weak var ownerNameTxt: UILabel!
    @IBOutlet weak var ownerImg: CircleImageView!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var yearTxt: UILabel!
    @IBOutlet weak var monthTxt: UILabel!
    @IBOutlet weak var dayTxt: UILabel!
    @IBOutlet weak var dayOfWeekTxt: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTumoliBtn: CircleShadowButtonView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    // MARK: Valiables
    var spot: Spot!
    var spotImages = [String]()
    var isOwner = false
    var tumolis = [Tumoli]()
    var db: Firestore!
    var listener: ListenerRegistration!
    var tumoliToEdit: Tumoli?

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

        navigationItem.title = spot.name
        spotImages = spot.images
        setupCollectionView()
        setupOwnerImg()
        setupPageControl()
        controlOfNextAndPrev()
        setupDateTxt(date: Date())
        setupTableView()
        
        // ログイン中のユーザーがこのスポットのオーナーかどうかを判定
        if spot.owner == UserService.user.id {
            isOwner = true
            setupNavigation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearAllTumolis()
        setTumoliListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        clearAllTumolis()
    }
    
    private func clearAllTumolis() {
        tumolis.removeAll()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.TumoliCell, bundle: nil), forCellReuseIdentifier: Identifiers.TumoliCell)
    }
    
    // ツモリテーブルに表示されるセルのデータを制御するメソッド
    private func setTumoliListener() {
        let ref = db.tumolis(spotId: spot.id)
        listener = ref.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "ツモリのデータの取得に失敗しました")
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let tumoli = Tumoli.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, tumoli: tumoli)
                case .modified:
                    self.onDocumentModified(change: change, tumoli: tumoli)
                case .removed:
                    self.onDocumentRemoved(change: change)
                @unknown default:
                    return
                }
            })
            
            // ログインユーザーのツモリがあるかどうかを確認する
            snap?.documents.forEach({ (document) in
                let data = document.data()
                let tumoli = Tumoli.init(data: data)
                if tumoli.userId == UserService.user.id {
                    self.tumoliToEdit = tumoli
                }
            })
            
            if self.tumoliToEdit == nil {
                self.appearTumoliBtnWithAnimasion()
            } else {
                self.disappearTumoliBtn()
            }
        })
    }
    
    func appearTumoliBtnWithAnimasion() {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            self.addTumoliBtn.alpha = 1.0
        }, completion: nil)
        changeTableHeight(margin: 140)
    }
    
    func disappearTumoliBtn() {
        addTumoliBtn.alpha = 0.0
        changeTableHeight(margin: 36)
    }
    
    private func changeTableHeight(margin: CGFloat) {
        tableHeight.constant = tableView.contentSize.height + margin
    }
    
    private func setupCollectionView() {
        slideImageView.delegate = self
        slideImageView.dataSource = self
        slideImageView.register(UINib(nibName: Identifiers.SpotImageCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.SpotImageCell)
    }
    
    // オーナーのUser情報を取得して表示させるためのメソッド
    private func setupOwnerImg() {
        let docRef = Firestore.firestore().collection(FirestoreCollectionIds.Users).document(spot.owner)
        docRef.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "オーナー情報の取得に失敗しました")
                return
            }
            
            guard let data = snap?.data() else { return }
            let owner = User.init(data: data)
            
            self.ownerNameTxt.text = owner.username
            
            if let url = URL(string: owner.imageUrl) {
                let placeholder = UIImage(named: AppImages.Placeholder)
                let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
                self.ownerImg.kf.indicatorType = .activity
                self.ownerImg.kf.setImage(with: url, placeholder: placeholder, options: options)
            }
        })
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = spotImages.count
        pageControl.currentPage = 0
    }
    
    private func setupDateTxt(date: Date) {
        let dayOfWeekStringJp: [Int: String] = [1: "日", 2: "月", 3: "火", 4: "水", 5: "木", 6: "金", 7: "土"]
        let date = date
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
        let manageSpotBtn = UIBarButtonItem(title: "管理", style: .plain, target: self, action: #selector(manageSpot))
        navigationItem.setRightBarButton(manageSpotBtn, animated: false)
    }
    
    @objc func manageSpot() {
        if isOwner {
            performSegue(withIdentifier: Segues.ToManageSpot, sender: self)
        } else {
            simpleAlert(title: "エラー", msg: "オーナーだけがスポットの管理が可能です")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToManageSpot {
            if let destination = segue.destination as? ManageSpotVC {
                destination.spot = spot
            }
        }
    }
    
    // MARK: Actions
    @IBAction func addTumoliClicked(_ sender: Any) {
        appearAddTumoliVC()
    }
    
    private func appearAddTumoliVC() {
        let vc = AddTumoliVC()
        vc.spot = spot
        vc.tumoliToEdit = tumoliToEdit
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
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

extension SpotVC : UITableViewDelegate, UITableViewDataSource {
    
    // データベースの変更に対して実行されるメソッド - begin
    private func onDocumentAdded(change: DocumentChange, tumoli: Tumoli) {
        let newIndex = Int(change.newIndex)
        tumolis.insert(tumoli, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
    }
    
    private func onDocumentModified(change: DocumentChange, tumoli: Tumoli) {
        if change.newIndex == change.oldIndex {
            // Row change, but remained in the same position
            let index = Int(change.newIndex)
            tumolis[index] = tumoli
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            // Row changed and changed position
            let newIndex = Int(change.newIndex)
            let oldIndex = Int(change.oldIndex)
            tumolis.remove(at: oldIndex)
            tumolis.insert(tumoli, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
            tableView.reloadRows(at: [IndexPath(row: newIndex, section: 0)], with: .none)
        }
    }
    
    private func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        tumolis.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .left)
    }
    // データベースの変更に対して実行されるメソッド - end
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tumolis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TumoliCell, for: indexPath) as? TumoliCell {
            cell.configureCell(tumoli: tumolis[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = tumolis[indexPath.row]
        if selectedRow.userId == UserService.user.id {
            appearAddTumoliVC()
        }
        
        // セルの選択解除
        // タップしても反応しない現象を避ける
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
