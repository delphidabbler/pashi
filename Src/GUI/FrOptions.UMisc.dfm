inherited MiscOptionsFrame: TMiscOptionsFrame
  object lblSeparatorLines: TLabel
    Left = 8
    Top = 36
    Width = 111
    Height = 13
    Caption = 'Separate input files by '
  end
  object lblSeparatorLinesEnd: TLabel
    Left = 162
    Top = 36
    Width = 29
    Height = 13
    Caption = 'line(s)'
  end
  object lblLanguage: TLabel
    Left = 8
    Top = 64
    Width = 123
    Height = 26
    Caption = 'HTML document language'#13#10'(leave blank for default)'
  end
  object lblTitle: TLabel
    Left = 8
    Top = 104
    Width = 116
    Height = 26
    Caption = 'Title of HTML document'#13#10'(leave blank for default)'
  end
  object chkTrim: TCheckBox
    Left = 8
    Top = 8
    Width = 217
    Height = 17
    Caption = 'Trim blank leading and trailing lines'
    TabOrder = 0
  end
  object seSeparatorLines: TSpinEdit
    Left = 117
    Top = 33
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
    Top = 69
    Width = 49
    Height = 21
    MaxLength = 5
    TabOrder = 2
  end
  object edTitle: TEdit
    Left = 8
    Top = 136
    Width = 186
    Height = 21
    TabOrder = 3
  end
  object chkBranding: TCheckBox
    Left = 8
    Top = 166
    Width = 217
    Height = 17
    Caption = 'Include "branding" in documents'
    TabOrder = 4
  end
  object chkViewport: TCheckBox
    Left = 8
    Top = 189
    Width = 217
    Height = 17
    Caption = 'Set viewport to make mobile friendly'
    TabOrder = 5
  end
  object chkEdgeCompatibility: TCheckBox
    Left = 8
    Top = 212
    Width = 217
    Height = 17
    Caption = 'Include MS Edge compatibility info'
    TabOrder = 6
  end
end
