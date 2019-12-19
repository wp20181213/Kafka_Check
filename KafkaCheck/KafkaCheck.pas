unit KafkaCheck;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, ComCtrls, ToolWin, Menus, ExtDlgs,
  ActnList, StdActns, ImgList, System.Actions, Vcl.Mask, strutils, Search, pshare,
  IniFiles, Contnrs, uConstDef, Vcl.Grids, Vcl.DBGrids, AdvObj, BaseGrid,
  AdvGrid, JvExMask, JvToolEdit, JvCombobox, Vcl.CheckLst, ShellAPI, AdvToolBtn;


type
  TKafkaCheckForm = class(TForm)
    ToolBar1: TToolBar;
    ClearGridButton: TSpeedButton;
    OpenFileButton: TSpeedButton;
    ImageList1: TImageList;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    SelDateButton: TSpeedButton;
    paTestContent: TPanel;
    PaTools: TPanel;
    paTestData: TPanel;
    paTestDataCaption: TPanel;
    paWholeData: TPanel;
    asgTestData: TAdvStringGrid;
    laSelStatus: TPanel;
    TestDataStatusBar: TStatusBar;
    StatusBar: TStatusBar;
    paTestResult: TPanel;
    paSelDate: TPanel;
    procedure ActRefreshAsgExecute(Sender: TObject);
    procedure ActOpenFileExcute(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure asgTestDataDblClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure asgTestDataGetCellColor(Sender: TObject; ARow, ACol: Integer;
      AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
    procedure asgTestDataCellBalloon(Sender: TObject; ACol, ARow: Integer;
      var ATitle, AText: string; var AIcon: Integer);
    procedure asgTestDataClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure asgTestDataClickSort(Sender: TObject; ACol: Integer);
    procedure asgTestDataGetColumnFilter(Sender: TObject; Column: Integer;
      Filter: TStrings);

  private
    FStartDate : TDateTime;
    FEndDate : TDateTime;
    FSelType : string;
    //配置文件名
    FTraceIniPath : String;
    FFileNameList : TStringList;
    FsIniFile : TIniFile;
    FFilePath : TStringList;
    FDeviceNameList : TStringList;
    FTestDataList : TStringList;
    FGrepNameList : TStringList;
    //横向展开中排序的列名
    FCrossSortColumnName: String;
    FCurRow : Integer;
    FCurCol : Integer;
    FIndex : string;
    function FindIntAfterSubStr(ASrcStr, ASubStr: string): String;
    function IsNumberic(AStr: string): Boolean;
    function GrepFileByDate(var slFileNameList: TStringList): Boolean;
    function FindStringBetweenKey(ASrc, AStartStr, AEndStr: String): String;
    function FileCreateWithinDate(AFileDate : string) : boolean;
    function FileEditWithinDate(AFileName : string) : boolean;
    function IsDateInSelectDate(AStartDate, AEndDate : TDateTime; ATargetDate: String): Boolean;
    function IsReadIniFile(AIniFile: TIniFile): Boolean;
    function NameOfStrs(AStrs: TStringList; AIndex: integer): string;
    function RowOfNo(AGrid: TAdvStringGrid; const ANo: String): Integer;
    procedure EnumFileInPath(PPath: PChar; AFileExt: string; slFileListInPath:
       TStringlist);
    procedure AddDataToGrid(slDataFile, slGrepNameList: TStringList; AFileName
       : String);
    procedure ClearAsgTestData;
    procedure SetAllColWidth;
    procedure ReadAllFile(slFilePath : TStringList; var slFileList :
       TStringList);
    procedure SetCaption(slVarFieldList : TStringList);
    procedure GetFileList(slFilePath, slFileList: TStringList);
    procedure GetGrepName(slSectionValue : TStringList; var slGrepNameList: TStringList);
    procedure AddIntToGrid(AData, AKey: string; ACol, ARow: Integer);
    procedure AddStrToGrid(AData, AKey: string; ACol, ARow: Integer);
    procedure SetGridNo;
    procedure RefreshCrossSort;
    procedure SetCrossSortColumnName(const Value: String);
    procedure FindNum(ARow : integer);
    procedure ShowSelDate(AStartDate, AEndDate: TDateTime);
    procedure GetSelDate(var AStartDate, AEndDate: TDateTime; var ASelType: string; slTimeOptionList: TStringList);
    procedure SetSelDate(AStartDate, AEndDate: TDateTime; ASelType: string);
    { Private declarations }

  public
    property CrossSortColumnName: String read FCrossSortColumnName write
    SetCrossSortColumnName;
    { Public declarations }
  end;

var
  KafkaCheckForm: TKafkaCheckForm;

implementation

uses pfmSelDate;
{$R *.dfm}

procedure TKafkaCheckForm.AddDataToGrid(slDataFile, slGrepNameList: TStringList; AFileName : String);
var
  i, j, k : Integer;
  l_Col, l_Row : integer;
begin
  with asgTestData do
  begin
    for i := 0 to slDataFile.Count - 1 do
    begin
        l_Row := RowCount - 1;
        for j := 0 to slGrepNameList.Count - 1 do
        begin
          if slDataFile[i].IndexOf(slGrepNameList.Names[j]) <> -1 then
          begin
            l_Col := strtoint(GetAValue(slGrepNameList, slGrepNameList.Names[j], 2));
            case StrToInt(GetAValue(slGrepNameList, slGrepNameList.Names[j], 1)) of
              0 : AddStrToGrid(slDataFile[i], slGrepNameList.Names[j], l_Col, l_Row);
              1 : AddIntToGrid(slDataFile[i], slGrepNameList.Names[j], l_Col, l_Row);
            end;
          end
          else continue
        end;

        for j := 1 to ColCount - 2 do
        begin
          if cells[j, l_Row] <> '' then continue
          else break
        end;

        if j = ColCount - 1 then
        //如果数据齐，给每个数据添加路径，并在后面增加空行
        begin
          cells[ColCount - 1, l_Row] := AFileName;
          for k := i to i + 8 do
          begin
            //如果K的值大于stringlist，那么表示后面没有数据了，跳出
            //否则就把数据按照相应格式记录下来
            if k > slDataFile.Count - 1 then break
            else if (Trim(slDataFile[k]) <> '') then
            begin
              FTestDataList.Add(slDataFile[k]);
            end;
          end;
          RowCount := RowCount + 1;
        end;
    end;
  end;
end;

procedure TKafkaCheckForm.AddIntToGrid(AData, AKey: string; ACol, ARow: Integer);
var
  l_str : string;
begin
  l_str := trim(FindIntAfterSubStr(AData, AKey));
  asgTestData.cells[ACol, ARow] := l_str;
end;

procedure TKafkaCheckForm.AddStrToGrid(AData, AKey: string; ACol, ARow: Integer);
var
  l_str : string;
begin
  l_str := trim(FindStringBetweenKey(AData, AKey, ' '));
  asgTestData.cells[ACol, ARow] := l_str;

  if asgTestData.ColumnHeaders[ACol] = 'Device' then
  begin
    if FDeviceNameList.IndexOf(l_str) = -1 then
      FDeviceNameList.Add(l_str);
  end;
end;

procedure TKafkaCheckForm.asgTestDataCellBalloon(Sender: TObject; ACol,
  ARow: Integer; var ATitle, AText: string; var AIcon: Integer);
var
  i, j : integer;
begin
  with asgTestData do
  begin
    if (ARow < 1) or (ARow > RowCount -1) or (ACol < 0) or (ACol > ColCount - 1)then
    begin
      AText := '';
      exit;
    end
    else if (ACol > 0) and (ACol < ColCount - 1) then
    begin
      for i := 0 to FTestDataList.Count - 1 do
      begin
        for j := 1 to colcount - 1 do
        begin
          if FTestDataList[i].IndexOf(cells[j, ARow]) <> -1 then continue
          else
          begin
            if j = colcount - 1 then
            begin
              ATitle := '实测数据';
              AText := FTestDataList[i+1] + #13 +FTestDataList[i+2];
            end
            else break;
          end;
        end;
      end;
    end
    else
    begin
      ATitle := columnheaders[ACol];
    end;
  end;
end;

procedure TKafkaCheckForm.asgTestDataClickCell(Sender: TObject; ARow,
  ACol: Integer);
begin
  with asgTestData do
  begin
    if ARow < 0 then
      exit;
    if ARow > RowCount - 1 then
      exit;
    if ACol < 0 then
      exit;
    if ACol > ColCount - 1 then
      exit;

    if ARow = 0 then
    begin
      if goRowSelect in Options then
      begin
        Options := Options - [goRowSelect];
      end;
      exit;
    end
    else
    begin
      if ARow <> -1 then
      begin
        if goRowSelect in Options then
          Options := Options - [goRowSelect]
      end;
      FCurCol := ACol;
      FCurRow := ARow;
      FindNum(FCurRow);
      //SelectRange(ACol,ACol,ARow,ARow);
    end;
  end;

end;

procedure TKafkaCheckForm.asgTestDataClickSort(Sender: TObject; ACol: Integer);
begin
  RefreshCrossSort;
end;

procedure TKafkaCheckForm.asgTestDataDblClickCell(Sender: TObject; ARow,
  ACol: Integer);
var
  l_str, l_ExePath : string;
  l_strs : TStringList;
begin
  with asgTestData do
  begin
    if ARow > 0 then
    begin
      if ColumnHeaders[ACol] = G_FilePath then
      begin
        l_strs := TStringList.Create;
        try
          l_str := cells[ACol, ARow];
          FsIniFile.ReadSectionValues('EXEPath', l_strs);
          l_ExePath := GetAValue(l_strs, 'Notepad++', 1);
          ShellExecute(Handle,'open',pchar(l_ExePath),pchar(l_str),'',SW_SHOWNORMAL);
        finally
          l_strs.Free;
        end;
      end
    end;
  end;
end;

procedure TKafkaCheckForm.asgTestDataGetCellColor(Sender: TObject; ARow,
  ACol: Integer; AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
var
  i : integer;
begin
  with asgTestData do
  begin
    if ColumnHeaders[ACol] = G_Device then
      begin
        for i := 0 to FDeviceNameList.Count - 1 do
        begin
          if cells[ACol, ARow] = FDeviceNameList[i] then
          begin
            case i of
              0 : ABrush.Color := clWebLemonChiffon;
              1 : ABrush.Color := clWebLavenderBlush;
              2 : ABrush.Color := clWebAzure;
              3 : ABrush.Color := clWebLavender;
              4 : ABrush.Color := clWebPink;
              5 : ABrush.Color := clMoneyGreen;
              6 : ABrush.Color := clWebWheat;
              7 : ABrush.Color := clWebPaleTurquoise;
              8 : ABrush.Color := clSkyBlue;
              9 : ABrush.Color := clWebCornFlowerBlue;
              10 : ABrush.Color := clWebDodgerBlue;
              11 : ABrush.Color := clWebOrchid;
              12 : ABrush.Color := clWebSalmon;
              13 : ABrush.Color := clWebLightCoral;
              14 : ABrush.Color := clWebGoldenRod;
              15 : ABrush.Color := clWebPeachPuff;
            end;
          end;
        end;
      end;
  end;

end;

procedure TKafkaCheckForm.asgTestDataGetColumnFilter(Sender: TObject;
  Column: Integer; Filter: TStrings);
var
  i :integer;
begin
  if asgTestData.ColumnByHeader(G_Device) <> -1 then
  begin
    if Column = asgTestData.ColumnByHeader(G_Device) then
    begin
      for i := 0 to FDeviceNameList.Count - 1 do
      begin
        Filter.Add(FDeviceNameList[i]);
      end;
      if i = FDeviceNameList.Count then
        Filter.Add('');
    end;
  end;
end;

procedure TKafkaCheckForm.ClearAsgTestData; //清除当前表格上面的数据,保留表头和第一个空行
var
  i : integer;
begin
  with asgTestData do
  begin
    for i := 1 to RowCount - 1 do
    begin
      Rows[i].clear;
    end;
    RemoveRows(2, i - 2);
  end;
end;

procedure TKafkaCheckForm.EnumFileInPath(PPath: PChar; AFileExt: string;
  slFileListInPath: TStringList);
var
  l_searchRec : TSearchRec;
  l_index : Integer;
  l_tmpStr, l_curDir : String;
  l_dir : TQueue;
  popDir : PChar;
begin
  l_dir := TQueue.Create; //创建目录队列
  l_dir.Push(PPath);  //将起始搜索路径入队
  popDir := l_dir.Pop;
  l_curDir := StrPas(popDir); //出队
  try
  {开始遍历,直至队列为空(即没有目录需要遍历)}
    while (True) do
    begin
    //加上搜索后缀,得到类似'c:\*.*' 、'c:\windows\*.*'的搜索路径
      l_tmpStr := l_curDir + '\*.*';
      //在当前目录查找第一个文件、子目录
      l_index := FindFirst(l_tmpStr, faAnyFile, l_searchRec);
      while l_index = 0 do //找到了一个文件或目录后
      begin
        //如果找到的是个目录
        if (l_searchRec.Attr and faDirectory) <> 0 then
        begin
          {在搜索非根目录(C:\、D:\)下的子目录时会出现'.','..'的"虚拟目录"}
          if (l_searchRec.Name <> '.') and (l_searchRec.Name <> '..') then
          begin
            {由于查找到的子目录只有个目录名，所以要添上上层目录的路径
            searchRec.Name = 'Windows';
            tmpStr:='c:\Windows';
            }
            l_tmpStr := l_curDir + '\' + l_searchRec.Name;
              {将搜索到的目录入队。让它先晾着。
            因为TQueue里面的数据只能是指针,所以要把string转换为PChar
            同时使用StrNew函数重新申请一个空间存入数据，否则会使已经进
            入队列的指针指向不存在或不正确的数据(tmpStr是局部变量)。}
            l_dir.Push(StrNew(PChar(l_tmpStr)));
          end;
        end
        else //如果找到的是个文件
        begin
        {Result记录着搜索到的文件数。}
          if AFileExt = '.*' then
          slFileListInPath.Add(l_curDir + '\' + l_searchRec.Name)
          else
          begin
            if SameText(RightStr(l_curDir + '\' + l_searchRec.Name, Length(AFileExt)), AFileExt) then
            slFileListInPath.Add(l_curDir + '\' + l_searchRec.Name);
          end;
        end;
        //查找下一个文件或目录
        l_index := FindNext(l_searchRec);
      end;
        {当前目录找到后，如果队列中没有数据，则表示全部找到了；
          否则就是还有子目录未查找，取一个出来继续查找。}
      if l_dir.Count > 0 then
      begin
        popDir := l_dir.Pop;
        l_curDir := StrPas(popDir);
        StrDispose(popDir);
      end
      else break;
    end;
  finally
    //释放资源
    l_dir.Free;
    FindClose(l_searchRec);
  end;
end;

procedure TKafkaCheckForm.ActOpenFileExcute(Sender: TObject);
var
  i: Integer;
  l_SingleFileContent: TStringlist;
  l_fm : TfmSelDate;
begin
  l_SingleFileContent := TStringList.Create;
  l_fm := TfmSelDate.Create(nil);
  try
    if l_fm.Execute(FStartDate, FEndDate, FSelType) then //打开选择日期的对话框，默认今天
    begin
      AppendLog(G_TraceFilePathDir+'Log\', 'ActOpenFileExcute','start', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');

      ClearAsgTestData;
      FFileNameList.Clear;
      FTestDataList.Clear;

      GetFileList(FFilePath, FFileNameList);
      //从配置文件中读取相应的文件路径，将该路径下所有完整文件名（路径+文件名）放到数组中
      //根据文件名中的日期过滤文件，将不符合日期的完整文件名从数组中删掉
      //l_FileInPath中存放了需要打开文件的地址
      if GrepFileByDate(FFileNameList) then
      begin
        for i := 0 to FFileNameList.Count - 1 do
        //遍历现有每个驱动trc文件目录
        begin
          l_SingleFileContent.LoadFromFile(FFileNameList[i]);
          //FFileNameList[i]为当前文件目录+文件名
          AddDataToGrid(l_SingleFileContent, FGrepNameList, FFileNameList[i]);
        end;
      end;
      if asgTestData.RowCount > 2 then
        asgTestData.RemoveRows(asgTestData.RowCount - 1, 1); //清除最后一个空行
      SetAllColWidth;
      SetGridNo;
      ShowSelDate(FStartDate, FEndDate);
      AppendLog(G_TraceFilePathDir+'Log\', 'ActOpenFileExcute','end', Now,
         formatdatetime('yyyymmdd',now)+ '' +'.log');
    end;
  finally
    l_SingleFileContent.Free;
    l_fm.Free;
  end;
end;

function TKafkaCheckForm.FileCreateWithinDate(AFileDate : string): boolean;
begin
  Result := False;
  if IsDateInSelectDate(FStartDate, FEndDate, AFileDate) then
    Result := True;
end;

function TKafkaCheckForm.FileEditWithinDate(AFileName : string): boolean;
var
  l_FileDate : string;
  l_FileDateTime : TDateTime;
begin
  Result := False;
  FileAge(AFileName, l_FileDateTime);
  l_FileDate := Formatdatetime(FILE_DATE_FORMAT, l_FileDateTime);
  if IsDateInSelectDate(FStartDate, FEndDate, l_FileDate) then
    Result := True;
end;

function TKafkaCheckForm.FindIntAfterSubStr(ASrcStr, ASubStr: string): String;
//返回子字串后面的值，如果为数字，则记录下来，不是则丢弃。
var
  i : Integer;
  l_str, l_FirstStr, l_LastStr : String;
begin
  l_str := '';
  divideStr(ASrcStr, l_FirstStr, l_LastStr, ASubStr, 1);
  l_LastStr := Trim(l_LastStr);
  //l_index := pos(ASubStr, ASrcStr) + length(ASubStr) - 1;//记录ASrcStr最后一位的索引位
  for i := 1 to l_LastStr.Length do
  begin
    if (IsNumberic(l_LastStr[i])) then //如果下一位为整形，则保留，不是则丢弃。
    begin
      l_str := l_str + l_LastStr[i];
      result := l_str;
    end
    else
      exit;
  end;
end;

procedure TKafkaCheckForm.FindNum(ARow : integer);
var
  l_ColIndex : integer;
begin
  with asgTestData do
  begin
    l_ColIndex := ColumnHeaders.IndexOf(G_Number);
    FIndex := cells[l_ColIndex, ARow];
  end;
end;

function TKafkaCheckForm.FindStringBetweenKey(ASrc, AStartStr, AEndStr: String): String;
var
  l_firstStr, l_LastStr : string;
  l_firstStr1, l_LastStr1 : string;
begin
  result := '';
  if dividestr(ASrc, l_firstStr, l_LastStr, AStartStr, 1) then
  begin
    if pos(' ', Trim(l_LastStr)) > 0 then
    begin
      divideStr(Trim(l_LastStr), l_firstStr1, l_LastStr1, AEndStr, 1);
      result := l_firstStr1;
    end
    else
      result := l_LastStr;
  end;
end;

procedure TKafkaCheckForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetSelDate(FStartDate, FEndDate, FSelType);
  Action := caFree;
end;

procedure TKafkaCheckForm.FormCreate(Sender: TObject);
begin
  FFilePath := TStringList.Create;
  FFileNameList := TStringList.Create;
  FDeviceNameList := TStringList.Create;
  FTestDataList := TStringList.Create;
  FGrepNameList := TStringList.Create;
  statusbar1.panels[0].text:='日期：'+datetostr(date());
  statusbar1.panels[1].text:='时间：'+timetostr(time());
  ShowSelDate(0,0);
end;

procedure TKafkaCheckForm.FormDestroy(Sender: TObject);
begin
  FFilePath.Free;
  FFileNameList.Free;
  FDeviceNameList.Free;
  FTestDataList.Free;
  FGrepNameList.Free;
  FsIniFile.Free;
end;

procedure TKafkaCheckForm.FormShow(Sender: TObject);
var
  l_strList : TStringList;
begin
  G_TraceFilePathDir := ExtractFilePath(Application.ExeName); //路径末尾含'\'
  FTraceIniPath := G_TraceFilePathDir + G_TraceFilePath; //TracePath.ini 在当前exe路径下
  if not FileExists(FTraceIniPath) then
  begin
    ShowMessage(FTraceIniPath + '配置文件不存在，请检查！');
    Application.Terminate;
  end;

  FsIniFile := TIniFile.Create(FTraceIniPath);
  l_strList := TStringList.Create;
  try
    if IsReadIniFile(FsIniFile) then
    begin
      FsIniFile.ReadSectionValues('TracePath', FFilePath);

      FsIniFile.ReadSectionValues('TimeOption', l_strList);
      GetSelDate(FStartDate, FEndDate, FSelType, l_strList);

      l_strList.clear;
      FsIniFile.ReadSectionValues('VarField', l_strList);
      SetCaption(l_strList);
      GetGrepName(l_strList, FGrepNameList);
      SetAllColWidth;
    end;
  finally
    l_strList.Free;
  end;
end;

procedure TKafkaCheckForm.GetFileList(slFilePath, slFileList: TStringList);
begin
  //从slFilePath中获取文件夹路径
  //将找到的文件路径列表放到slFileList里面
  if slFilePath.count > 0 then
    begin
      ReadAllFile(slFilePath, slFileList);
      AppendLog(G_TraceFilePathDir+'Log\', 'FormShow','读取仪器trc路径成功', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');
    end
    else
    begin
      AppendLog(G_TraceFilePathDir+'Log\', 'FormShow','异常,读取仪器trc路径失败!请检查配置文件', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');
      ShowMessage('配置文件中没有找到Trc文件所在目录！请检查配置文件。');
      Application.Terminate;
    end;
end;

procedure TKafkaCheckForm.GetGrepName(slSectionValue : TStringList; var slGrepNameList: TStringList);
var
  i : integer;
  l_ValueType, l_Key : string;
begin
  //从 slSectionValue中获取Key，valuetype，根据表头获取ColNumber，传递给 slGrepNameList
  //slGrepNameList的格式为  Key= ValueType，ColNumber
  for i := 0 to slSectionValue.Count - 1 do
  begin
    begin
    l_ValueType := GetAValue(slSectionValue, slSectionValue.Names[i], 2);
    if l_ValueType <> '' then
      begin
        l_Key := GetAValue(slSectionValue, slSectionValue.Names[i], 1);
        slGrepNameList.Values[l_Key] := l_ValueType + ',' + inttostr(
          asgTestData.ColumnByHeader(slSectionValue.Names[i]));
        AppendLog(G_TraceFilePathDir+'Log\', 'GetGrepName',slSectionValue.Names[i] + '的ValueType值为' + l_ValueType+'，加入数据过滤关键词列表', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');
      end
      else
      begin
        AppendLog(G_TraceFilePathDir+'Log\', 'GetGrepName',slSectionValue.Names[i] + '的ValueType值为空，不加入数据过滤关键词列表', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');
        continue;
      end;
    end;
  end;
end;

function TKafkaCheckForm.GrepFileByDate(var slFileNameList: TStringlist): Boolean;
var
  i : Integer;
  l_StrOfName : String;
  l_FirstStr, l_LastStr, l_ConnectStr: string;
  l_FileDate : string;
begin
  Result := false;
  l_ConnectStr := '_';
  for i := slFileNameList.Count - 1 downto 0 do
  begin
    l_StrOfName := ExtractFileName(slFileNameList[i]);
    //使用'_'对文件名进行分割，默认文件名为Pipe0_yyyymmddhhmmsszzzzz.trc；
    if not divideStr(l_StrOfName, l_FirstStr, l_LastStr, l_ConnectStr, 1) then
      exit;
    l_FileDate := copy(l_LastStr, 0, 8);//取文件创建日期
    //如果该文件日期在选择的时间之内，那么保留该文件
    //如果该文件日期不在选择的时间内，从数组中删除该条文件路径
    if FileCreateWithinDate(l_FileDate) or FileEditWithinDate(slFileNameList[i]) then
      continue
    else
      slFileNameList.Delete(i);
  end;

  if slFileNameList = nil then
    Application.MessageBox( '所选时间段内无相应文件，请检查对应文件目录！', '警告', MB_OK + MB_ICONEXCLAMATION)
  else
    Result := True;
end;

function TKafkaCheckForm.IsDateInSelectDate(AStartDate, AEndDate: TDateTime;
  ATargetDate: String): Boolean;
var
  l_StartDate, l_EndDate : string;
begin
  result := false;
  l_StartDate := Formatdatetime(FILE_DATE_FORMAT, AStartDate);
  l_EndDate := Formatdatetime(FILE_DATE_FORMAT, AEndDate);
  if (StrToInt(ATargetDate) >= StrToInt(l_StartDate)) and (StrToInt(ATargetDate) <=
     StrToInt(l_EndDate)) then
     result := true;
end;

function TKafkaCheckForm.IsNumberic(AStr: string): boolean;
//判断后一位字符是否为数字
var
  i : integer;
begin
  result := false;
  for i := 1 to length(AStr) do
  begin
    if not (AStr[i] in ['0'..'9']) then
      Exit
    else
      Result := True;
  end;
end;

procedure TKafkaCheckForm.ReadAllFile(slFilePath: TStringList;
  var slFileList: TStringList);
var
  i : integer;
  l_str : string;
begin
  if slFilePath.Count <> 0 then
    begin
      for i := 0 to slFilePath.Count - 1 do
      begin
        l_str := ValueOfStrs(slFilePath, i);
        EnumFileInPath(PChar(l_str), G_suffix, slFileList); //遍历 l_str路径下所有文件，添加到FFileNameList里
      end;
    end;
end;

procedure TKafkaCheckForm.RefreshCrossSort;
var
  l_row : integer;
begin
  with asgTestData do
  begin
    l_row := RowOfNo(asgTestData, FIndex);
    if l_row <> -1 then
    begin
      Row := l_row;
      Col := FCurcol;
      SetFocus;
      FCurRow := l_row;
    end;
  end;
end;

function TKafkaCheckForm.RowOfNo(AGrid: TAdvStringGrid;
  const ANo: String): Integer;
var
  l_Indexcol, l_Indexrow: Integer;
begin
  Result := -1;
  if not Assigned(AGrid) then
    exit;
  with AGrid do
  begin
    l_Indexcol := ColumnHeaders.IndexOf(G_Number);
    if l_Indexcol = -1 then
      exit;
    for l_Indexrow := 1 to RowCount - 1 do
    begin
      if cells[l_Indexcol, l_Indexrow] = ANo then
      begin
        Result := l_Indexrow;
        exit;
      end;
    end;
  end;
end;

function TKafkaCheckForm.IsReadIniFile(AIniFile: TIniFile): Boolean;
begin
  Result := False;
  if AIniFile = nil then
  begin
    AppendLog(G_TraceFilePathDir+'Log\', 'IsReadIniFile','异常,配置文件为空！', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');
    exit;
  end
  else
  begin
    Result := True;
    AppendLog(G_TraceFilePathDir+'Log\', 'IsReadIniFile','读取配置文件成功！', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');
  end;
end;

function TKafkaCheckForm.NameOfStrs(AStrs: TStringList;
  AIndex: integer): string;
var
  P: integer;
begin
  if (not Assigned(AStrs)) or (AIndex < 0) or (AIndex > AStrs.Count - 1) then
    exit;
  Result := AStrs.Strings[AIndex];
  P := Pos('=', Result);
  if P <> 0 then
  begin
    Delete(Result, P, Length(result)-P+1);
    SetLength(Result, Length(Result));
  end
  else
    SetLength(Result, 0);
end;

procedure TKafkaCheckForm.SetAllColWidth;
begin
  asgTestData.AutoSizeColumns(false, 20);
end;

procedure TKafkaCheckForm.SetCaption(slVarFieldList: TStringList);
var
  i : integer;
  l_strs : TStringList;
begin
  //将slVarFieldList的names取出来作为表头
  l_strs := TStringList.Create;
  try
    for i := 0 to slVarFieldList.Count - 1 do
    begin
      l_strs.Add(NameOfStrs(slVarFieldList, i));
      asgTestData.ColCount := asgTestData.ColCount + 1;
    end;
    asgTestData.ColumnHeaders := l_strs;
    asgTestData.RemoveCols(asgTestData.ColCount - 1, 1);
  finally
    l_strs.Free;
  end;
end;

procedure TKafkaCheckForm.SetCrossSortColumnName(const Value: String);
begin
  FCrossSortColumnName := Value;
end;

procedure TKafkaCheckForm.SetGridNo;
var
  i : integer;
begin
  with asgTestData do
  begin
    if RowCount = 2 then
    begin
      for i := 1 to asgTestData.ColCount - 1 do
      begin
        if cells[i, 1] = '' then continue
        else break;
      end;

      if i = asgTestData.ColCount then
      begin
        exit
      end;
    end;
    AutoNumberCol(0); //产生首列的自动编号
  end;
end;

procedure TKafkaCheckForm.SetSelDate(AStartDate, AEndDate: TDateTime;
  ASelType: string);
begin
  FsIniFile.WriteString('TimeOption', 'TimeMethods', ASelType);
  FsIniFile.WriteDate('TimeOption', 'StartTime', AStartDate);
  FsIniFile.WriteDate('TimeOption', 'EndTime', AEndDate);
end;

procedure TKafkaCheckForm.GetSelDate(var AStartDate, AEndDate: TDateTime; var ASelType: string; slTimeOptionList: TStringList);
var
  l_str : string;
begin
  ASelType := slTimeOptionList.ValueFromIndex[0];
  if ASelType = G_Today then
  begin
    AStartDate := Date;
    AEndDate := Date;
  end
  else
  begin
    AStartDate := strtodatetime(slTimeOptionList.ValueFromIndex[1]);
    AEndDate := strtodatetime(slTimeOptionList.ValueFromIndex[2]);
  end;
end;

procedure TKafkaCheckForm.ShowSelDate(AStartDate, AEndDate: TDateTime);
begin
  if (FStartDate = 0) or (FEndDate = 0) then
  begin
    statusbar.panels[0].Text :='开始日期：未选择';
    statusbar.panels[1].Text :='结束日期：未选择';
  end
  else
  begin
    statusbar.panels[0].Text :='开始日期：' + DateToStr(FStartDate);
    statusbar.panels[1].Text :='结束日期：' + DateToStr(FEndDate);
  end;
  statusbar.panels[0].Width := paSelDate.Width div 2;
  statusbar.panels[1].Width := paSelDate.Width div 2;
end;

procedure TKafkaCheckForm.ActRefreshAsgExecute(Sender: TObject);
var
  i : integer;
  l_SingleFileContent : TStringList;
begin
  AppendLog(G_TraceFilePathDir+'Log\', 'ActRefreshAsgExecute','start', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');

  ClearAsgTestData;
  FFileNameList.Clear;
  FTestDataList.Clear;

  GetFileList(FFilePath, FFileNameList);
  l_SingleFileContent := TStringList.Create;
  try
    //从配置文件中读取相应的文件路径，将该路径下所有完整文件名（路径+文件名）放到数组中
    //根据文件名中的日期过滤文件，将不符合日期的完整文件名从数组中删掉
    //l_FileInPath中存放了需要打开文件的地址
    if GrepFileByDate(FFileNameList) then
    begin
      for i := 0 to FFileNameList.Count - 1 do
      //遍历现有每个驱动trc文件目录
      begin
        l_SingleFileContent.LoadFromFile(FFileNameList[i]);
        //FFileNameList[i]为当前文件目录+文件名
        AddDataToGrid(l_SingleFileContent, FGrepNameList, FFileNameList[i]);
      end;
    end;
  finally
    l_SingleFileContent.Free;
  end;
  if asgTestData.RowCount > 2 then
    asgTestData.RemoveRows(asgTestData.RowCount - 1, 1); //清除最后一个空行
  SetAllColWidth;
  SetGridNo;
  AppendLog(G_TraceFilePathDir+'Log\', 'ActRefreshAsgExecute','end', Now, formatdatetime('yyyymmdd',now)+ '' +'.log');

end;

procedure TKafkaCheckForm.Timer1Timer(Sender: TObject);
begin
  statusbar1.panels[0].text:='日期：'+datetostr(date());
  statusbar1.panels[1].text:='时间：'+timetostr(time());
end;
end.
