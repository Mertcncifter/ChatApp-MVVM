//
//  ChatViewController.swift
//  ChatApp
//
//  Created by mert can çifter on 19.04.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import JGProgressHUD
import SDWebImage
import AVFoundation
import AVKit



class ChatViewController: MessagesViewController {

    // MARK: - Properties
    
    private var viewModel : ChatViewModelProtocol!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        
        guard let email = UserDefaults.email else {
            return nil
        }
        
        return Sender(photoUrl: "", senderId: email.safeEmail, displayName: "Me")
    }
    

    // MARK: - Lifecycle
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMessageCollectionView()
        setupInputButton()
        
        viewModel.delegate = self
        viewModel.load()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()

    }
    
    // MARK: - Helpers
    
    private func setupMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
    }
    
    
    private func configureSpinner(state: Bool) {
        if state {
            spinner.show(in: view)
        }
        else {
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
        }
    }
    
}

// MARK: - ConfigureInputButton

extension ChatViewController {
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default,handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default,handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default,handler: { [weak self] _ in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach a photo from?", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default,handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default,handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
                
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        
        present(actionSheet, animated: true)

    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where would you like to attach a video from?", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default,handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default,handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)
        }))
                
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        
        present(actionSheet, animated: true)

    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true,completion: nil)
        
        
        guard let selfSender = self.selfSender else {
            return
        }
        
        if let image = info[.editedImage] as? UIImage,
           let imageData = image.pngData() {
            viewModel.sendPhotoMessage(imageData: imageData, selfSender: selfSender, title: self.title ?? "")
        }
        else if let videoUrl = info[.mediaURL] as? URL {
            print("DEBUG \(videoUrl)")
            viewModel.sendVideoMessage(url: videoUrl, selfSender: selfSender, title: self.title ?? "")
        }
        
    }
}



// MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfsender = self.selfSender else {
            return
        }
               
        viewModel.sendMessage(selfSender: selfsender, text: text, title: self.title ?? "")
       
    }
}


// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("Self sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl,completed: nil)
        default:
            break
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            return .link
        }
        
        return .secondarySystemBackground
    }
}


// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
           
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc,animated: true)
        default:
            break
        }
    }
}

// MARK: - ChatViewModelDelegate


extension ChatViewController: ChatViewModelDelegate {
    func handleViewModelOutput(_ output: ChatViewModelOutput) {
        switch output {
        case .setLoading(let state):
            configureSpinner(state: state)
        case .error(let error):
            break
        case .clearInputBar:
            self.messageInputBar.inputTextView.text = nil
        case .showMessageList(let messages):
            self.messages = messages
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
    }
    
    func navigate(to route: ChatViewRoute) {
        
    }
}
