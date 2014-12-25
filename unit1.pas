unit unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, StdCtrls, ExtCtrls, smtpsend, mimemess, mimepart, SynaChar,
  EditBtn, Buttons, logscreen, smtpset, synautil, aboutscreen,
  unit2, ZDataset, ZConnection, windows ;

type

{ TMyThread }
TMyThread = class(TThread)

  private
    fStatusText: string;
    procedure ShowStatus;
  protected
    procedure Execute; override;
    procedure Databasesend;
    procedure readconfig;
  public
    constructor Create(CreateSuspended: boolean);
  end;



  { Tmainform }

  Tmainform = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    RadioGroup1: TRadioGroup;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ZConnection1: TZConnection;
    ZReadOnlyQuery1: TZReadOnlyQuery;
     procedure BitBtn1Click(Sender: TObject);
     procedure BitBtn2Click(Sender: TObject);
     procedure FormCreate(Sender: TObject);
     procedure FormShow(Sender: TObject);
     procedure MenuItem4Click(Sender: TObject);
     procedure MenuItem5Click(Sender: TObject);
     procedure MenuItem6Click(Sender: TObject);
     procedure MenuItem8Click(Sender: TObject);
     procedure MenuItem9Click(Sender: TObject);
     procedure Timer1Timer(Sender: TObject);
     procedure ToolButton1Click(Sender: TObject);
     procedure ToolButton2Click(Sender: TObject);
     procedure ToolButton3Click(Sender: TObject);
     procedure ToolButton4Click(Sender: TObject);
     procedure ToolButton5Click(Sender: TObject);
     procedure ToolButton6Click(Sender: TObject);
     procedure readconfig;
     procedure logwrite(tip, mesaj: String);
     function  GetVolumeID(DriveChar: Char): String;
     procedure ToolButton7Click(Sender: TObject);

  private
  
  public
    { public declarations }

  end; 

var
  mainform: Tmainform;

  username, password, smtpserver, portnumber, waitsecond,mailfrom: String;

  databaseusername, databasepassword, databasetype, databaseserver, databasename,
  databasetablename, databasefieldname : String;

  nowcancel: boolean;



implementation





{ TMyThread }

procedure TMyThread.ShowStatus;
begin
  mainform.Caption := fStatusText;
end;

procedure TMyThread.Databasesend;
var
  StrList:TStringList;
  SMTPHost, MailTo,Subject, MailToWho, okunan:String;
  AttachMess:TMimeMess;
  dosya:TextFile;
  mailicerik:String;
  sayac: Integer;

begin

