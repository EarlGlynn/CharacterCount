object FormControlCodes: TFormControlCodes
  Left = 566
  Top = 343
  BorderStyle = bsSingle
  Caption = 'ASCII Control Codes'
  ClientHeight = 489
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 120
    Top = 456
    Width = 75
    Height = 25
    Caption = '&OK'
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 0
  end
  object StringGridCodes: TStringGrid
    Left = 14
    Top = 24
    Width = 280
    Height = 425
    ColCount = 3
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 35
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goThumbTracking]
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
