object FormCharCount: TFormCharCount
  Left = 1643
  Top = 285
  BorderStyle = bsSingle
  Caption = 'CharCount 2013'
  ClientHeight = 514
  ClientWidth = 714
  Color = clBtnFace
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    714
    514)
  PixelsPerInch = 96
  TextHeight = 13
  object LabelInfo1: TLabel
    Left = 87
    Top = 18
    Width = 87
    Height = 13
    Caption = 'x,xxx,xxx,xxx bytes'
  end
  object LabelInfo2: TLabel
    Left = 87
    Top = 32
    Width = 102
    Height = 13
    Caption = 'CRC32 = XXXXXXXX'
  end
  object LabelInfoDeflines: TLabel
    Left = 216
    Top = 1
    Width = 154
    Height = 13
    Caption = 'x,xxx,xxx lines   x,xxx,xxx deflines'
    Visible = False
  end
  object ButtonSelect: TButton
    Left = 8
    Top = 22
    Width = 75
    Height = 25
    Caption = 'Select File'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = ButtonSelectClick
  end
  object StringGrid: TStringGrid
    Left = 6
    Top = 76
    Width = 701
    Height = 429
    ColCount = 17
    DefaultColWidth = 40
    RowCount = 17
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    OnDrawCell = StringGridDrawCell
  end
  object ButtonControlCodes: TButton
    Tag = 20
    Left = 632
    Top = 24
    Width = 75
    Height = 25
    Anchors = [akRight]
    Caption = 'Control Codes'
    TabOrder = 3
    OnClick = ButtonControlCodesClick
  end
  object CheckBoxFASTA: TCheckBox
    Left = 7
    Top = 1
    Width = 210
    Height = 17
    Caption = 'Assume FASTA File / Exclude Deflines'
    TabOrder = 2
  end
  object CheckBoxASCII: TCheckBox
    Left = 9
    Top = 53
    Width = 137
    Height = 17
    Caption = 'Show ASCII characters'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = CheckBoxASCIIClick
  end
  object OpenDialog: TOpenDialog
    FilterIndex = 0
    Title = 'Open File'
    Left = 376
    Top = 16
  end
end
