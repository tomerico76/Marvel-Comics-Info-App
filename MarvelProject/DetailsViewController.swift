//
//  CharacterViewController.swift
//  MarvelProject
//
//  Created by tomer on 20/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit
import SDWebImage
import SKPhotoBrowser

class DetailsViewController: UIViewController {
//MARK: - outlets, parameters,...
    var sourceSearchMode : SearchMode = .characters
    var item : Item!
    var isMarvel : Bool = true
    var tableArray : [Item] = []
    var URLsTableArray : [URL] = []
    
    var detaisSearchTypeIndex = 0
    var previousHighlightedCell : DetailsCell? = nil
    
    @IBOutlet weak var bottomBgImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    
    @IBOutlet weak var generalViewHeitghtLayout: NSLayoutConstraint!
    @IBOutlet weak var generalViewTopConstraint: NSLayoutConstraint!
    var tempGeneralViewTopConstraint : CGFloat = 0
    
    @IBOutlet weak var generalViewForImageView: UIView!
    @IBOutlet weak var generalImageViewOutlet: UIImageView!
    @IBOutlet weak var generalFormatLabelOutlet: UILabel!
    @IBOutlet weak var generalRatingLabelOutlet: UILabel!
    @IBOutlet weak var generalPagesLabelOutlet: UILabel!
    @IBOutlet weak var generalStartLabelOutlet: UILabel!
    @IBOutlet weak var generalEndLabelOutlet: UILabel!
    @IBOutlet weak var generalPreviousLabelOutlet: UILabel!
    @IBOutlet weak var generalNextLabelOutlet: UILabel!
    
    @IBOutlet weak var orderBySegmenOutlet: UISegmentedControl!
    @IBOutlet weak var orderByHeightLayoutConstraint: NSLayoutConstraint!
    var tVOrderAscending : Bool = true
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var cllectionViewHeightLayuot: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewHeightLayout: NSLayoutConstraint!
    var tempTextViewHeightLayout : CGFloat!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navBarTitleLabel: UILabel!
    
    var defaultTop : CGFloat = 0
    var defaultOffset : CGFloat = 0
    
    @IBOutlet weak var generalRefreshControl: UIActivityIndicatorView!
    
    weak var refreshControl : UIRefreshControl!
    var page : UInt = 0

    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var bottomDetailsView: UIView!
    
    var portraitConstraints : [NSLayoutConstraint] = []
    var landscapeConstraints : [NSLayoutConstraint] = []
    var previousOrientation : Bool = true
    
//MARK: - Checking for internet connection
    var isInternet : Bool{
        get{
            let reachability : Reachability = Reachability.forInternetConnection()
            return reachability.currentReachabilityStatus() == NotReachable ? false : true
        }
    }

//MARK: - general methods: viewDidLoad,...
    override func viewDidLoad(){
        super.viewDidLoad()
        previousOrientation = isPortrait()
        portraitConstraints = [
            NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: detailsView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomDetailsView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomDetailsView, attribute: .top, relatedBy: .equal, toItem: detailsView, attribute: .bottom, multiplier: 1, constant: 0)]
        