//mail gönderme işlemleri
    readconfig;

    if strtoint(databasetype)>0 then
     begin
       try
       mainform.ZConnection1.Database:=databasename;
       mainform.ZConnection1.HostName:=databaseserver;
       mainform.ZConnection1.Password:=databasepassword;
       mainform.ZConnection1.Protocol:='mysql-5';
       mainform.ZConnection1.User:=databaseusername;

       mainform.ZReadOnlyQuery1.SQL.Add('select '+databasefieldname+ ' from '+databasetablename);
       mainform.ZConnection1.Connected:=True;
       mainform.ZReadOnlyQuery1.Active:=True;
       //showmessage('select '+databasefieldname+ ' from '+databasetablename);
       //showmessage( 'Your first record is '+ZReadOnlyQuery1.FieldByName(databasefieldname).AsString );
       except
         ShowMessage('Please control your database settings or connections!');
         exit;
       end;

     end;


    Subject:=mainform.Edit3.Text;
    SMTPHost:=smtpserver+':'+portnumber;

    sayac:=0;

    repeat

    sayac:=sayac+1;

    StrList:=TStringList.Create;
    AttachMess:=TMimeMess.Create;

    okunan:= mainform.ZReadOnlyQuery1.FieldByName(databasefieldname).AsString;
    MailTo:= Trim( SeparateLeft(okunan, ',') );
    //MailToWho:= Trim( SeparateRight(okunan, ',') );

    mainform.StatusBar1.SimpleText := 'Sending mail ' + inttostr(sayac) + ' ' + MailTo;
    mainform.StatusBar1.Repaint;

    mailicerik := ReplaceString(mainform.Memo1.Lines.Text, '[mydearsign]', MailToWho);
    StrList.Add(mailicerik);

    AttachMess.Header.From:=MailFrom;
    AttachMess.Header.ToList.Add(MailTo);
    AttachMess.Header.Subject:=Subject;
    AttachMess.Header.XMailer:='Outlook 11.5608.5606';
    AttachMess.Header.CustomHeaders.Add('Content-type: Multipart/related;; boundary="boundary-example-1"');
    AttachMess.AddPartMultipart('', Nil);

    //html veya text mesaj
    if mainform.RadioGroup1.ItemIndex=0 then AttachMess.AddPartHTML(StrList, AttachMess.MessagePart)
    else AttachMess.AddPartText(StrList,AttachMess.MessagePart);

    //attach icinde bir sey varsa gonder
    if mainform.Edit2.Text<>'' then AttachMess.AddPartBinaryFromFile(mainform.Edit2.Text, AttachMess.MessagePart);

    AttachMess.EncodeMessage;

    if Not SendToRaw(MailFrom, MailTo, SMTPHost, AttachMess.Lines, username, password) then
      begin
      mainform.logwrite ('error', 'Error : '+Trim(MailTo) + ' : ' + FormatDateTime('DD-MM-YYYY HH:NN:SS',Now) );
      mainform.StatusBar1.SimpleText:='Error : '+Trim(MailTo);
      end
        else
      begin
      mainform.logwrite ('send', 'Sent to : '+Trim(MailTo) + ' : ' + FormatDateTime('DD-MM-YYYY HH:NN:SS',Now) );
      mainform.StatusBar1.SimpleText:='Sent success : '+Trim(MailTo)
      end;

    if StrList<>Nil then FreeAndNil(StrList);
    if AttachMess<>Nil then FreeAndNil(AttachMess);

    if (nowcancel=True) then
    begin
    mainform.logwrite ('error', 'Cancelled by user : '+Trim(MailTo) + ' : ' + FormatDateTime('DD-MM-YYYY HH:NN:SS',Now) );

    mainform.StatusBar1.SimpleText:='Cancelled';
    mainform.ToolButton1.ImageIndex:=0;
    exit;
    end;

    Sleep( StrToInt(waitsecond)*1000 );

    mainform.ZReadOnlyQuery1.Next;

    until mainform.ZReadOnlyQuery1.EOF;

    mainform.StatusBar1.SimpleText:='All mails finished. You can see logs for more information.';
    mainform.ToolButton1.ImageIndex:=0;

end;



procedure TMyThread.Execute;
var
  //newStatus : string;
  StrList:TStringList;
  SMTPHost,
  MailTo,Subject, MailToWho, okunan:String;
  AttachMess:TMimeMess;
  dosya:TextFile;
  mailicerik:String;
  sayac: Integer;

begin

