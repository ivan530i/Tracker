import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    private lazy var categoryTableView: UITableView = {
        let table = UITableView()
        table.tableHeaderView = UIView()
        table.tableFooterView = UIView()
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.dataSource = self
        table.delegate = self
        table.register(CustomCategoryCell.self, forCellReuseIdentifier: CustomCategoryCell.identifier)
        return table
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "stubIMG"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно \nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dataManager = CoreDataManager.shared
    private var categories = [String]()
    private let rowHeight = CGFloat(75)
    
    var updateCategory: ( (String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getCategoriesFromCD()
    }
    
    @objc private func createCategoryButtonTapped() {
        let createCategoryVC = CreateCategoryVC()
        let navVC = UINavigationController(rootViewController: createCategoryVC)
        
        createCategoryVC.updateCategory = { [weak self] in
            self?.getCategoriesFromCD()
            self?.categoryTableView.reloadData()
        }
        
        present(navVC, animated: true)
    }
    
    private func getCategoriesFromCD() {
        let listOfCategories = dataManager.getCategoriesFromCoreData()
        categories = [String]()
        listOfCategories.forEach { cat in
            guard let catName = cat.header else { return }
            categories.append(catName)
        }
        print(categories)
        showOrHidePlaceholder()
    }
    
    private func setupUI() {
        setupNavigationController()
        view.backgroundColor = .ypWhite
        view.addSubViews([categoryTableView, createCategoryButton, placeholderImageView, placeholderLabel])
        applyConstraints()
    }
    
    private func setupNavigationController() {
        title = "Категория"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor, constant: -20),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            
            createCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func sendLastChosenCategoryToStore(cell: CustomCategoryCell) {
        guard let categoryNameToPass = cell.titleLabel.text else {
            print("Oooops"); return }
        dataManager.sendLastChosenCategoryToStore(categoryName: categoryNameToPass)
        updateCategory?(categoryNameToPass)
    }
}

extension CategoryViewController {
    func showOrHidePlaceholder() {
        if categories.isEmpty {
            showPlaceholder()
        } else {
            hidePlaceholder()
        }
    }
    
    private func showPlaceholder() {
        
        placeholderImageView.isHidden = false
        placeholderLabel.isHidden = false
        
        let emptyScreenStack = UIStackView()
        emptyScreenStack.axis = .vertical
        emptyScreenStack.spacing = 8
        emptyScreenStack.alignment = .center
        
        [placeholderImageView, placeholderLabel].forEach { emptyScreenStack.addArrangedSubview($0) }
        
        view.addSubViews([emptyScreenStack])
        
        NSLayoutConstraint.activate([
            emptyScreenStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func hidePlaceholder() {
        placeholderImageView.isHidden = true
        placeholderLabel.isHidden = true
    }
}

extension CategoryViewController: CreateCategoryDelegate {
    func didCreateCategory(_ category: String) {
        dismiss(animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CustomCategoryCell.identifier, for: indexPath)
                as? CustomCategoryCell else { print("We have problems with cell")
            return UITableViewCell()
        }
        let cellViewModel = categories[indexPath.row]
        cell.configureCell(viewModelCategories: cellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
        cell.selectionStyle = .none
        cell.checkmarkImage.isHidden = false
        sendLastChosenCategoryToStore(cell: cell)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
        cell.checkmarkImage.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let radius: CGFloat = 16
        
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
        case categories.count - 1:
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        default:
            cell.layer.cornerRadius = 0
            cell.separatorInset = tableView.separatorInset
        }
    }
}
