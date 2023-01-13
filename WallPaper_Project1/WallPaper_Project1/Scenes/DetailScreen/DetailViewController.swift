//
//  DetailViewController.swift
//  WallPaper_Project1
//
//  Created by DuyThai on 10/01/2023.
//

import UIKit

final class DetailViewController: UIViewController {
    @IBOutlet private weak var downloadButton: UIButton!
    @IBOutlet private weak var detailImageView: UIImageView!
    @IBOutlet private weak var arrowTriangleImageView: UIImageView!
    @IBOutlet private weak var authorNameLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var informationView: UIView!
    @IBOutlet private weak var colorImageLabel: UILabel!
    @IBOutlet private weak var bottomButtonViewContainer: UIView!
    @IBOutlet private weak var topButtonViewContainer: UIView!
    @IBOutlet private weak var imageIdLabel: UILabel!
    @IBOutlet private weak var heightImageLabel: UILabel!
    @IBOutlet private weak var widthImageLabel: UILabel!
    private let apiCaller = APICaller.shared
    private var imageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    private func configView() {
        informationView.isHidden = true
        arrowTriangleImageView.isHidden = true
        downloadButton.layer.cornerRadius = 20
        informationView.layer.cornerRadius = 12
        bottomButtonViewContainer.setGradientBackground(colorTop: UIColor.clear.cgColor,
                                                        colorBottom: UIColor.black.cgColor)
        topButtonViewContainer.setGradientBackground(colorTop: UIColor.black.cgColor,
                                                     colorBottom: UIColor.clear.cgColor)
    }

    @IBAction private func downloadButtonTapped(_ sender: Any) {
        let waitingLoadingViewController = WaitingLoadingViewController(nibName: "WaitingLoadingViewController",
                                        bundle: nil)
        waitingLoadingViewController.updateView(status: true)
        waitingLoadingViewController.modalPresentationStyle = .fullScreen
       present(waitingLoadingViewController, animated: true)
        if let imageData = imageData {
            if let imageDownload = UIImage(data: imageData) {
                DispatchQueue.global().async {
                    UIImageWriteToSavedPhotosAlbum(imageDownload, nil, nil, nil)
                }
                waitingLoadingViewController.updateView(status: false)
            }
        }
    }

    @IBAction private func infomationButtonTapped(_ sender: Any) {
        informationView.isHidden = !informationView.isHidden
        arrowTriangleImageView.isHidden = !arrowTriangleImageView.isHidden
    }

    @IBAction private func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

    func setLoadBackGroundColor(color: UIColor) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.detailImageView?.setImageColor(color: color)
        }
    }

    private func showPopUp(notice: String) {
        let popUpView = PopUpViewController(nibName: "PopUpViewController", bundle: nil)
        popUpView.bindData(notice: notice)
        addChild(popUpView)
        view.addSubview(popUpView.view)
    }

    func bindData(image: Image ) {
        apiCaller.getImage(imageURL: image.source.portrait) { [weak self] (data, error)  in
            guard let self = self else { return }
            if let error = error {
                self.showPopUp(notice: "\(error)")
            }
            if let data = data {
                self.imageData = data
                DispatchQueue.main.async {
                    self.detailImageView.image = UIImage(data: data)
                }
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateView(image: image)
        }
    }

    private func updateView(image: Image) {
        authorNameLabel.text = image.photographer
        heightImageLabel.text = "Height: \(image.height)"
        widthImageLabel.text = "Width: \(image.width)"
        imageIdLabel.text = "Id: \(image.id)"
        colorImageLabel.text = "Color: \(image.avgColor)"
    }
}
