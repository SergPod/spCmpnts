unit spFormPlacement;

{
Provides simple class TAppFormIniFile on base TWinIni in order to replace
the D5 Rx FormPlacement and Lazarus TIniPropStorage Lazarus components.
 It has functions to save (Put) and restore (Get) TForm size (Width, Height)
or size and position (Left, Top) and Scaled), it does not use float & round
while screen sizes are the same when Put and Get. So it is stable for many
Put/Get cycles. If Screen sizes is different on Get/Put then Form's position
Form's size are recalculated, get = round(put*(sget/sput)).
When WindowState=wsMaximized the size and position are not saved.
 It has functions to save/restore (InitialDir & Filename) for TOpenDialog
and InitialDir for TSaveDialog=class(TOpenDialog) by method PutOSDlgPath
GetOSDlgPath(const Dlg). It saves InitalDir & File in the Owner section
 Also we can use it to save/restore other values we need in the same
way as TWinIni.
 cosntructor TAppFormIniFile.Create(FN:string) creates ini file with FN
as full file name Or if FN='' then creates ini file app_exe_name.ini in
app folder. Notice, TAppFormIniFile will be auto closed/destroyed in
finalization unit section if it has not be freed by Free() inside the
program which creates it.

Define global var AppIniFile: TAppFormIniFile typicaly it will be created
in OnCreate for the main form of app (and each app form can use it than).
}
{:}
{ ********************************************************************** }
{   Created by: ׁ.ֿ.ֿמהתÿקוג  S.P.Podyachev 22.02.2021                   }
{   Last update: 24.05.2021                                              }
{ ********************************************************************** }

interface

uses
  Windows, SysUtils, Classes, IniFiles, Forms, Dialogs;

type

  TAppFormIniFile = class(TINIFile)
  protected
    //FFlag: integer; let be simple
    procedure PutFormPos(const Form: TForm);
    procedure GetFormPos(const Form: TForm);
    procedure PutFormSize(const Form: TForm);
    procedure GetFormSize(const Form: TForm);
    function GetCtlOwnerName(const Ctl: TComponent): string;
  public
    constructor Create(FN: string);
    destructor Destroy; override;
    procedure PutFormPosSize(const Form: TForm);
    procedure GetFormPosSize(const Form: TForm);
    procedure PutOSDlgPath(const Dlg: TOpenDialog);
    procedure GetOSDlgPath(const Dlg: TOpenDialog);
    //note: TSaveDialog = class(TOpenDialog)
  end;


var
  AppIniFile: TAppFormIniFile;

implementation

const
  FPosition = 1;
  MAX_PATH = 512;

function GetAppDataFolder: string;  //Windows
var
  sVal: array [0..MAX_PATH] of char;
  sKey: string;
begin
  sKey := 'APPDATA';
  GetEnvironmentVariable(PChar(sKey), sVal, MAX_PATH);
  Result := string(sVal);
end;

{return full name to the app ini file name
 todo  change for user appdata folder }
function GetDfltPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
  {or
   Result:= IncludeTrailingBackslash(GetAppDataFolder)}
end;

function GetDfltName: string;
begin
  Result := ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini');
end;

function GetFromStr(S: string; var Int1, Int2: integer): boolean;
var
  bp, er: integer;
begin
  Result := False;
  S := Trim(S);
  if length(S) < 3 then
    Exit;             // '7:9'
  bp := Pos(':', S);  // position
  if (bp = 0) then
    Exit;
  Val(Trim(Copy(S, 1, bp - 1)), Int1, er);
  if er > 0 then
    Exit;

  S := Trim(Copy(S, bp + 1, length(S)));
  bp := Pos(' ', S);  //blank position
  if (bp > 0) then
    S := Copy(S, 1, bp);
  Val(S, Int2, er);
  if er > 0 then
    Exit;
  Result := True;
end;

{ TAppFormIniFile }

var
  AFIF_List: TList;

{create IniFile with full name FN, if FN='', then use Application.ExeName
 and insert it to auto delete list}

constructor TAppFormIniFile.Create(FN: string);
begin
  if FN = '' then
    FN := GetDfltName;
  FN := GetDfltPath + FN;
  inherited Create(FN);
  AFIF_List.Add(self);
end;

destructor TAppFormIniFile.Destroy;
begin
  AFIF_List.Remove(Self);
  inherited;
end;

procedure TAppFormIniFile.PutFormPos(const Form: TForm);
var
  S: string;
begin
  with Form do
    if WindowState <> wsMaximized then
      try
        S := Format('%d:%d', [Left, Screen.Width]);
        WriteString(Name, 'Left', S); //const Section, Ident, Value: string)
        S := Format('%d:%d', [Top, Screen.Height]);
        WriteString(Name, 'Top', S); //const Section, Ident, Value: string)
      except
        //do nothing
      end;
end;

procedure TAppFormIniFile.GetFormPos(const Form: TForm);
var
  vs: string;
  frmv, scrv: integer;
