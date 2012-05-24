inherited CSSOptionsFrame: TCSSOptionsFrame
  Height = 261
  ExplicitHeight = 261
  object lblCSSFile: TLabel
    Left = 24
    Top = 55
    Width = 145
    Height = 13
    Caption = 'Choose or enter CSS file name'
  end
  object lblCSSURL: TLabel
    Left = 24
    Top = 130
    Width = 107
    Height = 13
    Caption = 'Enter style sheet URL:'
  end
  object rbEmbedCSS: TRadioButton
    Left = 8
    Top = 32
    Width = 192
    Height = 17
    Caption = 'Embed CSS from file'
    TabOrder = 1
    OnClick = RadioButtonClick
  end
  object rbLinkCSS: TRadioButton
    Left = 8
    Top = 107
    Width = 192
    Height = 17
    Caption = 'Link to external style sheet'
    TabOrder = 4
    OnClick = RadioButtonClick
  end
  object chkLegacyCSS: TCheckBox
    Left = 8
    Top = 181
    Width = 192
    Height = 17
    Caption = 'Use PasHi v1 CSS style names'
    TabOrder = 6
  end
  object cbCSSFile: TComboBox
    Left = 24
    Top = 74
    Width = 140
    Height = 21
    TabOrder = 2
  end
  object edCSSURL: TEdit
    Left = 24
    Top = 149
    Width = 170
    Height = 21
    HideSelection = False
    TabOrder = 5
  end
  object chkHideCSS: TCheckBox
    Left = 8
    Top = 204
    Width = 176
    Height = 17
    Caption = 'Hide CSS in HTML comments'
    TabOrder = 7
  end
  object btnCSSFileDlg: TButton
    Left = 169
    Top = 72
    Width = 25
    Height = 25
    Action = actCSSFileBrowse
    TabOrder = 3
  end
  object rbDefaultCSS: TRadioButton
    Left = 8
    Top = 8
    Width = 192
    Height = 17
    Caption = 'Use default style sheet'
    TabOrder = 0
    OnClick = RadioButtonClick
  end
  object alCSSActions: TActionList
    Left = 211
    Top = 69
    object actCSSFileBrowse: TFileOpen
      Caption = '...'
      Dialog.DefaultExt = '.css'
      Dialog.Filter = 'Cascading Style Sheets|*.css'
      Dialog.Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
      Dialog.Title = 'Choose CSS file'
      Hint = 'Select CSS File|Choose CSS file to embed'
      ImageIndex = 7
      OnAccept = actCSSFileBrowseAccept
    end
  end
end
