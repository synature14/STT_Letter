//
//  ViewController.swift
//  STTLetter
//
//  Created by Suvely on 2022/02/03.
//

import UIKit
import Speech

class ViewController: UIViewController {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?  // 음성 인식 요청
    private var recognitionTask: SFSpeechRecognitionTask?       // 인식 요청 결과
    
    private let audioEngine = AVAudioEngine()
    
    weak var child: LetterViewController?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var audioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer?.delegate = self
        setContainerViewController("LetterViewController")
        //        self.child = containerView.subviews.first as? LetterViewController
    }
    
    func setContainerViewController(_ viewControllerID: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let child = storyboard.instantiateViewController(withIdentifier: viewControllerID) as? LetterViewController {
            self.child = child
            self.addChild(child)
            containerView.addSubview(child.view)
            child.view.frame = containerView.bounds
            child.didMove(toParent: self)
        }
    }

    @IBAction func speechToText(_ sender: UIButton) {
        if audioEngine.isRunning {
            // 오디오 입력을 중단한다.
            audioEngine.stop()
            // 음성 인식 역시 중단
            recognitionRequest?.endAudio()
            
            audioButton.isEnabled = true
            
        } else {
            startRecording()
            audioButton.isEnabled = false
        }
    }
    
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // 음성 소리를 인식
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record)
            try audioSession.setMode(.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        // 여기서 우리는 SFSpeechAudioBufferRecognitionRequest 객체를 생성합니다. 나중에 우리는 오디오 데이터를 Apple 서버에 전달하는 데 사용합니다.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
//        // audioEngine (장치)에 녹음 할 오디오 입력이 있는지 확인하십시오. 그렇지 않은 경우 치명적 오류가 발생합니다.
//        guard audioEngine.inputNode != nil else {
//            fatalError("Audio engine has no input node")
//        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // 사용자가 말할 때의 인식 부분적인 결과를보고하도록 recognitionRequest에 지시합니다.
        recognitionRequest.shouldReportPartialResults = true
        
        // 인식을 시작하려면 speechRecognizer의 recognitionTask 메소드를 호출합니다. 이 함수는 완료 핸들러가 있습니다.
        // 이 완료 핸들러는 인식 엔진이 입력을 수신했을 때, 현재의 인식을 세련되거나 취소 또는 정지 한 때에 불려 최종 성적표를 돌려 준다.
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
            guard let result = result else {
                return
            }
            
            guard let self = self else { return }
            
            //결과가 nil이 아닌 경우 textView.text 속성을 결과의 최상의 텍스트로 설정합니다.
            let text = result.bestTranscription.formattedString
            self.child?.letter = text
            
            // isFinal == true: 최종 결과, false : 부분 발화
            if result.isFinal || error != nil {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.audioButton.isEnabled = true
            }
        })
        
        /* recognitionRequest에 오디오 입력을 추가하십시오.
         인식 작업을 시작한 후에는 오디오 입력을 추가해도 괜찮습니다.
         오디오 프레임 워크는 오디오 입력이 추가되는 즉시 인식을 시작합니다.
         */
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)    // AVAudioNodeBus: Int - AVAudioNode objects potentially have multiple input and/or output busses. AVAudioNodeBus represents a bus as a zero-based index.
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        // Prepare and start the audioEngine.
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        child?.letter = "아무거나 말해보세요!"
    }
}

extension ViewController: SFSpeechRecognizerDelegate {
    //
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
    }
}
