unit uBaseForm;

{==============================================================================}
{ Formulaire de base moderne VCL pour Fiches Techniques                        }
{ Gère automatiquement : DoubleBuffered, Margins, Thèmes, BiDiMode             }
{==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, uVCLModernizer;

type
  TfrmBase = class(TForm)
    procedure FormCreate(Sender: TObject);
  protected
    procedure SetupModernUI; virtual;
    procedure SwitchLanguage(const LangCode: string); virtual;
  public
    procedure ApplyCardStyle(APanel: TPanel);
  end;

var
  frmBase: TfrmBase;

implementation

{$R *.dfm}

procedure TfrmBase.FormCreate(Sender: TObject);
begin
  SetupModernUI;
end;

procedure TfrmBase.SetupModernUI;
begin
  // Initialisation du moteur de style moderne
  TVCLModernizer.ModernizeForm(Self, 'Segoe UI');
end;

procedure TfrmBase.ApplyCardStyle(APanel: TPanel);
begin
  TVCLModernizer.StyleCardPanel(APanel);
end;

procedure TfrmBase.SwitchLanguage(const LangCode: string);
var
  IsAR: Boolean;
begin
  IsAR := SameText(LangCode, 'AR');
  TVCLModernizer.ApplyBiDiMode(Self, IsAR);
end;

end.
