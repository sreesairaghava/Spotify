//
//  ActionLabelView.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 05/06/21.
//

import UIKit

struct ActionLabelViewViewModel {
    let text: String
    let actionTitle: String
}

//Protocol: Delegate

protocol ActionLabelViewDelegate: AnyObject {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView)
}

class ActionLabelView: UIView {
    
    //Variable to hold delegate with weak reference
    weak var delegate: ActionLabelViewDelegate?
    
    //UI: Label
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    //UI: Button
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds =  true
        //This viewLabel should be hidden by default
        isHidden = true
        addSubview(button)
        addSubview(label)
        button.addTarget(self, action: #selector(didTapButton), for:.touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    //Function: @Objc didTapButton
    @objc func didTapButton(){
        delegate?.actionLabelViewDidTapButton(self)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 0, y: height-40, width: width, height: 40)
        label.frame = CGRect(x: 0, y: 0, width: width, height: height-45)
    }

    func configure(with viewModel: ActionLabelViewViewModel){
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }
}
