unit SendForm;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls,
  IdComponent, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTP, IdBaseComponent, IdMessage;

type
  TMainForm = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    eName: TEdit;
    Label2: TLabel;
    eSubject: TEdit;
    Label3: TLabel;
    BbtnAddToList: TButton;
    ListAddr: TListBox;
    BtnRemove: TButton;
    Label5: TLabel;
    eFrom: TEdit;
    BtnSendAll: TButton;
    eServer: TEdit;
    MailMessage: TIdMessage;
    Mail: TIdSMTP;
    Label4: TLabel;
    Label6: TLabel;
    eUserName: TEdit;
    Password: TLabel;
    ePassword: TEdit;
    reMessageText: TRichEdit;
    ListLog: TListBox;
    Label7: TLabel;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnSendAllClick(Sender: TObject);
    procedure BbtnAddToListClick(Sender: TObject);
    procedure BtnRemoveClick(Sender: TObject);
    procedure MailConnected(Sender: TObject);
    procedure MailDisconnected(Sender: TObject);
    procedure MailStatus(axSender: TObject; const axStatus: TIdStatus;
      const asStatusText: String);
    procedure MailWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCountMax: Integer);
    procedure MailWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
  private
    FileName: string;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
 Application.Title:='Simple Mail';
 // load the list of addresses
 FileName:=ChangeFileExt(Application.ExeName, '.txt');
 try
  ListAddr.Items.LoadFromFile(FileName);
 except
  ListAddr.Items.SaveToFile(FileName);
 end;
 ListLog.Clear;
 ListLog.Items.Add('Addresses: '+IntToStr(ListAddr.Items.Count));
 // select the first item
 ListAddr.ItemIndex:=0;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 // save the list of addresses
 ListAddr.Items.SaveToFile(FileName);
end;

const
  BccInMsg = 30;

procedure TMainForm.BtnSendAllClick(Sender: TObject);
var
 nItem: integer;
 Res: Word;
begin
 if ListAddr.Items.Count=0
 then
  begin
   ShowMessage('Список получателей пуст!');
   Exit;
  end;
 //
 Res:=MessageDlg('Start sending from item '+
   IntToStr(ListAddr.ItemIndex+1)+' ('+
   ListAddr.Items [ListAddr.ItemIndex]+')?'#13+
   'Или не начинать с первого адреса.', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
 if Res=mrCancel
 then Exit;
 if Res=mrYes
 then nItem:=ListAddr.ItemIndex // рассылка адреса ItemIndex
 else nItem:=0; // рассылка с первого адреса в списке
 // connect
 Mail.Host:=eServer.Text; // хост
 Mail.Username:=eUserName.Text; // имя пользователя
 if ePassword.Text<>''
 then
  begin
   Mail.Password:=ePassword.Text; // пароль
   Mail.AuthenticationType:=atLogin; // тип аутентификации
  end;
 Mail.Connect;
 // send the messages, one by one, prepending a custom message
 try
  // set the fixed part of the header
  MailMessage.From.Name:=eFrom.Text; // от кого
  MailMessage.Subject:=eSubject.Text; // тема сообщения
  MailMessage.Body.SetText(reMessageText.Lines.GetText);
  MailMessage.Body.Insert(0,'Hello!');
  while nItem<ListAddr.Items.Count do
   begin
    // show the current selection
    Application.ProcessMessages;
    ListAddr.ItemIndex:=nItem;
    MailMessage.Body[0]:='Hello "'+ListAddr.Items[nItem]+'"!';
    MailMessage.Recipients.EMailAddresses:=ListAddr.Items[nItem];
    Mail.Send(MailMessage);
    inc(nItem);
   end;
 finally
  Mail.Disconnect;
 end;
end;

procedure TMainForm.BbtnAddToListClick(Sender: TObject);
begin
 ListAddr.ItemIndex:=ListAddr.Items.Add(eName.Text);
 ListLog.Clear;
 ListLog.Items.Add('Addresses: '+IntToStr(ListAddr.Items.Count)); 
end;

procedure TMainForm.BtnRemoveClick(Sender: TObject);
begin
 // copy the item to the name edit box and remove it
 eName.Text:=ListAddr.Items[ListAddr.ItemIndex];
 ListAddr.Items.Delete(ListAddr.ItemIndex);
 ListLog.Clear;
 ListLog.Items.Add('Addresses: '+IntToStr(ListAddr.Items.Count));
end;

procedure TMainForm.MailConnected(Sender: TObject);
begin
 ListLog.Items.Add('Connected to host...');
end;

procedure TMainForm.MailDisconnected(Sender: TObject);
begin
 ListLog.Items.Add('Disconnected from host...');
end;

procedure TMainForm.MailStatus(axSender: TObject;
  const axStatus: TIdStatus; const asStatusText: String);
begin
 ListLog.Items.Add(asStatusText);
end;

procedure TMainForm.MailWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCountMax: Integer);
begin
 ListLog.Items.Add('Sending to: '+MailMessage.Recipients.EMailAddresses);
end;

procedure TMainForm.MailWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
 ListLog.Items.Add('Done...');
end;

end.
