inherited DocTypeOptionsFrame: TDocTypeOptionsFrame
  object lblCompleteDocType: TLabel
    Left = 25
    Top = 56
    Width = 77
    Height = 13
    Caption = 'Document type:'
  end
  object lblInhibitStyling: TLabel
    Left = 8
    Top = 106
    Width = 69
    Height = 13
    Caption = 'Inhibit Styling:'
    FocusControl = clbInhibitStyling
  end
  object rbDocTypeFragment: TRadioButton
    Left = 8
    Top = 8
    Width = 200
    Height = 17
    Caption = 'HTML Fragment'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbDocTypeFragmentClick
  end
  object rbDocTypeComplete: TRadioButton
    Left = 8
    Top = 31
    Width = 200
    Height = 17
    Caption = 'Complete HTML document'
    TabOrder = 1
    OnClick = rbDocTypeCompleteClick
  end
  object cbCompleteDocType: TComboBox
    Left = 25
    Top = 75
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 2
  end
  object clbInhibitStyling: TCheckListBox
    Left = 8
    Top = 124
    Width = 188
    Height = 97
    ItemHeight = 13
    TabOrder = 3
  end
end
