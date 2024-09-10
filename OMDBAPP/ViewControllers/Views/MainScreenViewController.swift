//
//  MainScreenViewController.swift
//  OMDBAPP
//
//  Created by Equipp on 09/09/24.
//

import UIKit

class MainScreenViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var movies: [Movie] = []
    var currentPage: Int = 1
    var isLoading: Bool = false
    var hasMoreData: Bool = true
    
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter movie name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let typePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let pickerData = ["All", "Movie", "Series"]
    var selectedType: String = "All"
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "OMDB APP"
        
        view.addSubview(searchTextField)
        searchTextField.delegate = self
       
        view.addSubview(searchButton)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        view.addSubview(typePicker)
        typePicker.delegate = self
        typePicker.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
          
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 40),
           
            typePicker.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
            typePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typePicker.widthAnchor.constraint(equalToConstant: 150),
            typePicker.heightAnchor.constraint(equalToConstant: 100),
           
            searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 32),
            searchButton.leadingAnchor.constraint(equalTo: typePicker.trailingAnchor, constant: 50),
            searchButton.heightAnchor.constraint(equalToConstant: 44),
            searchButton.widthAnchor.constraint(equalToConstant: 120),
            
            collectionView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func searchButtonTapped() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            print("Search text is empty")
            return
        }
       
        currentPage = 1
        hasMoreData = true
        fetchMovies(searchText: searchText, page: currentPage)
    }
    
    private func fetchMovies(searchText: String, page: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        MovieDataManager.shared.fetchMovies(byName: searchText, type: selectedType, page: page) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let movies):
                    if movies.isEmpty {
                        self?.hasMoreData = false
                    } else {
                        if page == 1 {
                            self?.movies = movies
                        } else {
                            self?.movies.append(contentsOf: movies)
                        }
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    print("Error fetching movies: \(error)")
                }
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - scrollViewHeight * 2 {
            guard hasMoreData else { return }
            currentPage += 1
            if let searchText = searchTextField.text, !searchText.isEmpty {
                fetchMovies(searchText: searchText, page: currentPage)
            }
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = pickerData[row]
        print("Selected type: \(selectedType)")
        searchButtonTapped()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Unable to dequeue MovieCollectionViewCell")
        }
        
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: width, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.item]
        
        let movieDetailVC = MovieDetailViewController(movieTitle: selectedMovie.title)
        
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}
