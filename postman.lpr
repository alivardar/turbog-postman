program postman;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  , unit1, smtpset, aboutscreen, logscreen, SQLDBLaz, Unit2, zcomponent;

{$IFDEF WINDOWS}{$R postman.rc}{$ENDIF}

begin
  Application.Title:='Postman ';
  //Application.Icon:=;
  Application.Initialize;
  Application.CreateForm(Tmainform, mainform);
  Application.CreateForm(Tabout, about);
  Application.CreateForm(Tdatabasesettings, databasesettings);
//  Application.CreateForm(Tsmtpsettings, smtpsettings);
//  Application.CreateForm(Tmysqlsettings, mysqlsettings);
  Application.Run;
end.

