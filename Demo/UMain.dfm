object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'Stringr demo'
  ClientHeight = 462
  ClientWidth = 811
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 433
    Top = 0
    Width = 5
    Height = 462
    ExplicitLeft = 521
  end
  object MemoSaida: TMemo
    Left = 438
    Top = 0
    Width = 373
    Height = 462
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 433
    Height = 462
    Align = alLeft
    TabOrder = 1
    object Label1: TLabel
      Left = 1
      Top = 373
      Width = 431
      Height = 13
      Align = alBottom
      Caption = 'Par'#226'metros:'
      ExplicitWidth = 59
    end
    object MemoParametros: TMemo
      Left = 1
      Top = 386
      Width = 431
      Height = 75
      Align = alBottom
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Lucida Console'
      Font.Style = []
      Lines.Strings = (
        'nome=world')
      ParentFont = False
      TabOrder = 0
      WordWrap = False
    end
    object MemoTemplate: TMemo
      Left = 1
      Top = 1
      Width = 431
      Height = 372
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Lucida Console'
      Font.Style = []
      Lines.Strings = (
        'Hello, {nome}!')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object MainMenu1: TMainMenu
    Left = 24
    Top = 232
    object emplate1: TMenuItem
      Caption = 'Template'
      object Abrir1: TMenuItem
        Caption = 'Abrir...'
        OnClick = Abrir1Click
      end
      object Gerar1: TMenuItem
        Caption = 'Gerar'
        OnClick = Gerar1Click
      end
    end
  end
  object OfdTemplate: TOpenDialog
    Left = 80
    Top = 232
  end
end