begin
  with Form do
  begin
    vs := ReadString(Name, 'Left', '');//(Section, Ident, Default)
    if GetFromStr(vs, frmv, scrv) then
    begin
      if (scrv <> Screen.Width) then
        frmv := round(frmv * (Screen.Width / scrv));
      if (frmv > Screen.Width) then
        frmv := Screen.Width div 5;
      Left := frmv;
    end
    else
      Exit;
    vs := ReadString(Name, 'Top', '');
    if GetFromStr(vs, frmv, scrv) then
    begin
      if (scrv <> Screen.Height) then
        frmv := round(frmv * (Screen.Height / scrv));
      Top := frmv;
    end;
  end;
end;

procedure TAppFormIniFile.PutFormSize(const Form: TForm);
var
  S: string;
begin
  with Form do
    if WindowState <> wsMaximized then
      try
        S := Format('%d:%d', [Width, Screen.Width]);
        WriteString(Name, 'Width', S); //const Section, Ident, Value: string)
        S := Format('%d:%d', [Height, Screen.Height]);
        WriteString(Name, 'Height', S); //const Section, Ident, Value: string)
      except
        //do nothing
      end;
end;

procedure TAppFormIniFile.GetFormSize(const Form: TForm);
var
  vs: string;
  frmv, scrv: integer;
begin
  with Form do
  begin
    vs := ReadString(Name, 'Width', '');
    if GetFromStr(vs, frmv, scrv) then
      with Form do
      begin
        if (scrv <> Screen.Width) and not Scaled then
          frmv := round(frmv * (Screen.Width / scrv));
        Width := frmv;
      end
    else
      Exit;
    vs := ReadString(Name, 'Height', '');
    if GetFromStr(vs, frmv, scrv) then
      with Form do
      begin
        if (scrv <> Screen.Height) and not Scaled then
          frmv := round(frmv * (Screen.Height / scrv));
        Height := frmv;
      end;
  end;
end;

procedure TAppFormIniFile.PutFormPosSize(const Form: TForm);
begin
  if not Assigned(Form) then
    Exit;
  WriteBool(Form.Name, 'Scaled', Form.Scaled);
  WriteInteger(Form.Name, 'PixelsPerInch', Form.PixelsPerInch);
  PutFormPos(Form);
  PutFormSize(Form);
end;

procedure TAppFormIniFile.GetFormPosSize(const Form: TForm);
begin
  if not Assigned(Form) then
    Exit;
  GetFormPos(Form);
  GetFormSize(Form);
  Form.PixelsPerInch := ReadInteger(Form.Name, 'PixelsPerInch', Form.PixelsPerInch);
  Form.Scaled := ReadBool(Form.Name, 'Scaled', Form.Scaled);
end;


const
  sDir = '_InitialDir';
  sFN = '_FileName';
  sNoOwner = 'WithoutOwner';

function TAppFormIniFile.GetCtlOwnerName(const Ctl: TComponent): string;
  // By default, a form owns all components that are on it. In turn, the form
  // is owned by the application. It is not clear with Frame
var
  Owner: TComponent;
  d: byte;
begin
  d := 0;
  Owner := Ctl.Owner;
  while (Owner <> nil) and (d < 7) do  //just for safe
  begin
    if Owner is TForm then
      break;
    Owner := Owner.Owner;
    Inc(d);
  end;
  if Owner <> nil then
    Result := Owner.Name
  else
    Result := sNoOwner;
end;

//Save & restore InitalDir & File in Owner section
procedure TAppFormIniFile.GetOSDlgPath(const Dlg: TOpenDialog);
var
  Sect: string;
begin
  if Assigned(Dlg) then
  begin
    Sect := GetCtlOwnerName(Dlg);
    //const Section, Ident, DefaultValue: string)
    Dlg.InitialDir := ReadString(Sect, Dlg.Name + sDir, Dlg.InitialDir);
    if not (Dlg is TSaveDialog) then  // TSaveDialog = class(TOpenDialog)
      Dlg.FileName := ReadString(Sect, Dlg.Name + sFN, Dlg.FileName);
  end;
end;

procedure TAppFormIniFile.PutOSDlgPath(const Dlg: TOpenDialog);
var
  Sect: string;
begin
  if Assigned(Dlg) then
    try
      Sect := GetCtlOwnerName(Dlg);
      //const Section, Ident, Value: string)
      WriteString(Sect, Dlg.Name + sDir, Dlg.InitialDir);
      if not (Dlg is TSaveDialog) then
        WriteString(Sect, Dlg.Name + sFN, Dlg.FileName);
    except
      //do nothing
    end;
end;

procedure FreeList;
begin
  if Assigned(AFIF_List) then
  begin
    while AFIF_List.Count > 0 do
      TAppFormIniFile(AFIF_List.Last).Free; //it removes itself from list
    AFIF_List.Free;
  end;
end;


initialization
  AFIF_List := TList.Create;


finalization
  FreeList;

end.
