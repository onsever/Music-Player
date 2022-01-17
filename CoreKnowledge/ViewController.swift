//
//  ViewController.swift
//  CoreKnowledge
//
//  Created by Onurcan Sever on 2022-01-16.
//

import UIKit
import AVFoundation
// TODO: Implement a Tap Gesture to the Slider. (We don't want to force user to slide, he / she can tap on the Slider to change it's current value.)
class ViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var musicTimeLabel: UILabel!
    @IBOutlet weak var musicTableView: UITableView!
    @IBOutlet weak var playButton: UIButton!
    
    private var musics = [Music]()
    private var player = AVAudioPlayer()
    private var timer = Timer()
    private var randomMusic: String = ""
    private var selectedRow: Int = 0
    
    // MARK: - View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        defaultMusicSelectedWhenViewLoads()
        imageViewGesture()
        sliderIsTapped()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        highlightTableViewRow(index: 0)
    }
    
    // MARK: - Shake Motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if event?.subtype == .motionShake {
            
            var selectedMusicIndex: Int = 0
            
            randomMusic = self.musics.randomElement()?.getCurrentPath()! ?? "bach"
            playAudio(for: randomMusic)
            
            for i in 0..<musics.count {
                if randomMusic == musics[i].getCurrentPath() {
                    selectedMusicIndex = i
                    break
                }
            }
            
            highlightTableViewRow(index: selectedMusicIndex)
            
            guard let image = self.musics[selectedMusicIndex].getMusicImage() else {
                self.musicImageView.image = nil
                return
            }
            
            musicImageView.image = image
            
            print("Shake action detected!")
            
        }
    }
    
    // MARK: - IBActions
    @IBAction func musicSliderPressed(_ sender: UISlider) {
        player.currentTime = TimeInterval(sender.value)
    }
    
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        resetAll()
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        musicSlider.value = Float(player.currentTime)
        
        if player.isPlaying {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
            timer.invalidate()
        }
        else {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(configureTimer), userInfo: nil, repeats: true)
        }
        
    }
    
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = musics[indexPath.row].getMusicName()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resetAll()
        
        playAudio(for: self.musics[indexPath.row].getCurrentPath()!)
        
        guard let image = musics[indexPath.row].getMusicImage() else {
            self.musicImageView.image = nil
            return
        }
        
        self.musicImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animate(withDuration: 1) {
            self.musicImageView.image = image
            self.musicImageView.transform = .identity
        }
        
    }
    
}

// MARK: - Helper Methods
extension ViewController {
    private func getMusicList() -> [Music] {
        var musicList = [Music]()
        musicList.append(Music(id: 1, name: "Bach", image: UIImage(named: "havana"), path: getPath(name: "bach")))
        musicList.append(Music(id: 2, name: "Boing", image: UIImage(named: "avamax"), path: getPath(name: "boing")))
        musicList.append(Music(id: 3, name: "Explosion", image: nil, path: getPath(name: "explosion")))
        musicList.append(Music(id: 4, name: "Hit", image: nil, path: getPath(name: "hit")))
        musicList.append(Music(id: 5, name: "Knife", image: nil, path: getPath(name: "knife")))
        musicList.append(Music(id: 6, name: "Shoot", image: nil, path: getPath(name: "shoot")))
        musicList.append(Music(id: 7, name: "Swish", image: nil, path: getPath(name: "swish")))
        musicList.append(Music(id: 8, name: "Wah", image: nil, path: getPath(name: "wah")))
        musicList.append(Music(id: 9, name: "Warble", image: nil, path: getPath(name: "warble")))
        
        return musicList
    }
    
    private func getPath(name: String?) -> String? {
        return Bundle.main.path(forResource: name, ofType: "mp3")
    }
    
