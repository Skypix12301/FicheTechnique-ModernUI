unit uBaseForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Math, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  AdvPanel, AdvSmoothButton, AdvStyleIF,
  uModernTheme, uUtils_v3;

type
  TBaseModernForm = class(TForm)
  private
    procedure ApplyRTL;
    procedure ApplyFormStyle;
  protected
    procedure ApplyModernStyle; virtual;
    procedure ApplyModernLayout; virtual;
    procedure ApplyRTL_v3; virtual;
    procedure AfterConstruction; override;
  public
    procedure ShowModal; override;
  end;

implementation

{ TBaseModernForm }

procedure TBaseModernForm.AfterConstruction;
begin
  inherited AfterConstruction;
  DoubleBuffered := True;
  ApplyRTL;
  ApplyFormStyle;
end;

procedure TBaseModernForm.ApplyRTL;
begin
  BiDiMode := bdRightToLeft;
end;

procedure TBaseModernForm.ApplyFormStyle;
begin
  Color := CLR_BG_MAIN;
  Font.Name := FONT_MAIN;
  Font.Size := FONT_SIZE_BODY;
  Font.Color := CLR_TEXT_MAIN;
end;

procedure TBaseModernForm.ApplyModernStyle;
begin
  ApplyFormStyle;
  ApplyRTL;
end;

procedure TBaseModernForm.ApplyModernLayout;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;
end;

procedure TBaseModernForm.ApplyRTL_v3;
begin
  BiDiMode := bdRightToLeft;
end;

procedure TBaseModernForm.ShowModal;
begin
  ApplyModernStyle;
  inherited ShowModal;
end;

end.