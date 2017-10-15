//
//  SearchViewController.swift
//  MarvelProject
//
//  Created by tomer on 16/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit
import SDWebImage
import CCBottomRefreshControl
import CoreData

extension UIViewController{
    var searchTypes : [SearchMode] {
        get{
            return [.characters, .comics, .creators, .events, .series]
        }
    }
}

class SearchViewController: UIViewController {
//MARK: - attributes

    var controller = DBManager.manager.fetchSearchHistory()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    var historySearchResultsArray : [SearchHistory] = []
    
    
    @IBOutlet weak var collectionView : UICollectionView!
    var collectionArray : [Item] = []
    
    @IBOutlet weak var backgroundControllerImageView: UIImageView!
    
    @IBOutlet weak var filterViewOutlet: UIView!
    @IBOutlet weak var filterViewConstraintHeight: NSLayoutConstraint!
    var tempfilterViewConstraintHeight : CGFloat = 0
    
    //@IBOutlet weak var companySegmentedOutlet: UISegmentedControl!
    
    @IBOutlet weak var searchFieldPickerOutlet: UIPickerView!
    @IBOutlet weak var filterButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    @IBOutlet weak var searchRefreshControl: UIActivityIndicatorView!
    
    var selectedSearchTypeIndex : Int{
        get{
            return searchFieldPickerOutlet.selectedRow(inComponent: 0)
        }
    }
    
    var isAscending : String{
        get{
            return searchFieldPickerOutlet.selectedRow(inComponent: 2) == 0 ? "" : "-"
        }
    }
    
    var selectedOrderBy : String{
        get{
            return isAscending + searchTypes[selectedSearchTypeIndex].orderBy[pickerOrderByIndex]
        }
    }
    
    var pickerOrderByIndex : Int = 0
    
    var searchName : String?
    weak var refreshControl : UIRefreshControl!
    var page : UInt = 0
    var cellPerRow : Int = 0
    
    var prevOrientation : String = ""
    
    var isMarvel : Bool{
        get{
            //return self.companySegmentedOutlet.selectedSegmentIndex == 0 ? true : false
            return true
        }
    }
    
//MARK: - general methods: viewDidLoad,...
    override func viewDidLoad() {
        
        prevOrientation = getOrientation()
        
        tableViewHeightConstraint.constant = 0
        //for future work
        //companySegmentedAction(companySegmentedOutlet)
        //3 lines needs to be deleted incase of using the segmented controller
        backgroundControllerImageView.image = #imageLiteral(resourceName: "marvelLogoBackground")
        pickerView(searchFieldPickerOutlet, didSelectRow: selectedSearchTypeIndex, inComponent: 0)
        determinSearchPlaceholder()
        
        searchFieldPickerOutlet.dataSource = self
        searchFieldPickerOutlet.delegate = self
        
        tempfilterViewConstraintHeight = filterViewConstraintHeight.constant
        filterViewConstraintHeight.constant = 0
        searchBarOutlet.becomeFirstResponder()
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(control)
        refreshControl = control
        
        let bottomControl = UIRefreshControl()
        bottomControl.addTarget(self, action: #selector(loadNextPage), for: .valueChanged)
        collectionView.bottomRefreshControl = bottomControl
    }
    //for future work
   /* @IBAction func companySegmentedAction(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            backgroundControllerImageView.image = #imageLiteral(resourceName: "marvelLogoBackground")
            pickerView(searchFieldPickerOutlet, didSelectRow: selectedSearchTypeIndex, inComponent: 0)
            determinSearchPlaceholder()
        case 1:
            backgroundControllerImageView.image = #imageLiteral(resourceName: "dcBackgroungLogo")
        default: break
        }
    }*/
    
    
    func determinSearchPlaceholder() {
        searchBarOutlet.placeholder = searchTypes[selectedSearchTypeIndex].placeHolder
    }
    
    @IBAction func filterButtonAction(_ sender: UIBarButtonItem) {
        self.filterViewConstraintHeight.constant = self.filterViewConstraintHeight.constant == 0 ? tempfilterViewConstraintHeight : 0

        UIView.animate(withDuration: 0.7) {
            self.view.layoutIfNeeded()
        }
        
        if !searchBarOutlet.isFirstResponder && self.filterViewConstraintHeight.constant != 0{
            searchBarOutlet.becomeFirstResponder()
        }
        searchFieldPickerOutlet.reloadComponent(1)
        searchFieldPickerOutlet.selectRow(pickerOrderByIndex, inComponent: 1, animated: false)
    }
    
    func loadNextPage(){
        guard let name = searchName else{
            collectionView.bottomRefreshControl?.endRefreshing()
            return
        }
        page += 1
        reload(with: name)
    }
    
    func refresh(){
        guard let name = searchName else{
            refreshControl.endRefreshing()
            return
        }
        page = 0
        reload(with: name)
    }
//MARK: - reload
    func reload(with name : String){
        
        func completion(_ arr : [Item]?, _ err : Error?){
            self.refreshControl.endRefreshing()
            self.collectionView.bottomRefreshControl?.endRefreshing()
            guard let arr = arr else{
                self.searchRefreshControl.stopAnimating()
                print(err?.localizedDescription ?? "Unknown error")
                return
            }
            
            if self.page == 0 {
                self.collectionArray = arr
            }else{
                self.collectionArray += arr
            }
            searchRefreshControl.stopAnimating()
            self.collectionView.reloadData()
        }
        
        let recsPerPage = UInt(collectionView.bounds.width / 100) * 7
        let searchType = searchTypes[selectedSearchTypeIndex]
        MarvelManager.manager.getItems(isMarvel: isMarvel,
                                       startPoint: searchType.startPoint,
                                       type: searchType.type,
                                       defaultParameter: searchType.defaultSearchParameter,
                                       charName: name,
                                       recsPerPage: recsPerPage,
                                       page: page,
                                       orderBy: self.selectedOrderBy,
                                       completion: completion)
    }
    
//MARK: - prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let charVC = segue.destination as? DetailsViewController,
            let cell = sender as? UICollectionViewCell,
            let indexPath = self.collectionView.indexPath(for: cell)
            {
                charVC.sourceSearchMode = searchTypes[selectedSearchTypeIndex]
                charVC.item = collectionArray[indexPath.item]
                charVC.isMarvel = self.isMarvel
        }
    }
    
//MARK: - screen orientation handling
    //gets the current screen orientation
    func getOrientation() -> String{
        let orient = UIDevice.current.orientation.isPortrait
        return orient ? "portrait" : "landscape"
    }
    