//mail gönderme işlemleri
    readconfig;

    if strtoint(databasetype)>0 then
     begin
       databasesend;
       exit;
     end;

     //showmessage('1');

     //Text dosyadan okuma islemleri baslasin
    Subject:=mainform.Edit3.Text;
    SMTPHost:=smtpserver+':'+portnumber;

    AssignFile (dosya, mainform.Edit1.Text);
    reset(dosya);

    sayac:=0;

    repeat

    sayac:=sayac+1;

    StrList:=TStringList.Create;
    AttachMess:=TMimeMess.Create;

    ReadLn(dosya, okunan);
    MailTo:= Trim( SeparateLeft(okunan, ',') );
    MailToWho:= Trim( SeparateRight(okunan, ',') );

    mainform.StatusBar1.SimpleText := 'Sending mail ' + inttostr(sayac) + ' ' + MailTo;
    mainform.StatusBar1.Repaint;

    mailicerik := ReplaceString(mainform.Memo1.Lines.Text, '[mydearsign]', MailToWho);
    StrList.Add(mailicerik);

    AttachMess.Header.From:=MailFrom;
    AttachMess.Header.ToList.Add(MailTo);
    AttachMess.Header.Subject:=Subject;
    AttachMess.Header.XMailer:='Outlook 11.5608.5606';
    AttachMess.Header.CustomHeaders.Add('Content-type: Multipart/related;; boundary="boundary-example-1"');
    AttachMess.AddPartMultipart('', Nil);

    //html veya text mesaj
    if mainform.RadioGroup1.ItemIndex=0 then AttachMess.AddPartHTML(StrList, AttachMess.MessagePart)
    else AttachMess.AddPartText(StrList,AttachMess.MessagePart);

    //attach icinde bir sey varsa gonder
    if mainform.Edit2.Text<>'' then AttachMess.AddPartBinaryFromFile(mainform.Edit2.Text, AttachMess.MessagePart);

    AttachMess.EncodeMessage;

    if Not SendToRaw(MailFrom, MailTo, SMTPHost, AttachMess.Lines, username, password) then
      begin
      mainform.logwrite ('error', 'Error : '+Trim(MailTo) + ' : ' + FormatDateTime('DD-MM-YYYY HH:NN:SS',Now) );
      mainform.StatusBar1.SimpleText:='Error : '+Trim(MailTo);
      end
        else
      begin
      mainform.logwrite ('send', 'Sent to : '+Trim(MailTo) + ' : ' + FormatDateTime('DD-MM-YYYY HH:NN:SS',Now) );
      mainform.StatusBar1.SimpleText:='Sent success : '+Trim(MailTo)
      end;

    if StrList<>Nil then FreeAndNil(StrList);
    if AttachMess<>Nil then FreeAndNil(AttachMess);

    if (nowcancel=True) then
    begin
    mainform.logwrite ('error', 'Cancelled by user : '+Trim(MailTo) + ' : ' + FormatDateTime('DD-MM-YYYY HH:NN:SS',Now) );
    CloseFile (dosya);
    mainform.StatusBar1.SimpleText:='Cancelled';
    mainform.ToolButton1.ImageIndex:=0;
    Terminate;
    end;

    Sleep( StrToInt(waitsecond)*1000 );

    until eof(dosya);

    CloseFile (dosya);
    mainform.StatusBar1.SimpleText:='All mails finished. You can see logs for more information.';
    mainform.ToolButton1.ImageIndex:=0;

end;


constructor TMyThread.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;


procedure TMyThread.readconfig;
var
okunan, degvar : String;
dosya : TextFile;
begin

//mail gonderme ayarlari okuma
     try
     AssignFile (dosya, 'conf/config');
     Reset(dosya);
     repeat
       ReadLn(dosya, okunan);
       degvar:=Trim(SeparateLeft(okunan, '='));
       //case not supported strings
          if degvar='username' then username:=Trim(SeparateRight(okunan, '='));
          if degvar='password' then password:=Trim(SeparateRight(okunan, '='));
          if degvar='server'   then smtpserver:=Trim(SeparateRight(okunan, '='));
          if degvar='sport' then portnumber:=Trim(SeparateRight(okunan, '='));
          if degvar='wait' then waitsecond:=Trim(SeparateRight(okunan, '='));
          if degvar='mailfrom' then mailfrom:=Trim(SeparateRight(okunan, '='));
     until eof(dosya);
     CloseFile(dosya);
     except
       ShowMessage('Can not read configuration file.');
     end;


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

end;













{ Tmainform }

function Tmainform.GetVolumeID(DriveChar: Char): String;
var
  MaxFileNameLength, VolFlags, SerNum: DWord;
  DrivePath : String;
begin

{$IFDEF WIN32}

  DrivePath :=  DriveChar + ':\';
  if GetVolumeInformation(PChar(DrivePath), nil, 0,
     @SerNum, MaxFileNameLength, VolFlags, nil, 0)
  then
  begin
      Result := IntToStr(SerNum);
  end
  else
      Result := '';
{$ENDIF}

{$IFDEF LINUX}

{$ENDIF}



end;


procedure Tmainform.logwrite(tip, mesaj: String);
var
dosya : TextFile;
begin

     try
     if (tip='error') then AssignFile (dosya, 'logs/errorlog');
     if (tip='send') then AssignFile (dosya, 'logs/sendlog');
     if (tip='prog') then AssignFile (dosya, 'logs/proglog');
     Append(dosya);
     WriteLn(dosya, mesaj);
     CloseFile(dosya);
     except
       ShowMessage('Can not write to log file!');
     end;

end;

procedure Tmainform.ToolButton7Click(Sender: TObject);
begin
  Application.Terminate;
end;


procedure Tmainform.readconfig;
var
okunan, degvar : String;
dosya : TextFile;
begin

