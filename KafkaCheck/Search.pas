unit Search;

interface
uses
  SysUtils, StdCtrls, Dialogs, StrUtils;

function SearchMemo(Memo: TCustomEdit; const SearchString: string; Options:
   TFindOptions): Boolean;

implementation

function SearchMemo(Memo: TCustomEdit; const SearchString: string; Options: TFindOptions): Boolean;
var
  Buffer, P: PChar;
  Size: Word;
begin
  Result := False;
  if Length(SearchString) = 0 then
    Exit;

  Size := Memo.GetTextLen;
  if (Size = 0) then
    Exit;

  Buffer := SysUtils.StrAlloc(Size + 1);
  try
    Memo.GetTextBuf(Buffer, Size + 1);

    if frDown in Options then
      P := SearchBuf(Buffer, Size, Memo.SelStart, Memo.SelLength,SearchString, [soDown])

    else
      P := SearchBuf(Buffer, Size, Memo.SelStart, Memo.SelLength,SearchString, []);

    if (frMatchCase in Options) then
      P := SearchBuf(Buffer, Size, Memo.SelStart, Memo.SelLength, SearchString,[soMatchCase]);

    if (frWholeWord in Options) then
      P := SearchBuf(Buffer, Size, Memo.SelStart, Memo.SelLength, SearchString,[soWholeWord]);

    if P <> nil then
    begin
      Memo.SelStart := P - Buffer;
      Memo.SelLength := Length(SearchString);
      Result := True;
    end;

  finally
    SysUtils.StrDispose(Buffer);
  end;
end;

end.
