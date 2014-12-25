unit aboutscreen; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls, Process, AsyncProcess;

type

  { Tabout }

  Tabout = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  about: Tabout;

implementation

{ Tabout }

procedure Tabout.Button1Click(Sender: TObject);
begin
  Close;
end;


initialization
  {$I aboutscreen.lrs}

end.

