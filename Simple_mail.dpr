program Simple_mail;

uses
  Forms,
  SendForm in 'SendForm.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
