unit smtpset;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, synautil;

type

  { Tsmtpsettings }

  Tsmtpsettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  smtpsettings: Tsmtpsettings;

implementation

{ Tsmtpsettings }

procedure Tsmtpsettings.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure Tsmtpsettings.FormShow(Sender: TObject);
var
okunan, degvar : String;
dosya : TextFile;

begin
     try
     AssignFile (dosya, 'conf/config');
     Reset(dosya);
     repeat
       ReadLn(dosya, okunan);
       degvar:=Trim(SeparateLeft(okunan, '='));
       //case not supported strings
          if degvar='username' then edit1.text:=Trim(SeparateRight(okunan, '='));
          if degvar='password' then edit2.text:=Trim(SeparateRight(okunan, '='));
          if degvar='server'   then edit3.text:=Trim(SeparateRight(okunan, '='));
          if degvar='sport' then edit4.text:=Trim(SeparateRight(okunan, '='));
          if degvar='wait' then edit5.text:=Trim(SeparateRight(okunan, '='));
          if degvar='mailfrom' then edit6.text:=Trim(SeparateRight(okunan, '='));
     until eof(dosya);
     CloseFile(dosya);
     except
       ShowMessage('Can not read configuration file');
     end;
end;

procedure Tsmtpsettings.Button1Click(Sender: TObject);
var
dosya:TextFile;
begin
     try
     AssignFile (dosya, 'conf/config');
     Rewrite(dosya);
     WriteLn(dosya, 'username='+edit1.Text);
     WriteLn(dosya, 'password='+edit2.Text);
     WriteLn(dosya, 'server='+edit3.Text);
     WriteLn(dosya, 'sport='+edit4.Text);
     WriteLn(dosya, 'wait='+edit5.Text);
     Writeln(dosya, 'mailfrom='+edit6.text);
     CloseFile(dosya);
     except
       ShowMessage('Can not write configuration file');
     end;
     
     Close;
end;

initialization
  {$I smtpset.lrs}

end.

