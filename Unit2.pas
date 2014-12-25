unit Unit2; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, synautil, ZConnection, db, ZDataset;

type

  { Tdatabasesettings }

  Tdatabasesettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ComboBox1: TComboBox;
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
    Label7: TLabel;
    ZConnection1: TZConnection;
    ZReadOnlyQuery1: TZReadOnlyQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end; 



var
  databasesettings: Tdatabasesettings;



implementation

{ Tdatabasesettings }

  uses unit1;



procedure Tdatabasesettings.Button1Click(Sender: TObject);
var
dosya:TextFile;
begin
     try
     AssignFile (dosya, 'conf/databaseconfig');
     Rewrite(dosya);
     Writeln(dosya, 'databasetype='+ IntToStr( ComboBox1.ItemIndex ) );
     WriteLn(dosya, 'username='+edit1.Text);
     WriteLn(dosya, 'password='+edit2.Text);
     WriteLn(dosya, 'server='+edit3.Text);
     WriteLn(dosya, 'databasename='+edit4.Text);
     WriteLn(dosya, 'tablename='+edit5.Text);
     Writeln(dosya, 'fieldname='+edit6.text);
     CloseFile(dosya);
     except
       ShowMessage('Can not write mysql configuration to config file.');
     end;

     if ComboBox1.ItemIndex=0 then mainform.BitBtn1.Enabled:=True else
         mainform.BitBtn1.Enabled:=False;

     Close;
end;

procedure Tdatabasesettings.Button2Click(Sender: TObject);
begin
  close;
end;

procedure Tdatabasesettings.Button3Click(Sender: TObject);
var
  databaseusername, databasepassword, databasetype, databaseserver, databasename,
  databasetablename, databasefieldname : String;
  dosya : TextFile;
  okunan, degvar :String;

begin

    //database ayarlari okuma
     try
     AssignFile (dosya, 'conf/databaseconfig');
     Reset(dosya);
     repeat
       ReadLn(dosya, okunan);
       degvar:=Trim(SeparateLeft(okunan, '='));
       //case not supported strings
          if degvar='username' then databaseusername:=Trim(SeparateRight(okunan, '='));
          if degvar='password' then databasepassword:=Trim(SeparateRight(okunan, '='));
          if degvar='databasetype' then databasetype:=Trim(SeparateRight(okunan, '='));
          if degvar='server'   then databaseserver:=Trim(SeparateRight(okunan, '='));
          if degvar='databasename' then databasename:=Trim(SeparateRight(okunan, '='));
          if degvar='tablename' then databasetablename:=Trim(SeparateRight(okunan, '='));
          if degvar='fieldname' then databasefieldname:=Trim(SeparateRight(okunan, '='));
      until eof(dosya);
     CloseFile(dosya);
     except
         ShowMessage('Can not read database configuration file.');
     end;

     if strtoint(databasetype)>0 then
     begin

       ZConnection1.Database:=databasename;
       ZConnection1.HostName:=databaseserver;
       ZConnection1.Password:=databasepassword;
       ZConnection1.Protocol:='mysql-5';
       ZConnection1.User:=databaseusername;

       ZReadOnlyQuery1.SQL.Add('select '+databasefieldname+ ' from '+databasetablename);
       ZConnection1.Connected:=True;
       ZReadOnlyQuery1.Active:=True;
       //showmessage('select '+databasefieldname+ ' from '+databasetablename);
       showmessage( 'Your first record is '+ZReadOnlyQuery1.FieldByName(databasefieldname).AsString );

     end;



end;



procedure Tdatabasesettings.ComboBox1Change(Sender: TObject);
begin
  if ComboBox1.ItemIndex>0 then
     begin
          Edit1.Enabled:=True;
          Edit2.Enabled:=True;
          Edit3.Enabled:=True;
          Edit4.Enabled:=True;
          Edit5.Enabled:=True;
          Edit6.Enabled:=True;
     end;

  if ComboBox1.ItemIndex=0 then
     begin
          Edit1.Enabled:=False;
          Edit2.Enabled:=False;
          Edit3.Enabled:=False;
          Edit4.Enabled:=False;
          Edit5.Enabled:=False;
          Edit6.Enabled:=False;
     end;

end;

procedure Tdatabasesettings.FormShow(Sender: TObject);
var
okunan, degvar : String;
dosya : TextFile;

begin
     try
     AssignFile (dosya, 'conf/databaseconfig');
     Reset(dosya);
     repeat
       ReadLn(dosya, okunan);
       degvar:=Trim(SeparateLeft(okunan, '='));
       //case not supported strings
          if degvar='username' then edit1.text:=Trim(SeparateRight(okunan, '='));
          if degvar='password' then edit2.text:=Trim(SeparateRight(okunan, '='));
          if degvar='databasetype' then ComboBox1.ItemIndex:=StrToInt( Trim(SeparateRight(okunan, '=')) );
          if degvar='server'   then edit3.text:=Trim(SeparateRight(okunan, '='));
          if degvar='databasename' then edit4.text:=Trim(SeparateRight(okunan, '='));
          if degvar='tablename' then edit5.text:=Trim(SeparateRight(okunan, '='));
          if degvar='fieldname' then edit6.text:=Trim(SeparateRight(okunan, '='));

          if ComboBox1.ItemIndex=0 then
          begin
               Edit1.Enabled:=False;
               Edit2.Enabled:=False;
               Edit3.Enabled:=False;
               Edit4.Enabled:=False;
               Edit5.Enabled:=False;
               Edit6.Enabled:=False;
          end;

     until eof(dosya);
     CloseFile(dosya);
     except
       ShowMessage('Can not read configuration file');
            try
            AssignFile (dosya, 'conf/databaseconfig');
            Rewrite(dosya);
            WriteLn(dosya, 'username=test');
            WriteLn(dosya, 'password=testpass');
            Writeln(dosya, 'databasetype=0' );
            WriteLn(dosya, 'server=10.0.0.10');
            WriteLn(dosya, 'databasename=testdb');
            WriteLn(dosya, 'tablename=mailtable');
            Writeln(dosya, 'fieldname=emailaddress');
            CloseFile(dosya);
            except
            ShowMessage('Can not write mysql configuration file');
            end;
     end;
end;

initialization
  {$I unit2.lrs}

end.

