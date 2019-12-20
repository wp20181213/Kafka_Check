unit pfmSelDate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, AdvObj, BaseGrid, AdvGrid,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, uConstDef;

type
  TfmSelDate = class(TForm)
    paDate: TPanel;
    PaDateCap: TPanel;
    PaDateAsg: TPanel;
    AsgDate: TAdvStringGrid;
    PaOkCancel: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    procedure AsgDateGetEditorType(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TEditorType);
    procedure AsgDateSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure AsgDateEditChange(Sender: TObject; ACol, ARow: Integer;
      Value: string);
  private
    { Private declarations }
    procedure InitFormView(AStartDate, AEndDate : TDateTime; ASelType : string);
  public
    function Execute(var AStartDate, AEndDate : TDateTime;var ASelType : string) : Boolean;
    procedure SelectDate(var AChooseStartDate, AChooseEndDate : TDateTime; var ASelType :string);
    { Public declarations }
  end;

var
  fmSelDate: TfmSelDate;

const
  FILE_DATE_FORMAT: String ='YYYYMMDD';

implementation

{$R *.dfm}

{ TSelDateDlg }

{ TfmSelDate }

procedure TfmSelDate.AsgDateEditChange(Sender: TObject; ACol, ARow: Integer;
  Value: string);
begin
  with AsgDate do
  begin
    if value = g_Today then
    begin
      cells[1, 1] := datetostr(Date);
      cells[1, 2] := datetostr(Date);
      //AsgDate.Refresh;
    end;
  end;
end;

procedure TfmSelDate.AsgDateGetEditorType(Sender: TObject; ACol, ARow: Integer;
  var AEditor: TEditorType);
begin
  case ARow of
    0 :
      AEditor := edComboList;
    1, 2:
      AEditor := edDateEdit;
      //AEditor := edDateTimeEdit;
      //todo 修改过滤函数
  end;
end;

procedure TfmSelDate.AsgDateSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  with AsgDate do
  begin
    case ARow of
      0:
        begin
          ClearComboString;
          AddComboString(g_Today);
          AddComboString(g_Customize);
        end;
    end;
    if Cells[1, 0] = g_Today then
    begin
      if ARow in [1, 2] then
        options := options - [goEditing]
      else
        options := options + [goEditing];
    end;

  end;
end;

function TfmSelDate.Execute(var AStartDate, AEndDate : TDateTime;var ASelType : string): Boolean;
begin
  Result := False;
  InitFormView(AStartDate, AEndDate, ASelType);
  case ShowModal of
    mrOk:
    begin
      SelectDate(AStartDate, AEndDate, ASelType); //确定起始日期
      Result := true;
    end;
  end;
end;

procedure TfmSelDate.SelectDate(var AChooseStartDate, AChooseEndDate: TDateTime; var ASelType :string);
var
  l_StartDate, l_EndDate : string;
begin
  if AsgDate.Cells[1, 0] = g_Today then
  begin
    AChooseStartDate := Date;
    AChooseEndDate := Now;
  end
  else
  begin
    AChooseStartDate := StrToDate(AsgDate.Cells[1, 1]);
    AChooseEndDate := StrToDateTime(AsgDate.Cells[1, 2]);
  end;
  ASelType := AsgDate.Cells[1, 0];
  l_StartDate := Formatdatetime(FILE_DATE_FORMAT, AChooseStartDate);
  l_EndDate := Formatdatetime(FILE_DATE_FORMAT, AChooseEndDate);
  if l_StartDate > l_EndDate then
  begin
    //ShowMessage('开始时间大于截止时间，请重新选择！');
    Application.MessageBox( '开始时间大于截止时间，请重新选择！', '警告', MB_OK + MB_ICONEXCLAMATION);
    abort;
  end;
end;

procedure TfmSelDate.InitFormView(AStartDate, AEndDate : TDateTime; ASelType : string);
begin
  with AsgDate do
  begin
    Cells[0, 0] := '选择方式';
    Cells[0, 1] := g_StartDate;
    Cells[0, 2] := g_EndDate;

    if (ASelType = '') or (ASelType = g_Today) then
    begin
      Cells[1, 0] := g_Today;
      Cells[1, 1] := DateToStr(now);
      Cells[1, 2] := DateToStr(now);
    end
    else
    begin
      Cells[1, 0] := g_Customize;
      Cells[1, 1] := DateToStr(AStartDate);
      Cells[1, 2] := DateToStr(AEndDate);
    end;
  end;
end;

end.