    private func configureTableView() {
        musicTableView.delegate = self
        musicTableView.dataSource = self
        musicTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        musicTableView.layer.cornerRadius = 10
        musicTableView.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Timer Method
    @objc private func configureTimer() {
        musicSlider.value = Float(player.currentTime)
        musicTimeLabel.text = remainingTime()
        
        if musicSlider.value == musicSlider.minimumValue {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    // MARK: - Remaining Time Method
    private func remainingTime() -> String {
        let duration = Int(player.currentTime)
        let minutes = duration / 60
        let seconds = duration - minutes * 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Default Music Method
    private func defaultMusicSelectedWhenViewLoads() {
        musics = getMusicList()
        musicSlider.value = musicSlider.minimumValue
        
        playAudio(for: self.musics[0].getCurrentPath()!)
        
        guard let image = musics[0].getMusicImage() else { return }
        self.musicImageView.image = image
        self.musicImageView.layer.cornerRadius = 10
        self.musicImageView.clipsToBounds = true
        
    }
    
    // MARK: - Resetting Method
    private func resetAll() {
        player.stop()
        player.currentTime = 0
        timer.invalidate()
        musicSlider.value = musicSlider.minimumValue
        musicTimeLabel.text = "00:00"
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    // MARK: - Playing Audio Method
    private func playAudio(for path: String) {
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            musicSlider.maximumValue = Float(player.duration)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - ImageView Animation & Gesture
    private func imageViewGesture() {
        
        self.musicImageView.isUserInteractionEnabled = true

        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(imageViewSwiped(_:)))
        // gesture.numberOfTapsRequired = 2
        // Touches -> Single place we touch on the screen.
        // gesture.numberOfTouchesRequired = 1
        swipeLeft.direction = .left
        
        self.musicImageView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(imageViewSwiped(_:)))
        swipeRight.direction = .right
        
        self.musicImageView.addGestureRecognizer(swipeRight)
    }
    
    
    @objc private func imageViewSwiped(_ gesture: UISwipeGestureRecognizer) {
        
        self.musicImageView.alpha = 0
        self.musicImageView.center = CGPoint(x: self.musicImageView.center.x + 500, y: self.musicImageView.center.y)
        
        switch gesture.direction {
        case .left:
            if selectedRow < musics.count {
                selectedRow += 1
            }
            
            if gesture.state == .ended {
                
                UIView.animate(withDuration: 1.2) {
                    self.musicImageView.alpha = 1
                    
                    self.musicImageView.center = CGPoint(x: self.musicImageView.center.x - 500, y: self.musicImageView.center.y)
                    
                    self.playAudio(for: self.musics[self.selectedRow].getCurrentPath()!)
                    
                    self.highlightTableViewRow(index: self.selectedRow)
                    
                    self.musicImageView.image = self.musics[self.selectedRow].getMusicImage()
                }
                
            }
        case .right:
            
            if selectedRow == 0 { return }
            if selectedRow >= 0 { selectedRow -= 1 }
            
            if gesture.state == .ended {
                
                UIView.animate(withDuration: 1.2) {
                    self.musicImageView.alpha = 1
                    
                    self.musicImageView.center = CGPoint(x: self.musicImageView.center.x + 500, y: self.musicImageView.center.y)
                    
                    self.playAudio(for: self.musics[self.selectedRow].getCurrentPath()!)
                    
                    self.highlightTableViewRow(index: self.selectedRow)
                    
                    self.musicImageView.image = self.musics[self.selectedRow].getMusicImage()
                }
                
            }
        case .up:
            break
        case .down:
            break
        default:
            break
        }
        
        
        
        
        
    }
    
    // MARK: - Slider Tap Gesture
    private func sliderIsTapped() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(sliderTappedOn(_:)))
        self.musicSlider.addGestureRecognizer(gesture)
    }
    
    @objc private func sliderTappedOn(_ gesture: UITapGestureRecognizer) {
        let pointTapped: CGPoint = gesture.location(in: self.view)
        
        let positionOfSlider: CGPoint = musicSlider.frame.origin
        let widthOfSlider: CGFloat = musicSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x)) * CGFloat(musicSlider.maximumValue) / widthOfSlider
        
        musicSlider.setValue(Float(newValue), animated: true)
        player.currentTime = TimeInterval(musicSlider.value)
    }
    
    // MARK: - Highlighting TableView Method
    private func highlightTableViewRow(index: Int) {
        musicTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
    }
    
    
}
