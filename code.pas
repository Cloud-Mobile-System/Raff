var 
  MyForm:TclForm;
  BtnCekilisYap:TclButton;
  LblDisplay:TclLabel;
  MyMQTT : TclMQTT;
  QMemList:TclJSonQuery;
  MemberList:TclMemo;
  CekilisTimer:TClTimer;
  LblLyt : TclLayout;
  
  Procedure MyMQTTPublishReceived;
  begin
    If Not Clomosy.PlatformIsMobile Then //WINDOWS ISE
    begin
      //If MyMQTT.ReceivedAlright Then
        //LblDisplay.Caption :=  MyMQTT.ReceivedMessage;
      If CekilisTimer.Enabled And (MyMQTT.ReceivedMessage = 'durdur') Then
      begin
        CekilisTimer.Enabled := False;
        BtnCekilisYap.Caption := 'Devam et';
        LblDisplay.Caption := QMemList.FieldByName('Member_Name').AsString;
        Clomosy.SendNotification('Tebrikler ',LblDisplay.Caption + ' Kazandınız',QMemList.FieldByName('Member_GUID').AsString);
        MyMQTT.Send('Talihli:'+ LblDisplay.Caption + ' ('+QMemList.FieldByName('Member_GUID').AsString+')');
      End;
    End Else //WIN DEGILSE
    begin
      If POS('Talihli:',MyMQTT.ReceivedMessage)>0 Then
        LblDisplay.Caption :=  'Kazanan Talihli' + MyMQTT.ReceivedMessage;
    End;
  End;
  
  
  Procedure BtnCekilisYapClick;
  Begin
    MyMQTT.Send('durdur');
  End;
  
  Procedure ProcOnCekilisTimer;
  begin
    LblDisplay.Caption := QMemList.FieldByName('Member_Name').AsString;
    Clomosy.ProcessMessages;
    QMemList.Next;
    If QMemList.EOF Then QMemList.First;
  End;
  
  procedure BtnIsimKatistirClick;
  Begin
    If Not CekilisTimer.Enabled Then 
      QMemList := Clomosy.DBCloudQueryWith(ftMembers,'','1=1 ORDER BY NEWID()');//her seferinde karışık member listesi al
    CekilisTimer.Enabled := Not CekilisTimer.Enabled;
    LblDisplay.Caption := '';
    //LblDisplay.Visible := CekilisTimer.Enabled;
    If CekilisTimer.Enabled Then BtnCekilisYap.Caption := 'Bekle' Else BtnCekilisYap.Caption := 'Devam et';
  End;
begin
  MyForm := TclForm.Create(Self);
  MyForm.SetFormBGImage('https://clomosy.com/theme/SurveyStyle4.png');
  
  LblLyt := MyForm.AddNewLayout(MyForm,'LblLyt');
  LblLyt.Width := 100;
  LblLyt.Height := 100;
  LblLyt.Align := alTop;

  
  LblDisplay:= MyForm.AddNewLabel(LblLyt,'LblDisplay','ÇEKİLİŞ UYGULAMASI');
  LblDisplay.StyledSettings := ssFamily;
  LblDisplay.TextSettings.Font.Size := 16;
  LblDisplay.Align := alCenter;
  LblDisplay.Width := LblDisplay.Width*3;
  LblDisplay.Visible := True;
  LblDisplay.Height := LblDisplay.Height*3;//yazılar uzun gelebildiği için
  LblDisplay.TextSettings.FontColor := clAlphaColor.clHexToColor('#ffffff');


  MyMQTT := MyForm.AddNewMQTTConnection(MyForm,'MyMQTT');
  MyForm.AddNewEvent(MyMQTT,tbeOnMQTTPublishReceived,'MyMQTTPublishReceived');
  MyMQTT.Channel := 'cekilis';//project guid + channel
  MyMQTT.Connect;
   
  If Clomosy.PlatformIsMobile Then 
  begin
    If Clomosy.AppUserProfile=1 Then //mobilde Yonetici ise
    Begin
      LblDisplay.Caption := 'Talihli Kişiyi Belirlemek için Ekranda İsimler Geçmeye Başlayınca Aşağıdaki Butona Basın';
      //BtnCekilisYap:= MyForm.AddNewButton(MyForm,'BtnCekilisYap','Çekilişi Yap');
      //BtnCekilisYap.Height := BtnCekilisYap.Height * 3;
      //BtnCekilisYap.Width := BtnCekilisYap.Width * 3;
      //BtnCekilisYap.Align := alCenter;
      
      
      BtnCekilisYap := MyForm.AddNewProButton(MyForm,'BtnCekilisYap','');
      clComponent.SetupComponent(BtnCekilisYap,'{"caption":"Çekilişi Yap","Align" : "Center",
      "Width" :'+IntToStr(BtnCekilisYap.Width * 3)+', 
      "Height":'+IntToStr(BtnCekilisYap.Height * 3)+',
      "RoundHeight":8,
      "RoundWidth":8,
      "BorderColor":"#ff0000",
      "BorderWidth":2}');
      
      MyForm.AddNewEvent(BtnCekilisYap,tbeOnClick,'BtnCekilisYapClick');
      
    End Else 
    Begin//mobilde talihli adayı ise
      LblDisplay.Caption := 'Talihli Kişi Bekleniyor';
      LblDisplay.Align := alClient;
    End;
  
  End Else 
  begin//windows ekran ise
    //BtnCekilisYap:= MyForm.AddNewButton(MyForm,'BtnCekilisYap','Başlat');
    //BtnCekilisYap.Align := alCenter;
    
    
     BtnCekilisYap := MyForm.AddNewProButton(MyForm,'BtnCekilisYap','');
      clComponent.SetupComponent(BtnCekilisYap,'{"caption":"Başlat","Align" : "Center",
      "RoundHeight":8,
      "RoundWidth":8,
      "BorderColor":"#ff0000",
      "BorderWidth":2}');
      
    MyForm.AddNewEvent(BtnCekilisYap,tbeOnClick,'BtnIsimKatistirClick');
    
    QMemList := Clomosy.DBCloudQueryWith(ftMembers,'','1=1 ORDER BY NEWID()');//her seferinde karışık member listesi al
    CekilisTimer:= MyForm.AddNewTimer(MyForm,'CekilisTimer',1000);
    CekilisTimer.Interval := 100;//100 milisaniye aralıklarla 
    CekilisTimer.Enabled := False;
    //LblDisplay.Visible := False;
    QMemList.First;
    MyForm.AddNewEvent(CekilisTimer,tbeOnTimer,'ProcOnCekilisTimer');
     
  End;
  
  MyForm.Run;
  
End;  