        landscapeConstraints = [
            NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: detailsView, attribute: .trailing, multiplier: 2, constant: 0),
            NSLayoutConstraint(item: bottomDetailsView, attribute: .leading, relatedBy: .equal, toItem: detailsView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomDetailsView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)]
        
        
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        control.tintColor = .white
        tableView.addSubview(control)
        refreshControl = control
        
        let bottomControl = UIRefreshControl()
        bottomControl.addTarget(self, action: #selector(loadNextPage), for: .valueChanged)
        bottomControl.tintColor = .white
        tableView.bottomRefreshControl = bottomControl
        
        tempGeneralViewTopConstraint = generalViewTopConstraint.constant
        tempTextViewHeightLayout = textViewHeightLayout.constant
        
        orderBySegmenOutlet.layer.cornerRadius = 5
        
        reloadPage()
    }
    
    func reloadPage(){

        bgImageView.sd_setImage(with: item.thumbnailURL, placeholderImage: #imageLiteral(resourceName: "marvelLogoBackground"))
        
        if item.isMarvel{
            bottomBgImageView.image = #imageLiteral(resourceName: "marvelLogoBackground")
        } else{
            bottomBgImageView.image = #imageLiteral(resourceName: "dcBackgroungLogo")
        }
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        descTextView.text = item.desc
        
        generalImageViewOutlet.sd_setImage(with: item.thumbnailURL, placeholderImage: #imageLiteral(resourceName: "marvelLogoBackground"))
        generalImageViewOutlet.layer.cornerRadius = 10
        
        generalViewForImageView.layer.cornerRadius = 10
        generalViewForImageView.layer.shadowOffset = CGSize(width: 5, height: 5)
        generalViewForImageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.9).cgColor
        generalViewForImageView.layer.shadowOpacity = 1
        
        generalFormatLabelOutlet.text = item.format
        generalRatingLabelOutlet.text = item.rating
        generalPagesLabelOutlet.text = item.pageCount
        if let start = item.start?.dateString{
            generalStartLabelOutlet.text = "Start: " + start
        }else{
            if let start = item.startYear{
                generalStartLabelOutlet.text = start
            }else{
                generalStartLabelOutlet.text = "Start: N/A"
            }
        }
        
        if let end = item.end?.dateString{
            generalEndLabelOutlet.text = "End: " + end
        }else{
            if let end = item.endYear{
                generalEndLabelOutlet.text = end
            }else{
                generalEndLabelOutlet.text = "End: N/A"
            }
        }
        
        generalPreviousLabelOutlet.text = item.previousName
        generalNextLabelOutlet.text = item.nextName

        defaultTop = tempGeneralViewTopConstraint
        
        if isPortrait(){
            defaultOffset = generalViewHeitghtLayout.constant + cllectionViewHeightLayuot.constant + collectionViewTopConstraint.constant
            
            tableView.contentInset = UIEdgeInsets(top: defaultOffset, left: 0, bottom: 0, right: 0)
            
            tableView.contentOffset.y = defaultOffset * -1
        }else{
            defaultOffset = cllectionViewHeightLayuot.constant + collectionViewTopConstraint.constant
            tableView.contentInset = UIEdgeInsets(top: defaultOffset, left: 0, bottom: 0, right: 0)
            
            tableView.contentOffset.y = defaultOffset * -1
        }
        navBarTitleLabel.text = item.name
        getUrls()
    }
    
    func getUrls(){
        MarvelManager.manager.getUrlsFor(charID: self.item.id.description,
                                         startPoint: sourceSearchMode.endPoint,
                                         recsPerPage: 20, page: 0)
        { (arr, err) in
            self.choosingTable(self.collectionViewOutlet)
            if let err = err{
                print(err.localizedDescription)
                return
            }
            
            self.URLsTableArray = arr
        }
    }
    
    func reload(with endPoint : String){
    
        let recsPerPage = UInt(20)
        if !tableArray.isEmpty && page == 0{
            tableArray = []
            tableView.reloadData()
        }
        generalRefreshControl.startAnimating()
        
        MarvelManager.manager.getDetailsFor(isMarvel: isMarvel,
                                            charID: item.id.description,
                                            startPoint: sourceSearchMode.startPoint,
                                            type: sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].type,
                                            endPoint: endPoint,
                                            recsPerPage: recsPerPage,
                                            page: page,
                                            orderBy: self.getOrderByParam())
        { (arr, err, type) in
            
            guard let arr = arr else{
                self.refreshControl.endRefreshing()
                self.tableView.bottomRefreshControl?.endRefreshing()
                self.generalRefreshControl.stopAnimating()
                print(err?.localizedDescription ?? "Unknown error")
                return
            }
            if type == self.sourceSearchMode.detailsAvailableSearchModes[self.detaisSearchTypeIndex].type {
                if self.page == 0 {
                    self.tableArray = arr
                }else{
                    self.tableArray += arr
                }
            }
            self.refreshControl.endRefreshing()
            self.tableView.bottomRefreshControl?.endRefreshing()
            self.generalRefreshControl.stopAnimating()
            
            self.tableView.reloadData()
        }
    }
    
    func loadNextPage(){
        page += 1
        reload(with: sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].endPoint)
    }
    
    func refresh(){
        if page == 0{
            refreshControl.endRefreshing()
            return
        }
        page = 0
        reload(with: sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].endPoint)
    }
    
