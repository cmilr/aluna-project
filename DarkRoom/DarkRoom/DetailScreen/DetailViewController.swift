//
//  DetailViewController.swift
//  DarkRoom
//
//  Created by Cary Miller on 2/14/19.
//  Copyright © 2019 C.Miller & Co. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

   @IBOutlet weak var titleLabel: UILabel!
   @IBOutlet weak var ratingsLabel: UILabel!
   @IBOutlet weak var genreLabel: UILabel!
   @IBOutlet weak var overviewTextView: UITextView!
   @IBOutlet weak var posterImageView: UIImageView!
   @IBOutlet weak var backButtonImageView: UIImageView!
    
   var movie = Movie()
   var imageCache = [String: UIImage?]()

   override func viewDidLoad() {
      super.viewDidLoad()
      setTitleLabel()
      setRating()
      setGenres()
      setPoster()
      configureBackButton()
      NotificationCenter.default.addObserver(
         self,
         selector: #selector(willEnterBackground),
         name: UIApplication.willResignActiveNotification,
         object: nil
      )
   }

   override func viewDidLayoutSubviews() {
      configureGradient()
      setOverview()
   }

   @objc func willEnterBackground() {
      dismiss(animated: false, completion: nil)
   }

   private func setTitleLabel() {
      titleLabel.text = movie.title
   }

   private func setRating() {
      if let rawAverage = movie.voteAverage {
         let average = (rawAverage / 2).rounded()
         let ratingString = String( Array(repeating: "★", count: Int(average)) )
         ratingsLabel.text = ratingString
      }
   }

   private func setGenres() {
      if let genres = movie.genreIDs {
         var genreString = ""
         for genre in genres {
            if let genreTitle = genreDict[genre] {
               genreString += "\(genreTitle), "
            }
         }
         genreString = String(genreString.dropLast(2))
         genreLabel.text = genreString
      }
   }

   private func setOverview() {
      if let overview = movie.overview {

         // Configure font size and line spacing.
         var fontSize: CGFloat
         var lineSpacing: CGFloat

         if UIScreen.main.bounds.height >= DeviceHeight.iPhoneX {
            fontSize = 22
            lineSpacing = 14
         } else {
            fontSize = 18
            lineSpacing = 10
         }

         // Configure font style.
         let font = "System Font Regular"
         let fontColor = UIColor.white

         // Configure paragraph style.
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.lineSpacing = lineSpacing
         paragraphStyle.alignment = .left
         paragraphStyle.lineBreakMode = .byWordWrapping

         // Apply font and paragraph styles.
         let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont(name: font, size: fontSize)!,
            NSAttributedString.Key.foregroundColor: fontColor
         ]
         overviewTextView.attributedText = NSAttributedString(string: overview , attributes: attributes)

         overviewTextView.indicatorStyle = .white
         overviewTextView.setContentOffset(CGPoint.zero, animated: false)
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.overviewTextView.flashScrollIndicators()
         }
      }
   }

   private func setPoster() {
      posterImageView.layer.masksToBounds = false
      posterImageView.layer.shadowColor = UIColor.black.cgColor
      posterImageView.layer.shadowOpacity = 0.7
      posterImageView.layer.shadowOffset = CGSize(width: 7, height: 7)
      posterImageView.layer.shadowRadius = 10

      guard let urlString = movie.composedPosterPath else {
         return
      }
      if let cachedImage = imageCache[urlString] {
         posterImageView.image = cachedImage
      } else {
         NetworkManager.shared.imageFrom(urlString) { (image, error) in
            guard error == nil else {
               print(error!)
               return
            }
            self.imageCache[urlString] = image
            DispatchQueue.main.async { [] in
               self.posterImageView.transition(toImage: image)
            }
         }
      }
   }

   private func configureGradient() {
      if let colorOne = UIColor(named: "moviePurple")?.cgColor,
         let colorTwo = UIColor(named: "movieDarkPurple")?.cgColor {
         let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [colorOne, colorTwo], type: .axial)
         gradient.frame = view.bounds
         view.layer.insertSublayer(gradient, at: 0)
      }
   }

   private func configureBackButton() {
      backButtonImageView.tintColorDidChange()
   }

   @IBAction func dismissViewController(_ sender: Any) {
      dismiss(animated: true, completion: nil)
   }
}
