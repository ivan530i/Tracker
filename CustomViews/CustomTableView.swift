import UIKit

final class CustomTableView: UITableView {
    
    weak var tableViewDelegate: CustomTableViewDelegate?
    
    var viewModel: CategoryViewModelProtocol? {
        didSet {
            reloadData()
        }
    }
    
    var didSelectHandler: ( (IndexPath) -> () )?
    
    init(tableViewDelegate: CustomTableViewDelegate? = nil, viewModel: CategoryViewModelProtocol? = nil) {
        super.init(frame: .zero, style: .plain)
        self.tableViewDelegate = tableViewDelegate
        self.viewModel = viewModel
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        tableHeaderView = UIView()
        tableFooterView = UIView()
        separatorStyle = .singleLine
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        dataSource = self
        delegate = self
        register(CustomCategoryCell.self, forCellReuseIdentifier: CustomCategoryCell.identifier)
        rowHeight = CGFloat(75)
    }
    
    func setupLayout(_ view: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

extension CustomTableView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getCategoryCount() ?? 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CustomCategoryCell.identifier, for: indexPath)
                as? CustomCategoryCell else {
            return UITableViewCell()
        }
        
        guard let cellViewModel = viewModel?.getCategoryName(indexPath) else {
            return UITableViewCell()
        }
        
        cell.configureCell(viewModelCategories: cellViewModel)
        checkChosenFilter(cell)
        return cell
    }
    
    private func checkChosenFilter(_ cell: CustomCategoryCell) {
        let selectedFilter = viewModel?.getSelectedFilter()
        if selectedFilter == cell.titleLabel.text {
            cell.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
        cell.selectionStyle = .none
        cell.checkmarkImage.isHidden = false
        viewModel?.categoryCellSelected(cell: cell)
        viewModel?.sendSelectedFilterToStore(indexPath)
        tableViewDelegate?.didSelectCategory()
        didSelectHandler?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
        cell.checkmarkImage.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let radius = CGFloat(16)
        let categoryCount = viewModel?.getCategoryCount() ?? 0
        
        if numberOfRows == 1 {
            cell.layer.cornerRadius = radius
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return
        }
        
        switch indexPath.row {
        case 0:
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = tableView.separatorInset
        case categoryCount - 1:
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        default:
            cell.layer.cornerRadius = 0
            cell.separatorInset = tableView.separatorInset
        }
    }
}
