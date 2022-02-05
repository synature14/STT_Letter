//
//  LetterViewController.swift
//  STTLetter
//
//  Created by Suvely on 2022/02/04.
//

import UIKit

class LetterViewController: UIViewController {
    @IBOutlet weak var letterTextView: UITextView!

    var letter: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        letterTextView.text = letter
    }
    

}