//MARK: - methods for constraints(portrait, landscape)
    
    func isPortrait() -> Bool{
        return UIDevice.current.orientation.isPortrait
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateViewConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if isPortrait(){
            self.view.removeConstraints(landscapeConstraints)
            self.view.addConstraints(portraitConstraints)
            if isPortrait() != previousOrientation{
                defaultOffset = generalViewHeitghtLayout.constant + cllectionViewHeightLayuot.constant + collectionViewTopConstraint.constant
                tableView.contentInset = UIEdgeInsets(top: defaultOffset, left: 0, bottom: 0, right: 0)
                tableView.contentOffset.y = defaultOffset * -1
            }
        }else{
            self.view.removeConstraints(portraitConstraints)
            self.view.addConstraints(landscapeConstraints)
            defaultOffset = cllectionViewHeightLayuot.constant + collectionViewTopConstraint.constant
            tableView.contentInset = UIEdgeInsets(top: defaultOffset, left: 0, bottom: 0, right: 0)
            tableView.contentOffset.y = defaultOffset * -1
        }
        previousOrientation = isPortrait()
    }
    
//MARK: - order by segment action + tap gesture
    
    @IBAction func orderByTapGestureAction(_ sender: UITapGestureRecognizer) {
        let t = orderBySegmenOutlet.bounds.width / CGFloat(orderBySegmenOutlet.numberOfSegments)
        let cIndex : Int = sender.location(in: orderBySegmenOutlet).x <= t ? 0 : 1
        if cIndex == orderBySegmenOutlet.selectedSegmentIndex{
            tVOrderAscending = !tVOrderAscending
        }else{
            orderBySegmenOutlet.selectedSegmentIndex = cIndex
            tVOrderAscending = true
        }
        orderBySegmenOutlet.setTitle(getArrow(index: cIndex), forSegmentAt: cIndex)
        
        reload(with: sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].endPoint)
    }
    
    private func getOrderByParam() -> String{
        let result = sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].orderBy[orderBySegmenOutlet.selectedSegmentIndex]
        
        return tVOrderAscending ? result : "-" + result
    }
    
//MARK: - image tap gesture action
    @IBAction func imageTapGesturAction(_ sender: UITapGestureRecognizer) {
        
        //let reachability : Reachability = Reachability.forInternetConnection()
        if !isInternet{
            "The Internet connection appears to be offline.".toast()
            return
        }
        let browser = SKPhotoBrowser(photos: item.images)
        self.present(browser, animated: true, completion: nil)
        
    }
   
//MARK: - labels(previous & next) gesture actions
    
    @IBAction func previousLabelTapGestureAction(_ sender: UITapGestureRecognizer) {
        
        guard let url = item.previousUrl else {
            return
        }
        getNextOrPrevData(url: url)
    }
    
    @IBAction func nextLabelTapGestureAction(_ sender: UITapGestureRecognizer) {
        guard let url = item.nextUrl else {
            return
        }
        getNextOrPrevData(url: url)
    }
    
    private func getNextOrPrevData(url : String){
        MarvelManager.manager.getDetailsFor(isMarvel: item.isMarvel,
                                            charID: "",
                                            startPoint: url,
                                            type: sourceSearchMode.type,
                                            endPoint: "",
                                            recsPerPage: 20,
                                            page: 0,
                                            orderBy: "")
        { (arr, err, type) in
            
            guard let arr = arr else{
                print(err?.localizedDescription ?? "Unknown error")
                return
            }
            self.item = arr[0]
            self.reloadPage()
        }

    }
}