//mail gonderme ayarlari okuma
     try
     AssignFile (dosya, 'conf/config');
     Reset(dosya);
     repeat
       ReadLn(dosya, okunan);
       degvar:=Trim(SeparateLeft(okunan, '='));
       //case not supported strings
          if degvar='username' then username:=Trim(SeparateRight(okunan, '='));
          if degvar='password' then password:=Trim(SeparateRight(okunan, '='));
          if degvar='server'   then smtpserver:=Trim(SeparateRight(okunan, '='));
          if degvar='sport' then portnumber:=Trim(SeparateRight(okunan, '='));
          if degvar='wait' then waitsecond:=Trim(SeparateRight(okunan, '='));
          if degvar='mailfrom' then mailfrom:=Trim(SeparateRight(okunan, '='));
     until eof(dosya);
     CloseFile(dosya);
     except
       ShowMessage('Can not read configuration file.');
     end;
     

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


end;




procedure Tmainform.ToolButton1Click(Sender: TObject);
 var
 MyThread : TMyThread;
begin

readconfig;

  if (Edit1.Text='') and (strtoint(databasetype)=0) then
   begin
    showmessage('You must select a mail list file.');
    exit;
   end;

   StatusBar1.SimpleText:='Starting ...';

   if (ToolButton1.ImageIndex=0) then
   begin
        MyThread := TMyThread.Create(True); // With the True parameter it doesn't start automatically
        if Assigned(MyThread.FatalException) then
           raise MyThread.FatalException;

           nowcancel:=false;
           MyThread.Resume;
           ToolButton1.ImageIndex:=5;
   end else
   begin
   if MessageDlg ('Question', 'Process is working. Do you want to cancel?',
                 mtConfirmation, [mbYes, mbNo],0) = mrYes
   then
       begin
        ToolButton1.ImageIndex:=0;
        nowcancel:=True;
        StatusBar1.SimpleText:='Status cancelled';
       end;
   end;


end;




procedure Tmainform.ToolButton2Click(Sender: TObject);
begin
  Application.CreateForm(Tsmtpsettings, smtpsettings);
  smtpsettings.Showmodal;
end;

procedure Tmainform.ToolButton3Click(Sender: TObject);
begin
  Application.CreateForm(Tlogscreen, logscreenunit);
  logscreenunit.Showmodal;
end;

procedure Tmainform.ToolButton4Click(Sender: TObject);
begin

end;

procedure Tmainform.ToolButton5Click(Sender: TObject);
begin
     databasesettings.Showmodal;
end;

procedure Tmainform.ToolButton6Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tmainform.BitBtn1Click(Sender: TObject);
begin
 OpenDialog1.Filter:='*.*|*.*';
 if (OpenDialog1.Execute) then
 Edit1.Text:= OpenDialog1.FileName;
end;

procedure Tmainform.BitBtn2Click(Sender: TObject);
begin
 OpenDialog1.Filter:='';
 if ( OpenDialog1.Execute ) then
 Edit2.Text:= OpenDialog1.FileName;
end;

procedure Tmainform.FormCreate(Sender: TObject);
begin

end;

procedure Tmainform.FormShow(Sender: TObject);
begin
  Readconfig;
  if StrToInt(databasetype)>0 then
     begin
     Edit1.Enabled:=False;
     BitBtn1.Enabled:=False;
     end
     else
     begin
     Edit1.Enabled:=True;
     BitBtn1.Enabled:=True;
     end;


end;

procedure Tmainform.MenuItem4Click(Sender: TObject);
begin
   Application.Terminate;
end;

procedure Tmainform.MenuItem5Click(Sender: TObject);
begin
     Application.CreateForm(Tsmtpsettings, smtpsettings);
     smtpsettings.Show;
end;

procedure Tmainform.MenuItem6Click(Sender: TObject);
begin
     Application.CreateForm(Tabout, about);
     about.Showmodal;
end;

procedure Tmainform.MenuItem8Click(Sender: TObject);
begin
     Application.CreateForm(Tlogscreen, logscreenunit);
     logscreenunit.Showmodal;
end;

procedure Tmainform.MenuItem9Click(Sender: TObject);
begin
     Application.CreateForm(Tdatabasesettings, databasesettings);
     databasesettings.Showmodal;
end;


procedure Tmainform.Timer1Timer(Sender: TObject);
begin
     Application.ProcessMessages;
end;


initialization
{$I unit1.lrs}

end.




