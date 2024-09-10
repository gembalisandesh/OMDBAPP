//
//  MovieDetailViewController.swift
//  OMDBAPP
//
//  Created by Equipp on 09/09/24.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    let movieTitle: String
    private var movie: Movie?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plotLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    init(movieTitle: String) {
        self.movieTitle = movieTitle
        super.init(nibName: nil, bundle: nil)
        fetchMovieDetails()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        if let movie = movie {
            updateUI(with: movie)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(ratingView)
        ratingView.addSubview(ratingLabel)
        contentView.addSubview(plotLabel)
        contentView.addSubview(detailsStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            posterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            yearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            ratingView.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor),
            ratingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ratingView.widthAnchor.constraint(equalToConstant: 50),
            ratingView.heightAnchor.constraint(equalToConstant: 24),
            
            ratingLabel.centerXAnchor.constraint(equalTo: ratingView.centerXAnchor),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            
            plotLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 16),
            plotLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            plotLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            detailsStackView.topAnchor.constraint(equalTo: plotLabel.bottomAnchor, constant: 16),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func fetchMovieDetails() {
        MovieDataManager.shared.fetchMovieDetails(byTitle: movieTitle) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movie):
                    self?.movie = movie
                    if self?.isViewLoaded == true {
                        self?.updateUI(with: movie)
                    }
                case .failure(let error):
                    print("Failed to fetch movie details: \(error.localizedDescription)")
                }
            }
        }
    }
   
    private func updateUI(with movie: Movie) {
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        ratingLabel.text = movie.imdbRating
        plotLabel.text = movie.plot
        
        if let url = URL(string: movie.poster) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.posterImageView.image = image
                    }
                }
            }.resume()
        }
       
        detailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        addSection(title: "General Information", details: [
            ("Rated", movie.rated ?? "N/A"),
            ("Released", movie.released ?? "N/A"),
            ("Runtime", movie.runtime ?? "N/A"),
            ("Genre", movie.genre ?? "N/A"),
            ("Type", movie.type)
        ])
        
        addSection(title: "Production", details: [
            ("Director", movie.director ?? "N/A"),
            ("Writer", movie.writer ?? "N/A"),
            ("Actors", movie.actors ?? "N/A"),
            ("Production", movie.production ?? "N/A"),
            ("Country", movie.country ?? "N/A"),
            ("Language", movie.language ?? "N/A")
        ])
        
        addSection(title: "Ratings", details: [
            ("IMDb Rating", movie.imdbRating ?? "N/A"),
            ("IMDb Votes", movie.imdbVotes ?? "N/A"),
            ("Metascore", movie.metascore ?? "N/A")
        ])
        
        if let ratings = movie.ratings {
            var ratingDetails: [(String, String?)] = []
            for rating in ratings {
                ratingDetails.append((rating.source, rating.value))
            }
            addSection(title: "Other Ratings", details: ratingDetails)
        }
        
        addSection(title: "Additional Information", details: [
            ("Awards", movie.awards ?? "N/A"),
            ("Box Office", movie.boxOffice ?? "N/A"),
            ("DVD", movie.dvd ?? "N/A"),
            ("Website", movie.website ?? "N/A")
        ])
    }
    
    private func addSection(title: String, details: [(String, String?)]) {
        let sectionTitleLabel = UILabel()
        sectionTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        sectionTitleLabel.text = title
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let sectionStackView = UIStackView()
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 8
        sectionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (key, value) in details {
            let detailLabel = UILabel()
            detailLabel.font = UIFont.systemFont(ofSize: 16)
            detailLabel.text = "\(key): \(value ?? "N/A")"
            sectionStackView.addArrangedSubview(detailLabel)
        }
        
        detailsStackView.addArrangedSubview(sectionTitleLabel)
        detailsStackView.addArrangedSubview(sectionStackView)
    }
}