    override func viewDidLayoutSubviews() {
        guard let name = self.searchName, !name.isEmpty else {
            return
        }
        //do only if the device was rotated
        if prevOrientation != getOrientation(){
            searchFieldPickerOutlet.reloadComponent(1)
            searchFieldPickerOutlet.selectRow(pickerOrderByIndex, inComponent: 1, animated: false)
            self.reload(with: name)
            prevOrientation = getOrientation()
        }
    }
}
//MARK: - history searches table view
extension SearchViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historySearchResultsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewSearchCell
        cell.configure(with: historySearchResultsArray[indexPath.row].term ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let searchText = historySearchResultsArray[indexPath.row].term
        searchBarOutlet.text = searchText
        historySearchResultsArray = []
        getTableViewHeight()
    }
    
}
//MARK: - items(search results) collection view
extension SearchViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let w = Int(collectionView.bounds.width)
        let c = w / 100
        let s = 100 + (w % 100) / c
        
        return CGSize(width: s, height: s)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemCell
        
        cell.configure(with: collectionArray[indexPath.item])
        
        cell.viewWithTag(2)?.layer.cornerRadius = 10
        
        cell.layer.shadowOffset = CGSize(width: 5, height: 4)
        cell.layer.shadowColor = UIColor.black.withAlphaComponent(0.9).cgColor
        cell.layer.shadowOpacity = 1
        return cell
    }
}
//MARK: - handeling the search bar
extension SearchViewController : UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if filterViewConstraintHeight.constant > 0{
            filterButtonAction(filterButtonOutlet)
        }
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchName = nil
        historySearchResultsArray = []
        getTableViewHeight()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if filterViewConstraintHeight.constant > 0{
            filterButtonAction(filterButtonOutlet)
        }
        searchBar.resignFirstResponder()

        guard let name = searchBar.text, !name.isEmpty else{
            return
        }
        storeSearchToDB(name)
        searchName = name
        page = 0
        historySearchResultsArray = []
        getTableViewHeight()
        searchRefreshControl.startAnimating()
        reload(with: name)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        controller = DBManager.manager.fetchSearchHistory(filter: searchText)
        
        if !searchText.isEmpty{
            guard let arr = controller.fetchedObjects else {
                return
            }
            historySearchResultsArray = arr
        }else{
            historySearchResultsArray = []
        }
        getTableViewHeight()
    }
    
    fileprivate func getTableViewHeight(){
        let tableViewHeight = CGFloat(historySearchResultsArray.count * 25)
        tableViewHeightConstraint.constant = tableViewHeight < 150 ? tableViewHeight : 150
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        tableView.reloadData()
    }
    
    fileprivate func storeSearchToDB(_ searchTerm : String){
        
        controller = DBManager.manager.fetchSearchHistory(filter: searchTerm)
        guard let arr = controller.fetchedObjects else {
            return
        }
        historySearchResultsArray = arr
        
        for searchItem in historySearchResultsArray{
            if searchItem.term == searchTerm{
                return
            }
        }
        let item = SearchHistory(context: DBManager.manager.context)
        item.term = searchTerm

        DBManager.manager.saveContext()
    }
}

//MARK: - Picker
extension SearchViewController : UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 2{
            return 2
        }
        return component == 0 ? searchTypes.count : searchTypes[pickerView.selectedRow(inComponent: 0)].orderBy.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var size = pickerView.rowSize(forComponent: component)
        var point = CGPoint(x: 0, y: 0)
        
        let view = UIView(frame: CGRect(origin: point, size: size))
        
        size.height -= 1
        size.width -= 1
        point.x = 1
        let label = UILabel(frame: CGRect(origin: point, size: size))
        
        switch component {
        case 0:
            label.text = searchTypes[row].description
        case 1:
            label.text = searchTypes[pickerView.selectedRow(inComponent: 0)].orderByDescription[row]
        case 2:
            label.text = row == 0 ? "Ascending" : "Descending"
        default: break
        }

        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        view.addSubview(label)
        
        size.height = 1
        size.width -= 10
        point.x = 5
        
        let sview = UIView(frame: CGRect(origin:  point, size: size))
        
        sview.backgroundColor = .white
        view.addSubview(sview)
        
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: false)
        }
        pickerOrderByIndex = pickerView.selectedRow(inComponent: 1)
        determinSearchPlaceholder()
    }
}
