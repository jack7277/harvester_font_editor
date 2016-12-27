object Form1: TForm1
  Left = 100
  Top = 64
  Width = 1365
  Height = 803
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object img1: TImage
    Left = 200
    Top = 40
    Width = 1
    Height = 1
    Stretch = True
    OnMouseDown = img1MouseDown
    OnMouseMove = img1MouseMove
  end
  object Label1: TLabel
    Left = 8
    Top = 260
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 8
    Top = 279
    Width = 31
    Height = 13
    Caption = 'Label2'
  end
  object imgz: TImage
    Left = 8
    Top = 340
    Width = 170
    Height = 40
  end
  object img3: TImage
    Left = 2
    Top = 383
    Width = 47
    Height = 55
    Center = True
  end
  object lbl1: TLabel
    Left = 223
    Top = 0
    Width = 76
    Height = 13
    Caption = #1042#1099#1073#1086#1088' '#1089#1080#1084#1074#1086#1083#1072
  end
  object lbl2: TLabel
    Left = 381
    Top = 2
    Width = 25
    Height = 13
    Caption = 'zoom'
  end
  object img2: TImage
    Left = 0
    Top = 496
    Width = 5000
    Height = 49
  end
  object lbl3: TLabel
    Left = 101
    Top = 277
    Width = 75
    Height = 13
    Caption = #1074#1099#1073#1086#1088' '#1096#1088#1080#1092#1090#1072
  end
  object lbl4: TLabel
    Left = 601
    Top = 248
    Width = 16
    Height = 13
    Caption = 'lbl4'
  end
  object lbl5: TLabel
    Left = 705
    Top = 248
    Width = 16
    Height = 13
    Caption = 'lbl5'
  end
  object decrypt: TButton
    Left = 8
    Top = 8
    Width = 81
    Height = 65
    Caption = #1056#1072#1089#1096#1092#1088#1074#1072#1090#1100
    TabOrder = 0
    OnClick = decryptClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 78
    Width = 177
    Height = 181
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object encrypt: TButton
    Left = 96
    Top = 8
    Width = 89
    Height = 65
    Caption = #1047#1087#1080#1083#1080#1090#1100' '#1087#1077#1088#1074#1086#1076' '#1074' '#1096#1080#1092#1088
    TabOrder = 2
    WordWrap = True
    OnClick = encryptClick
  end
  object fontnum: TScrollBar
    Left = 200
    Top = 19
    Width = 121
    Height = 17
    Max = 255
    Min = 32
    PageSize = 0
    Position = 167
    TabOrder = 3
    OnChange = fontnumChange
  end
  object zoom: TScrollBar
    Left = 336
    Top = 19
    Width = 121
    Height = 16
    Max = 40
    Min = 1
    PageSize = 0
    Position = 40
    TabOrder = 4
    OnChange = zoomChange
  end
  object ColorChoose: TScrollBar
    Left = 8
    Top = 319
    Width = 170
    Height = 16
    Max = 255
    PageSize = 0
    Position = 15
    TabOrder = 5
    OnChange = ColorChooseChange
  end
  object SaveFont: TButton
    Left = 136
    Top = 412
    Width = 41
    Height = 25
    Caption = #1089#1093#1088#1085#1090#1100
    TabOrder = 6
    OnClick = SaveFontClick
  end
  object seSymWidth: TSpinEdit
    Left = 8
    Top = 442
    Width = 169
    Height = 33
    AutoSize = False
    MaxValue = 100
    MinValue = 1
    TabOrder = 7
    Value = 2
    OnChange = seSymWidthChange
  end
  object btn2: TButton
    Left = 51
    Top = 412
    Width = 81
    Height = 25
    Caption = 'Clear & save smbl'
    TabOrder = 8
    OnClick = btn2Click
  end
  object FontChoose: TScrollBar
    Left = 65
    Top = 296
    Width = 112
    Height = 18
    Max = 8
    PageSize = 0
    TabOrder = 9
    OnChange = FontChooseChange
  end
  object mmo1: TMemo
    Left = 592
    Top = 2
    Width = 345
    Height = 122
    ScrollBars = ssVertical
    TabOrder = 10
  end
  object mmo2: TMemo
    Left = 592
    Top = 128
    Width = 345
    Height = 110
    ScrollBars = ssVertical
    TabOrder = 11
  end
  object ScrollBar4: TScrollBar
    Left = 942
    Top = 16
    Width = 65
    Height = 33
    PageSize = 0
    TabOrder = 12
    OnChange = ScrollBar4Change
  end
  object ScrollBar5: TScrollBar
    Left = 943
    Top = 57
    Width = 65
    Height = 40
    PageSize = 0
    TabOrder = 13
    OnChange = ScrollBar5Change
  end
  object _SaveTranslation: TButton
    Left = 943
    Top = 102
    Width = 66
    Height = 27
    Caption = #1057#1093#1088#1085#1090#1100' '#1087#1088#1074#1076
    TabOrder = 14
    OnClick = _SaveTranslationClick
  end
  object chk1: TCheckBox
    Left = 938
    Top = 134
    Width = 97
    Height = 17
    Caption = #1050#1078#1076#1103' '#1089#1090#1088#1082#1072
    TabOrder = 15
  end
  object datUnpack: TButton
    Left = 942
    Top = 211
    Width = 70
    Height = 25
    Caption = 'DAT unpack'
    TabOrder = 16
    OnClick = datUnpackClick
  end
  object chk2: TCheckBox
    Left = 940
    Top = 155
    Width = 72
    Height = 17
    Caption = #1057#1086#1093#1088
    Checked = True
    State = cbChecked
    TabOrder = 17
  end
  object bmpFontImport: TButton
    Left = 944
    Top = 240
    Width = 67
    Height = 25
    Caption = 'imprt bmp'
    TabOrder = 18
    OnClick = bmpFontImportClick
  end
  object btn1: TButton
    Left = 56
    Top = 384
    Width = 121
    Height = 25
    Caption = #1074#1085#1080#1079
    TabOrder = 19
    OnClick = btn1Click
  end
  object btn3: TButton
    Left = 944
    Top = 272
    Width = 65
    Height = 25
    Caption = 'dat_rusify'
    TabOrder = 20
    OnClick = btn3Click
  end
  object btn4: TButton
    Left = 944
    Top = 304
    Width = 65
    Height = 25
    Caption = 'abm de-rle'
    TabOrder = 21
    OnClick = btn4Click
  end
  object Button1: TButton
    Left = 942
    Top = 336
    Width = 67
    Height = 32
    Caption = 'ABM encode'
    TabOrder = 22
    OnClick = Button1Click
  end
end
