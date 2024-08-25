import UIKit

extension EditingTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.layer.cornerRadius = 10
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.separatorColor = .ypGray
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = tableViewRows[indexPath.row]
        cell.backgroundColor = .ypBackground
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .ypGray
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = tracker?.category?.header
        } else {
            cell.detailTextLabel?.text = tracker?.schedule
        }
        
        let disclosureImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        disclosureImage.image = UIImage(named: "chevron")
        cell.accessoryView = disclosureImage
        
        if indexPath.row == tableViewRows.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewModel = CategoryViewModel()
            let viewController = CategoryViewController(viewModel: viewModel)
            viewModel.view = viewController
            goToCategoryVC(viewController)
            
            viewModel.updateCategory = { [weak self] categoryName in
                guard let self,
                      let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = categoryName
                self.chosenCategory = categoryName
                print("chosenCategory \(chosenCategory)")
            }
        } else {
            goToScheduleVC()
        }
        isCreateButtonEnable()
    }
    
    private func goToCategoryVC(_ viewController: UIViewController) {
        let navVC = UINavigationController(rootViewController: viewController)
        present(navVC, animated: true)
    }
    
    private func goToScheduleVC() {
        let viewController = ScheduleViewController()
        self.present(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
