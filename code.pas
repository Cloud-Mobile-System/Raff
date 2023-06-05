var 
  MyForm:TclForm;
  btnRaffEvent:TclButton;
  LblDisplay:TclLabel;
  MyMQTT : TclMQTT;
  QMemList:TclJSonQuery;
  MemberList:TclMemo;
  raffTimer:TClTimer;
  LblLyt : TclLayout;
  
  Procedure MyMQTTPublishReceived;
  begin
    If Not Clomosy.PlatformIsMobile Then 
    begin
      If raffTimer.Enabled And (MyMQTT.ReceivedMessage = 'Stop') Then
      begin
        raffTimer.Enabled := False;
        btnRaffEvent.Caption := 'Continue';
        LblDisplay.Caption := QMemList.FieldByName('Member_Name').AsString;
        Clomosy.SendNotification('Congratulations ',LblDisplay.Caption + ' You win',QMemList.FieldByName('Member_GUID').AsString);
        MyMQTT.Send('Fortunate:'+ LblDisplay.Caption + ' ('+QMemList.FieldByName('Member_GUID').AsString+')');
      End;
    End Else //WIN DEGILSE
    begin
      If POS('Fortunate:',MyMQTT.ReceivedMessage)>0 Then
        LblDisplay.Caption :=  'Winner Fortunate' + MyMQTT.ReceivedMessage;
    End;
  End;
  
  
  Procedure btnRaffEventClick;
  Begin
    MyMQTT.Send('Stop');
  End;
  
  Procedure ProcOnraffTimer;
  begin
    LblDisplay.Caption := QMemList.FieldByName('Member_Name').AsString;
    Clomosy.ProcessMessages;
    QMemList.Next;
    If QMemList.EOF Then QMemList.First;
  End;
  
  procedure BtnNameMixingClick;
  Begin
    If Not raffTimer.Enabled Then 
      QMemList := Clomosy.DBCloudQueryWith(ftMembers,'','1=1 ORDER BY NEWID()');
    raffTimer.Enabled := Not raffTimer.Enabled;
    LblDisplay.Caption := '';
    //LblDisplay.Visible := raffTimer.Enabled;
    If raffTimer.Enabled Then btnRaffEvent.Caption := 'Wait' Else btnRaffEvent.Caption := 'Continue';
  End;
begin
  MyForm := TclForm.Create(Self);
  MyForm.SetFormBGImage('https://clomosy.com/theme/SurveyStyle4.png');
  
  LblLyt := MyForm.AddNewLayout(MyForm,'LblLyt');
  LblLyt.Width := 100;
  LblLyt.Height := 100;
  LblLyt.Align := alTop;

  
  LblDisplay:= MyForm.AddNewLabel(LblLyt,'LblDisplay','Raff Application');
  LblDisplay.StyledSettings := ssFamily;
  LblDisplay.TextSettings.Font.Size := 16;
  LblDisplay.Align := alCenter;
  LblDisplay.Width := LblDisplay.Width*3;
  LblDisplay.Visible := True;
  LblDisplay.Height := LblDisplay.Height*3;
  LblDisplay.TextSettings.FontColor := clAlphaColor.clHexToColor('#ffffff');


  MyMQTT := MyForm.AddNewMQTTConnection(MyForm,'MyMQTT');
  MyForm.AddNewEvent(MyMQTT,tbeOnMQTTPublishReceived,'MyMQTTPublishReceived');
  MyMQTT.Channel := 'raf';
  MyMQTT.Connect;
   
  If Clomosy.PlatformIsMobile Then 
  begin
    If Clomosy.AppUserProfile=1 Then 
    Begin
      LblDisplay.Caption := 'Press the button below when the names start to appear on the screen to determine the lucky person.';
      btnRaffEvent := MyForm.AddNewProButton(MyForm,'btnRaffEvent','');
      clComponent.SetupComponent(btnRaffEvent,'{"caption":"Make Raff","Align" : "Center",
      "Width" :'+IntToStr(btnRaffEvent.Width * 3)+', 
      "Height":'+IntToStr(btnRaffEvent.Height * 3)+',
      "RoundHeight":8,
      "RoundWidth":8,
      "BorderColor":"#ff0000",
      "BorderWidth":2}');
      
      MyForm.AddNewEvent(btnRaffEvent,tbeOnClick,'btnRaffEventClick');
      
    End Else 
    Begin//mobilde talihli adayı ise
      LblDisplay.Caption := 'Waiting For The Lucky Person';
      LblDisplay.Align := alClient;
    End;
  
  End Else 
  begin
    
     btnRaffEvent := MyForm.AddNewProButton(MyForm,'btnRaffEvent','');
      clComponent.SetupComponent(btnRaffEvent,'{"caption":"Start","Align" : "Center",
      "RoundHeight":8,
      "RoundWidth":8,
      "BorderColor":"#ff0000",
      "BorderWidth":2}');
      
    MyForm.AddNewEvent(btnRaffEvent,tbeOnClick,'BtnNameMixingClick');
    QMemList := Clomosy.DBCloudQueryWith(ftMembers,'','1=1 ORDER BY NEWID()');
    raffTimer:= MyForm.AddNewTimer(MyForm,'raffTimer',1000);
    raffTimer.Interval := 100;
    raffTimer.Enabled := False;
    QMemList.First;
    MyForm.AddNewEvent(raffTimer,tbeOnTimer,'ProcOnraffTimer');
     
  End;
  
  MyForm.Run;
  
End
