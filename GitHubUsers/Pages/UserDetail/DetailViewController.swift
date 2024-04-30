//
//  DetailViewController.swift
//  GitHubUsers
//
//  Created by Alvin on 2024/4/30.
//

import UIKit
import Combine

fileprivate enum DetailViewControllerConstants {
    enum Strings {
        static let personPlaceholderImage = "person.fill"
    }
    
    enum Numbers {
        static let avatarCornerRadius: CGFloat = 75
    }
}

class DetailViewController: UIViewController {
    
    fileprivate typealias Constants = DetailViewControllerConstants

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var siteAdminBadge: UIButton!
    @IBOutlet weak var loginStack: UIStackView!
    
    @IBOutlet weak var locationStack: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var linkStack: UIView!
    @IBOutlet weak var blogTextView: UITextView!
    
    @IBAction func closeButtonTap(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func saveButtonTap(_ sender: UIButton) {
        _ = viewModel.updateUser()
    }
    
    @IBOutlet weak var saveButton: UIButton!
    
    var viewModel: DetailViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelOutputs()
        _ = viewModel.fetchUser()
        locationStack.isHidden = true
        loginStack.isHidden = true
        avatarImageView.layer.cornerRadius = Constants.Numbers.avatarCornerRadius
        avatarImageView.clipsToBounds = true
        nameTextField.delegate = self
        blogTextView.delegate = self
    }
    
    private func bindViewModelOutputs() {
        let viewModelOutput = viewModel.bindOutput()
        
        viewModelOutput.$user
            .sink { [weak self] user in
                self?.configure(with: user)
            }
            .store(in: &cancellables)
        
        viewModelOutput.showError
            .sink { [weak self] errorMessage in
                self?.showAlert(with: errorMessage)
            }
            .store(in: &cancellables)
        
        viewModelOutput.showSuccess
            .sink { [weak self] _ in
                self?.showAlert(with: "Save Successful")
            }
            .store(in: &cancellables)
    }

    
    func configure(with user: GitHubUser) {
        nameTextField.text = user.name
        bioLabel.text = user.bio
        
        siteAdminBadge.isHidden = !user.siteAdmin
        
        if let url = URL(string: user.avatarURL) {
            avatarImageView.af.setImage(withURL: url, placeholderImage: UIImage(systemName: Constants.Strings.personPlaceholderImage))
        }
        
        loginLabel.text = user.login
        loginStack.isHidden = false
        
        if let location = user.location, !location.isEmpty {
            locationLabel.text = location
            locationStack.isHidden = false
        } else {
            locationStack.isHidden = true
        }
        
        if let blog = user.blog, !blog.isEmpty {
            let attributedString = NSAttributedString(string: blog, attributes: [.link: blog])
            blogTextView.attributedText = attributedString
            linkStack.isHidden = false
        } else {
            linkStack.isHidden = true
        }
    }
    
    private func showAlert(with message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {  [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
}

extension DetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        saveButton.isEnabled = !newText.isEmpty
        return true
    }
}

extension DetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
