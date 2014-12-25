unit logscreen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls;

type

  { Tlogscreen }

  Tlogscreen = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1ChangeBounds(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  logscreenunit: Tlogscreen;

implementation

{ Tlogscreen }

procedure Tlogscreen.FormShow(Sender: TObject);
begin
  RadioGroup1.ItemIndex:=0;
  Memo1.Lines.LoadFromFile('logs/errorlog');
end;

procedure Tlogscreen.RadioGroup1ChangeBounds(Sender: TObject);
begin
end;

procedure Tlogscreen.RadioGroup1Click(Sender: TObject);
begin
  if (RadioGroup1.ItemIndex=0) then Memo1.Lines.LoadFromFile('logs/errorlog');
  if (RadioGroup1.ItemIndex=1) then Memo1.Lines.LoadFromFile('logs/sendlog');
  if (RadioGroup1.ItemIndex=2) then Memo1.Lines.LoadFromFile('logs/proglog');

  Memo1.Refresh;
end;

procedure Tlogscreen.Button1Click(Sender: TObject);
begin
    Close;
end;

procedure Tlogscreen.Button2Click(Sender: TObject);
var
dosya:TextFile;
dosyaadi:String;
begin
       if (RadioGroup1.ItemIndex=0) then dosyaadi:='logs/errorlog';
       if (RadioGroup1.ItemIndex=1) then dosyaadi:='logs/sendlog';
       if (RadioGroup1.ItemIndex=2) then dosyaadi:='logs/proglog';

     try
     AssignFile (dosya, dosyaadi);
     Rewrite(dosya);
     WriteLn(dosya, ' ');
     CloseFile(dosya);
     except
       ShowMessage('Can not clear log file!');
     end;
     Memo1.Lines.LoadFromFile(dosyaadi);
     Memo1.Refresh;
end;



initialization
  {$I logscreen.lrs}

end.

