inherited MiscOptionsFrame: TMiscOptionsFrame
  Height = 283
  ExplicitHeight = 283
  object lblSeparatorLines: TLabel
    Left = 8
    Top = 60
    Width = 111
    Height = 13
    Caption = 'Separate input files by '
  end
  object lblSeparatorLinesEnd: TLabel
    Left = 162
    Top = 60
    Width = 29
    Height = 13
    Caption = 'line(s)'
  end
  object lblLanguage: TLabel
    Left = 8
    Top = 88
    Width = 123
    Height = 26
    Caption = 'HTML document language'#13#10'(leave blank for default)'
  end
  object lblTitle: TLabel
    Left = 8
    Top = 128
    Width = 116
    Height = 26
    Caption = 'Title of HTML document'#13#10'(leave blank for default)'
  end
  object chkTrimLines: TCheckBox
    Left = 8
    Top = 8
    Width = 217
    Height = 17
    Caption = 'Trim blank leading and trailing lines'
    TabOrder = 0
  end
  object seSeparatorLines: TSpinEdit
    Left = 117
    Top = 57
    Width = 40
    Height = 22
    EditorEnabled = False
    MaxLength = 1
    MaxValue = 16
    MinValue = 0
    TabOrder = 1
    Value = 1
  end
  object edLanguage: TEdit
    Left = 145
    Top = 93
    Width = 49
    Height = 21
    MaxLength = 5
    TabOrder = 2
  end
  object edTitle: TEdit
    Left = 8
    Top = 160
    Width = 186
    Height = 21
    TabOrder = 3
  end
  object chkBranding: TCheckBox
    Left = 8
    Top = 190
    Width = 217
    Height = 17
    Caption = 'Include "branding" in documents'
    TabOrder = 4
  end
  object chkViewport: TCheckBox
    Left = 8
    Top = 213
    Width = 217
    Height = 17
    Caption = 'Set viewport to make mobile friendly'
    TabOrder = 5
  end
  object chkEdgeCompatibility: TCheckBox
    Left = 8
    Top = 236
    Width = 217
    Height = 17
    Caption = 'Include MS Edge compatibility info'
    TabOrder = 6
  end
  object chkTrimSpaces: TCheckBox
    Left = 8
    Top = 29
    Width = 217
    Height = 17
    Caption = 'Trim spaces from line ends'
    TabOrder = 7
  end
end