//MARK: - table view delegate and dataSource
extension DetailsViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex] != .urls{
            return tableArray.count
        }else{
            return URLsTableArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TableViewDetailsCell
        cell.configure(with: tableArray[indexPath.row])
        if sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex] == .urls{
            cell.accessoryType = .disclosureIndicator
        }
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex] == .urls{
            if !isInternet{
                "The Internet connection appears to be offline.".toast()
                return
            }
            let itemUrl : URL = URLsTableArray[indexPath.row]
            
            let webVC = WebViewController.webViewController()
            
            webVC.name = self.item.name
            webVC.url = itemUrl
            
            navigationController?.show(webVC, sender: nil)
        }else{
            let item = tableArray[indexPath.row]
            self.item = item
            self.sourceSearchMode = sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex]
            self.detaisSearchTypeIndex = 0
            self.isMarvel = item.isMarvel
            page = 0
            collectionViewOutlet.contentOffset.x = 0
            collectionViewOutlet.reloadData()
            reloadPage()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var y = tableView.contentOffset.y
        y = min(y, 0)
        let delta = max(abs(defaultOffset - (cllectionViewHeightLayuot.constant + orderByHeightLayoutConstraint.constant)) - abs(y), 0)
        if isPortrait(){
            generalViewTopConstraint.constant = defaultTop - delta
        }else{
            generalViewTopConstraint.constant = tempGeneralViewTopConstraint
        }
    }
}

//MARK: - collection view data source, delegate, flow layout
extension DetailsViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = Int(collectionView.bounds.height)
        let w = 100
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceSearchMode.detailsAvailableSearchModes.count + 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailsCell

        if indexPath.row == 0 || indexPath.row == sourceSearchMode.detailsAvailableSearchModes.count + 1{
            cell.configure(with: "")
            if indexPath.row == 0{
                (cell.viewWithTag(4) as? UIImageView)?.image = #imageLiteral(resourceName: "swipeLeft")
            }else{
                (cell.viewWithTag(4) as? UIImageView)?.image = #imageLiteral(resourceName: "swipeRight")
            }
        }else{
            if indexPath.row <= sourceSearchMode.detailsAvailableSearchModes.count{
                cell.configure(with: sourceSearchMode.detailsAvailableSearchModes[indexPath.row-1].description)
            }else{
                cell.configure(with: sourceSearchMode.detailsAvailableSearchModes[indexPath.row-2].description)
            }
            (cell.viewWithTag(4) as? UIImageView)?.image = nil
        }
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate{
            choosingTable(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        choosingTable(scrollView)
    }
    
    func choosingTable(_ scrollView: UIScrollView){
        guard let colV = scrollView as? UICollectionView else{
            return
        }
        let point = CGPoint(x: scrollView.contentOffset.x + 150, y: scrollView.contentOffset.y)
        
        if let indexPath = collectionViewOutlet.indexPathForItem(at: point){
            
            if let preCell = previousHighlightedCell{
                preCell.backgroundColor = .white
            }
            
            var ip : IndexPath = indexPath
            if indexPath.row == 0{
                ip.row = 1
            }
            
            if indexPath.row == colV.numberOfItems(inSection: 0){
                ip.row = indexPath.row - 1
            }
            
            let cell = colV.cellForItem(at: ip) as! DetailsCell
            cell.backgroundColor = .lightGray
            previousHighlightedCell = cell
            detaisSearchTypeIndex = ip.row - 1
            page = 0
            if ip.row == sourceSearchMode.detailsAvailableSearchModes.count{
                //purchases doesn't have sort
                self.orderBySegmenOutlet.isHidden = true
                self.tableView.reloadData()
            }else{
                self.orderBySegmenOutlet.isHidden = false
                self.orderBySegmenOutlet.removeAllSegments()
                tVOrderAscending = true
                for seg in 0..<sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].orderBy.count{
                        orderBySegmenOutlet.insertSegment(withTitle: getArrow(index: seg), at: seg, animated: false)
                    }
                
                orderBySegmenOutlet.selectedSegmentIndex = 0
                reload(with: sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].endPoint)
            }
        }
    }
    
    fileprivate func getArrow(index : Int) -> String{
        switch tVOrderAscending {
        case true:
            return sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].orderByDescription[index] + " ⬆︎"
        case false:
            return sourceSearchMode.detailsAvailableSearchModes[detaisSearchTypeIndex].orderByDescription[index] + " ⬇︎"
        }
    }
}
