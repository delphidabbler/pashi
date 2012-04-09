inherited LineStyleOptionsFrame: TLineStyleOptionsFrame
  object lblNumberWidth: TLabel
    Left = 24
    Top = 36
    Width = 94
    Height = 13
    Caption = 'Line number width: '
  end
  object lblPadding: TLabel
    Left = 24
    Top = 64
    Width = 152
    Height = 13
    Caption = 'Line number padding character:'
  end
  object chkLineNumbering: TCheckBox
    Left = 8
    Top = 8
    Width = 201
    Height = 17
    Caption = 'Use line numbering'
    TabOrder = 0
    OnClick = chkLineNumberingClick
  end
  object chkStriping: TCheckBox
    Left = 8
    Top = 116
    Width = 177
    Height = 17
    Caption = 'Highlight alternate lines'
    TabOrder = 3
  end
  object seNumberWidth: TSpinEdit
    Left = 124
    Top = 31
    Width = 45
    Height = 22
    EditorEnabled = False
    MaxLength = 1
    MaxValue = 6
    MinValue = 1
    TabOrder = 1
    Value = 3
  end
  object cbPadding: TComboBox
    Left = 24
    Top = 83
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 2
  end
end
