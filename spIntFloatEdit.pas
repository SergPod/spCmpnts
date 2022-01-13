unit spIntFloatEdit;
{
Hystorically (199x) I used TSpinEdit and TRxSpinEdit based on the VCL unit Spin.
TSpinEdit was installed on Sample tab of Delphi IDE. It makes difficult migration 
to Lazarus and Delphi where Rx components were not avaialable. 
On base TSpinEdit I've created 3 Numerical EditLine
TIntSpinEdit (like TSpinEdit in Delphi and Lazarus)
TFloatSpinEdit (like TFloatSpinEdit in Lazarus)
TExtSpinEdit (like TRxSpinEdit )

spIntFloatEdit.pas can be used in the Delphi 10.3 (uses spIntFloatEdit)
proting code to Delphi without Rx library we need replace in code 
  TRxSpinEdit by TExtSpinEdit

porting code to Lazarus we need replace in code 
  spIntFloatEdit by Spin in "uses" sections (uses Spin)
  TIntSpinEdit by TSpinEdit see also //$DEFINE FS_DECIMAL }

{:}
{ ********************************************************************** }
{   Created by: ׁ.ֿ.ֿמהתÿקוג  S.P.Podyachev                              }
{   Last update: 24.05.2021                                              }
{ ********************************************************************** }

interface

uses Windows, SysUtils,  Controls, ExtCtrls,
     Classes, Graphics, ComCtrls,
     Messages, Forms, StdCtrls, Menus;

type

{ $DEFINE FS_DECIMAL}  //see DecimalSeparator in TspCustomSpinEdit.Create

{ TspSpinButton <- TRxSpinButton }

  TspSpinButtonState = (sbNotDown, sbTopDown, sbBottomDown); //TSpinButtonState

  TspSpinButton = class(TGraphicControl)
  private
    FDown: TspSpinButtonState;
    FUpBitmap: TBitmap;
    FDownBitmap: TBitmap;
    FDragging: Boolean;
    FInvalidate: Boolean;
    FTopDownBtn: TBitmap;
    FBottomDownBtn: TBitmap;
    FRepeatTimer: TTimer;
    FNotDownBtn: TBitmap;
    FLastDown: TspSpinButtonState;
    FFocusControl: TWinControl;
    FOnTopClick: TNotifyEvent;
    FOnBottomClick: TNotifyEvent;
    procedure TopClick;
    procedure BottomClick;
    procedure GlyphChanged(Sender: TObject);
    function GetUpGlyph: TBitmap;
    function GetDownGlyph: TBitmap;
    procedure SetUpGlyph(ABmp: TBitmap);
    procedure SetDownGlyph(ABmp: TBitmap);
    procedure SetDown(ABtnState: TspSpinButtonState);
    procedure SetFocusControl(AWinCtl: TWinControl);
    procedure DrawAllBitmap;
    procedure DrawBitmap(ABitmap: TBitmap; ADownState: TspSpinButtonState);
    procedure TimerExpired(Sender: TObject);
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Down: TspSpinButtonState read FDown write SetDown default sbNotDown;
  published
    property DragCursor;
    property DragMode;
    property Enabled;
    property Visible;
    property DownGlyph: TBitmap read GetDownGlyph write SetDownGlyph;
    property UpGlyph: TBitmap read GetUpGlyph write SetUpGlyph;
    property FocusControl: TWinControl read FFocusControl write SetFocusControl;
    property ShowHint;
    property ParentShowHint;
    property Anchors;
    property Constraints;
    property DragKind;
    property OnBottomClick: TNotifyEvent read FOnBottomClick write FOnBottomClick;
    property OnTopClick: TNotifyEvent read FOnTopClick write FOnTopClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnStartDrag;
    property OnEndDock;
    property OnStartDock;
  end;

{ TspCustomSpinEdit <- TRxSpinEdit }

  TEditValueType = (evtInteger, evtFloat);

  TspSpinButtonKind = (bkStandard, bkDiagonal);

  TspCustomSpinEdit = class(TCustomEdit)
  private
    FAlignment: TAlignment;
    FMinValue,
    FMaxValue,
    FIncrement : Double;// TspIntFloat;
    FDecimal: Byte;
    FChanging: Boolean;
    FEditorEnabled: Boolean;
    FValueType: TEditValueType;
    FButton: TspSpinButton;
    FBtnWindow: TWinControl;
    FArrowKeys: Boolean;
    FOnTopClick: TNotifyEvent;
    FOnBottomClick: TNotifyEvent;
    FButtonKind: TspSpinButtonKind;
    FUpDown: TCustomUpDown;
{$IFDEF FS_DECIMAL}
    DecimalSeparator: Char;
{$ENDIF}
    procedure UpdateBuddy;
    function GetButtonKind: TspSpinButtonKind;
    procedure SetButtonKind(Value: TspSpinButtonKind);
    procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
    function GetMinHeight: Integer;
    procedure GetTextHeight(var SysHeight, Height: Integer);
    function CheckValue(NewValue: Double): Double;
    function GetAsInteger: Integer;  //
    function GetAsFloat: Double;  //
    function IsIncrementStored: Boolean;
    function IsMaxStored: Boolean;
    function IsMinStored: Boolean;
    function IsValueStored: Boolean;
    procedure SetArrowKeys(Value: Boolean);
    procedure SetAsInteger(NewValue: Integer);
    procedure SetAsFloat(NewValue: Double);
    procedure SetValueType(NewType: TEditValueType);
    procedure SetDecimal(NewValue: Byte);
    function GetButtonWidth: Integer;
    procedure RecreateButton;
    procedure ResizeButton;
    procedure SetEditRect;
    procedure SetAlignment(Value: TAlignment);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TMessage); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
  protected
    procedure Change; override;

    procedure UpClick(Sender: TObject); virtual;
    procedure DownClick(Sender: TObject); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  {custom}
    function IsValidChar(Key: Char): Boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Text;
 {custom}
    property Decimal: Byte read FDecimal write SetDecimal default 2;
    property Increment: Double read FIncrement write FIncrement stored IsIncrementStored;
    property MaxValue: Double read FMaxValue write FMaxValue stored IsMaxStored;
    property MinValue: Double read FMinValue write FMinValue stored IsMinStored;
    property Value: Double read GetAsFloat write SetAsFloat stored IsValueStored;
    property ValueType: TEditValueType read FValueType write SetValueType
      default evtFloat;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taLeftJustify;
    property ArrowKeys: Boolean read FArrowKeys write SetArrowKeys default True;
    property ButtonKind: TspSpinButtonKind read FButtonKind write SetButtonKind
      default bkDiagonal;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled default True;
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnBottomClick: TNotifyEvent read FOnBottomClick write FOnBottomClick;
    property OnTopClick: TNotifyEvent read FOnTopClick write FOnTopClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnEndDock;
    property OnStartDock;
  end;


  TIntSpinEdit = class(TspCustomSpinEdit)
  protected
    function IsValidChar(Key: Char): Boolean; override;
    function GetIncrement:Integer;
    procedure SetIncrement(ANew: Integer);
    function GetMax: Integer;
    procedure SetMax(ANew: Integer);
    function GetMin: Integer;
    procedure SetMin(ANew: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Value: Integer read GetAsInteger write SetAsInteger default 0;
    property Increment: Integer read GetIncrement write SetIncrement default 1;
    property MaxValue: Integer read GetMax write SetMax default 0;
    property MinValue: Integer read GetMin write SetMin default 0;
  end;


  TFloatSpinEdit = class(TspCustomSpinEdit)  //like Lazarus 
  published
    property DecimalPlaces: Byte read FDecimal write SetDecimal default 2;
    property Value;
    property Increment;
    property MaxValue;
    property MinValue;
  end;


  TExtSpinEdit  = class(TspCustomSpinEdit)   //like RxSpinEdit
  public
    property AsInteger: Integer read GetAsInteger write SetAsInteger default 0;
  published
    property ValueType;
    property Value;
    property Increment;
    property MaxValue;
    property MinValue;
    property Decimal: Byte read FDecimal write SetDecimal default 2;
  end;

procedure Register;  

implementation

uses CommCtrl;

  {$R *.res}

procedure Register;
begin
 RegisterComponents('Sgraph', [TIntSpinEdit, TFloatSpinEdit, TExtSpinEdit]);
end; //Register

const
  sSpinUpBtn = 'ARRWUP';//'SPSPINUP';
  sSpinDownBtn = 'ARRWDOWN';//'SPSPINDOWN';

const
  InitRepeatPause = 400; { pause before repeat timer (ms) }
  RepeatPause     = 100;

{ TspSpinButton }      {sSpinUpBtn sSpinDownBtn}

constructor TspSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUpBitmap := TBitmap.Create;
  FDownBitmap := TBitmap.Create;
  FUpBitmap.Handle := LoadBitmap(HInstance, sSpinUpBtn);
  FDownBitmap.Handle := LoadBitmap(HInstance, sSpinDownBtn);
  FUpBitmap.OnChange := GlyphChanged;
  FDownBitmap.OnChange := GlyphChanged;
  Height := 20;
  Width := 20;
  FTopDownBtn := TBitmap.Create;
  FBottomDownBtn := TBitmap.Create;
  FNotDownBtn := TBitmap.Create;
  DrawAllBitmap;
  FLastDown := sbNotDown;
end;

destructor TspSpinButton.Destroy;
begin
  FTopDownBtn.Free;
  FBottomDownBtn.Free;
  FNotDownBtn.Free;
  FUpBitmap.Free;
  FDownBitmap.Free;
  FRepeatTimer.Free;
  inherited Destroy;
end;

procedure TspSpinButton.GlyphChanged(Sender: TObject);
begin
  FInvalidate := True;
  Invalidate;
end;

function TspSpinButton.GetUpGlyph: TBitmap;
begin
  Result := FUpBitmap;
end;

procedure TspSpinButton.SetUpGlyph(ABmp: TBitmap);
begin
  if ABmp <> nil then FUpBitmap.Assign(ABmp)
  else FUpBitmap.Handle := LoadBitmap(HInstance, sSpinUpBtn);
end;

function TspSpinButton.GetDownGlyph: TBitmap;
begin
  Result := FDownBitmap;
end;

procedure TspSpinButton.SetDownGlyph(ABmp: TBitmap);
begin
  if ABmp <> nil then FDownBitmap.Assign(ABmp)
  else FDownBitmap.Handle := LoadBitmap(HInstance, sSpinDownBtn);
end;

procedure TspSpinButton.SetDown(ABtnState: TspSpinButtonState);
begin
  if ABtnState <> FDown then // check later
  begin
    FDown := ABtnState;
    Repaint;
  end;
end;

procedure TspSpinButton.SetFocusControl(AWinCtl: TWinControl);
begin
  FFocusControl := AWinCtl;
  if AWinCtl <> nil then AWinCtl.FreeNotification(Self);
end;

procedure TspSpinButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFocusControl) then
    FFocusControl := nil;
end;

procedure TspSpinButton.Paint;
begin
  if not Enabled and not (csDesigning in ComponentState) then
    FDragging := False;
  if (FNotDownBtn.Height <> Height) or (FNotDownBtn.Width <> Width) or
    FInvalidate then DrawAllBitmap;
  FInvalidate := False;
  with Canvas do
    case FDown of
      sbNotDown: Draw(0, 0, FNotDownBtn);
      sbTopDown: Draw(0, 0, FTopDownBtn);
      sbBottomDown: Draw(0, 0, FBottomDownBtn);
    end;
end;

procedure TspSpinButton.DrawAllBitmap;
begin
  DrawBitmap(FTopDownBtn, sbTopDown);
  DrawBitmap(FBottomDownBtn, sbBottomDown);
  DrawBitmap(FNotDownBtn, sbNotDown);
end;

procedure TspSpinButton.DrawBitmap(ABitmap: TBitmap; ADownState: TspSpinButtonState);
var
  R, RSrc: TRect;
  dRect: Integer;
  {Temp: TBitmap;}
begin
  ABitmap.Height := Height;
  ABitmap.Width := Width;
  with ABitmap.Canvas do begin
    R := Bounds(0, 0, Width, Height);
    Pen.Width := 1;
    Brush.Color := clBtnFace;
    Brush.Style := bsSolid;
    FillRect(R);
    { buttons frame }
    Pen.Color := clWindowFrame;
    Rectangle(0, 0, Width, Height);
    MoveTo(-1, Height);
    LineTo(Width, -1);
    { top button }
    if ADownState = sbTopDown then Pen.Color := clBtnShadow
    else Pen.Color := clBtnHighlight;
    MoveTo(1, Height - 4);
    LineTo(1, 1);
    LineTo(Width - 3, 1);
    if ADownState = sbTopDown then Pen.Color := clBtnHighlight
      else Pen.Color := clBtnShadow;
    if ADownState <> sbTopDown then begin
      MoveTo(1, Height - 3);
      LineTo(Width - 2, 0);
    end;
    { bottom button }
    if ADownState = sbBottomDown then Pen.Color := clBtnHighlight
      else Pen.Color := clBtnShadow;
    MoveTo(2, Height - 2);
    LineTo(Width - 2, Height - 2);
    LineTo(Width - 2, 1);
    if ADownState = sbBottomDown then Pen.Color := clBtnShadow
      else Pen.Color := clBtnHighlight;
    MoveTo(2, Height - 2);
    LineTo(Width - 1, 1);
    { top glyph }
    dRect := 1;
    if ADownState = sbTopDown then Inc(dRect);
    R := Bounds(Round((Width / 4) - (FUpBitmap.Width / 2)) + dRect,
      Round((Height / 4) - (FUpBitmap.Height / 2)) + dRect, FUpBitmap.Width,
      FUpBitmap.Height);
    RSrc := Bounds(0, 0, FUpBitmap.Width, FUpBitmap.Height);
    {
    if Self.Enabled or (csDesigning in ComponentState) then
      BrushCopy(R, FUpBitmap, RSrc, FUpBitmap.TransparentColor)
    else begin
      Temp := CreateDisabledBitmap(FUpBitmap, clBlack);
      try
        BrushCopy(R, Temp, RSrc, Temp.TransparentColor);
      finally
        Temp.Free;
      end;
    end;
    }
    BrushCopy(R, FUpBitmap, RSrc, FUpBitmap.TransparentColor);
    { bottom glyph }
    R := Bounds(Round((3 * Width / 4) - (FDownBitmap.Width / 2)) - 1,
      Round((3 * Height / 4) - (FDownBitmap.Height / 2)) - 1,
      FDownBitmap.Width, FDownBitmap.Height);
    RSrc := Bounds(0, 0, FDownBitmap.Width, FDownBitmap.Height);
    {
    if Self.Enabled or (csDesigning in ComponentState) then
      BrushCopy(R, FDownBitmap, RSrc, FDownBitmap.TransparentColor)
    else begin
      Temp := CreateDisabledBitmap(FDownBitmap, clBlack);
      try
        BrushCopy(R, Temp, RSrc, Temp.TransparentColor);
      finally
        Temp.Free;
      end;
    end;
    }
    BrushCopy(R, FDownBitmap, RSrc, FDownBitmap.TransparentColor);
    if ADownState = sbBottomDown then begin
      Pen.Color := clBtnShadow;
      MoveTo(3, Height - 2);
      LineTo(Width - 1, 2);
    end;
  end;
end;

procedure TspSpinButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  FInvalidate := True;
  Invalidate;
end;

procedure TspSpinButton.TopClick;
begin
  if Assigned(FOnTopClick) then begin
    FOnTopClick(Self);
    if not (csLButtonDown in ControlState) then FDown := sbNotDown;
  end;
end;

procedure TspSpinButton.BottomClick;
begin
  if Assigned(FOnBottomClick) then begin
    FOnBottomClick(Self);
    if not (csLButtonDown in ControlState) then FDown := sbNotDown;
  end;
end;

procedure TspSpinButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then begin
    if (FFocusControl <> nil) and FFocusControl.TabStop and
      FFocusControl.CanFocus and (GetFocus <> FFocusControl.Handle) then
        FFocusControl.SetFocus;
    if FDown = sbNotDown then begin
      FLastDown := FDown;
      if Y > (-(Height/Width) * X + Height) then begin
        FDown := sbBottomDown;
        BottomClick;
      end
      else begin
        FDown := sbTopDown;
        TopClick;
      end;
      if FLastDown <> FDown then begin
        FLastDown := FDown;
        Repaint;
      end;
      if FRepeatTimer = nil then FRepeatTimer := TTimer.Create(Self);
      FRepeatTimer.OnTimer := TimerExpired;
      FRepeatTimer.Interval := InitRepeatPause;
      FRepeatTimer.Enabled := True;
    end;
    FDragging := True;
  end;
end;

procedure TspSpinButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: TspSpinButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then begin
    if (X >= 0) and (X <= Width) and (Y >= 0) and (Y <= Height) then begin
      NewState := FDown;
      if Y > (-(Width / Height) * X + Height) then begin
        if (FDown <> sbBottomDown) then begin
          if FLastDown = sbBottomDown then FDown := sbBottomDown
          else FDown := sbNotDown;
          if NewState <> FDown then Repaint;
        end;
      end
      else begin
        if (FDown <> sbTopDown) then begin
          if (FLastDown = sbTopDown) then FDown := sbTopDown
          else FDown := sbNotDown;
          if NewState <> FDown then Repaint;
        end;
      end;
    end else
      if FDown <> sbNotDown then begin
        FDown := sbNotDown;
        Repaint;
      end;
  end;
end;

procedure TspSpinButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FDragging then begin
    FDragging := False;
    if (X >= 0) and (X <= Width) and (Y >= 0) and (Y <= Height) then begin
      FDown := sbNotDown;
      FLastDown := sbNotDown;
      Repaint;
    end;
  end;
end;

procedure TspSpinButton.TimerExpired(Sender: TObject);
begin
  FRepeatTimer.Interval := RepeatPause;
  if (FDown <> sbNotDown) and MouseCapture then begin
    try
      if FDown = sbBottomDown then BottomClick else TopClick;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;
end;

function DefBtnWidth: Integer;
begin
  Result := GetSystemMetrics(SM_CXVSCROLL);
  if Result > 15 then Result := 15;
end;


type
  TRxUpDown = class(TCustomUpDown)
  private
    FChanging: Boolean;
    procedure ScrollMessage(var Message: TWMVScroll);
    procedure WMHScroll(var Message: TWMHScroll); message CN_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message CN_VSCROLL;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnClick;
  end;

constructor TRxUpDown.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Orientation := udVertical;
  Min := -1;
  Max := 1;
  Position := 0;
end;

destructor TRxUpDown.Destroy;
begin
  OnClick := nil;
  inherited Destroy;
end;

procedure TRxUpDown.ScrollMessage(var Message: TWMVScroll);
begin
  if Message.ScrollCode = SB_THUMBPOSITION then begin
    if not FChanging then begin
      FChanging := True;
      try
        if Message.Pos > 0 then Click(btNext)
        else if Message.Pos < 0 then Click(btPrev);
        if HandleAllocated then
          SendMessage(Handle, UDM_SETPOS, 0, 0);
      finally
        FChanging := False;
      end;
    end;
  end;
end;

procedure TRxUpDown.WMHScroll(var Message: TWMHScroll);
begin
  ScrollMessage(TWMVScroll(Message));
end;

procedure TRxUpDown.WMVScroll(var Message: TWMVScroll);
begin
  ScrollMessage(Message);
end;

procedure TRxUpDown.WMSize(var Message: TWMSize);
begin
  inherited;
  if Width <> DefBtnWidth then Width := DefBtnWidth;
end;

{ TspCustomSpinEdit }

constructor TspCustomSpinEdit.Create(AOwner: TComponent);
{$IFDEF FS_DECIMAL}
var FS: TFormatSettings;
{$ENDIF}
begin
  inherited Create(AOwner);
  Text := '0';
  ControlStyle := ControlStyle - [csSetCaption];
  FIncrement := 1.0;
  FDecimal := 2;
  FValueType := evtFloat;
  FEditorEnabled := True;
  FButtonKind := bkDiagonal;
  FArrowKeys := True;
  RecreateButton;
{$IFDEF FS_DECIMAL}
  FS:= TFormatSettings.Create;    //create for current locale
  DecimalSeparator:= FS.DecimalSeparator;
{$ENDIF}
end;

destructor TspCustomSpinEdit.Destroy;
begin
  Destroying;
  FChanging := True;
  if FButton <> nil then begin
    FButton.Free;
    FButton := nil;
    FBtnWindow.Free;
    FBtnWindow := nil;
  end;
  if FUpDown <> nil then begin
    FUpDown.Free;
    FUpDown := nil;
  end;
  inherited Destroy;
end;

procedure TspCustomSpinEdit.RecreateButton;
begin
  if (csDestroying in ComponentState) then Exit;
  FButton.Free;
  FButton := nil;
  FBtnWindow.Free;
  FBtnWindow := nil;
  FUpDown.Free;
  FUpDown := nil;
  if GetButtonKind = bkStandard then begin
    FUpDown := TRxUpDown.Create(Self);
    with TRxUpDown(FUpDown) do begin
      Visible := True;
      SetBounds(0, 0, DefBtnWidth, Self.Height);
      if (BiDiMode = bdRightToLeft) then Align := alLeft else
      Parent := Self;
      UpdateBuddy;
      Align := alRight;
      OnClick := UpDownClick;
    end;
  end
  else begin
    FBtnWindow := TWinControl.Create(Self);
    FBtnWindow.Visible := True;
    FBtnWindow.Parent := Self;
    FBtnWindow.SetBounds(0, 0, Height, Height);
    FButton := TspSpinButton.Create(Self);
    FButton.Visible := True;
    FButton.Parent := FBtnWindow;
    FButton.FocusControl := Self;
    FButton.OnTopClick := UpClick;
    FButton.OnBottomClick := DownClick;
    FButton.SetBounds(0, 0, FBtnWindow.Width, FBtnWindow.Height);
  end;
end;

procedure TspCustomSpinEdit.SetArrowKeys(Value: Boolean);
begin
  FArrowKeys := Value;
  UpdateBuddy;
  ResizeButton;
end;

procedure TspCustomSpinEdit.UpdateBuddy;
begin
  if (FUpDown <> nil) and HandleAllocated then begin
    FUpDown.HandleNeeded;
    if FArrowKeys then SendMessage(FUpDown.Handle, UDM_SETBUDDY, Handle, 0)
    else SendMessage(FUpDown.Handle, UDM_SETBUDDY, 0, 0);
  end;
end;

function TspCustomSpinEdit.GetButtonKind: TspSpinButtonKind;
begin
  if NewStyleControls then Result := FButtonKind
  else Result := bkDiagonal;
end;

procedure TspCustomSpinEdit.SetButtonKind(Value: TspSpinButtonKind);
var
  OldKind: TspSpinButtonKind;
begin
  OldKind := FButtonKind;
  FButtonKind := Value;
  if OldKind <> GetButtonKind then begin
    RecreateButton;
    ResizeButton;
    SetEditRect;
  end;
end;

procedure TspCustomSpinEdit.UpDownClick(Sender: TObject; Button: TUDBtnType);
begin
  if TabStop and CanFocus then SetFocus;
  case Button of
    btNext: UpClick(Sender);
    btPrev: DownClick(Sender);
  end;
end;

function TspCustomSpinEdit.GetButtonWidth: Integer;
begin
  if FUpDown <> nil then Result := FUpDown.Width else
  if FButton <> nil then Result := FButton.Width
  else Result := DefBtnWidth;
end;

procedure TspCustomSpinEdit.ResizeButton;
var
  R: TRect;
begin
  if FUpDown <> nil then begin
    FUpDown.Width := DefBtnWidth;
    if (BiDiMode = bdRightToLeft) then FUpDown.Align := alLeft else
    FUpDown.Align := alRight;
  end
  else if FButton <> nil then begin { bkDiagonal }
    if NewStyleControls and Ctl3D and (BorderStyle = bsSingle) then
      R := Bounds(Width - Height - 1, -1, Height - 3, Height - 3)
    else
      R := Bounds(Width - Height, 0, Height, Height);
    if (BiDiMode = bdRightToLeft) then begin
      if NewStyleControls and Ctl3D and (BorderStyle = bsSingle) then begin
        R.Left := -1;
        R.Right := Height - 4;
      end
      else begin
        R.Left := 0;
        R.Right := Height;
      end;
    end;
    with R do
      FBtnWindow.SetBounds(Left, Top, Right - Left, Bottom - Top);
    FButton.SetBounds(0, 0, FBtnWindow.Width, FBtnWindow.Height);
  end;
end;

procedure TspCustomSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if ArrowKeys and (Key in [VK_UP, VK_DOWN]) and (FUpDown = nil) then
  begin
    if Key = VK_UP then UpClick(Self)
    else if Key = VK_DOWN then DownClick(Self);
    Key := 0;
  end;
end;

procedure TspCustomSpinEdit.Change;
begin
  if not FChanging then inherited Change;
end;

procedure TspCustomSpinEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then begin
    inherited KeyPress(Key);
    if (Key = Char(VK_RETURN)) or (Key = Char(VK_ESCAPE)) then begin
      { must catch and remove this, since is actually multi-line }
      GetParentForm(Self).Perform(CM_DIALOGKEY, Byte(Key), 0);
      if Key = Char(VK_RETURN) then Key := #0;
    end;
  end;
end;

function TspCustomSpinEdit.IsValidChar(Key: Char): Boolean;
var
  ValidChars: set of Char;
begin
  ValidChars := ['+', '-', '0'..'9'];
  if ValueType = evtFloat then begin
    if Pos(DecimalSeparator, Text) = 0 then
      ValidChars := ValidChars + [DecimalSeparator];
    if Pos('E', AnsiUpperCase(Text)) = 0 then
      ValidChars := ValidChars + ['e', 'E'];
  end;
  Result := (Key in ValidChars) or (Key < #32);
  if not FEditorEnabled and Result and ((Key >= #32) or
    (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE))) then Result := False;
end;

procedure TspCustomSpinEdit.CreateParams(var Params: TCreateParams);
const
  Alignments: array[Boolean, TAlignment] of DWORD =
    ((ES_LEFT, ES_RIGHT, ES_CENTER), (ES_RIGHT, ES_LEFT, ES_CENTER));
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN or
    Alignments[UseRightToLeftAlignment, FAlignment];
end;

procedure TspCustomSpinEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
  UpdateBuddy;
end;

procedure TspCustomSpinEdit.SetEditRect;
var
  Loc: TRect;
begin
  if (BiDiMode = bdRightToLeft) then
    SetRect(Loc, GetButtonWidth + 1, 0, ClientWidth - 1,
      ClientHeight + 1) else
  SetRect(Loc, 0, 0, ClientWidth - GetButtonWidth - 2, ClientHeight + 1);
  SendMessage(Handle, EM_SETRECTNP, 0, Longint(@Loc));
end;

procedure TspCustomSpinEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    RecreateWnd;
  end;
end;

procedure TspCustomSpinEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
  { text edit bug: if size to less than minheight, then edit ctrl does
    not display the text }
  if Height < MinHeight then
    Height := MinHeight
  else begin
    ResizeButton;
    SetEditRect;
  end;
end;

procedure TspCustomSpinEdit.GetTextHeight(var SysHeight, Height: Integer);
var
  DC: HDC;
  SaveFont: HFont;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  SysHeight := SysMetrics.tmHeight;
  Height := Metrics.tmHeight;
end;

function TspCustomSpinEdit.GetMinHeight: Integer;
var
  I, H: Integer;
begin
  GetTextHeight(I, H);
  if I > H then I := H;
  Result := H + (I div 4) + (GetSystemMetrics(SM_CYBORDER) * 4) + 1;
end;

procedure TspCustomSpinEdit.UpClick(Sender: TObject);
var
  OldText: string;
begin
  if ReadOnly then MessageBeep(0)
  else begin
    FChanging := True;
    try
      OldText := inherited Text;
      if FValueType = evtFloat then
        SetAsFloat(GetAsFloat + FIncrement)
      else
        SetAsInteger(GetAsInteger + Trunc(FIncrement));
    finally
      FChanging := False;
    end;
    if CompareText(inherited Text, OldText) <> 0 then begin
      Modified := True;
      Change;
    end;
    if Assigned(FOnTopClick) then FOnTopClick(Self);
  end;
end;

procedure TspCustomSpinEdit.DownClick(Sender: TObject);
var
  OldText: string;
begin
  if ReadOnly then MessageBeep(0)
  else begin
    FChanging := True;
    try
      OldText := inherited Text;
      if FValueType = evtFloat then
        SetAsFloat(GetAsFloat - FIncrement)
      else
        SetAsInteger(GetAsInteger - Trunc(FIncrement));
    finally
      FChanging := False;
    end;
    if CompareText(inherited Text, OldText) <> 0 then begin
      Modified := True;
      Change;
    end;
    if Assigned(FOnBottomClick) then FOnBottomClick(Self);
  end;
end;

procedure TspCustomSpinEdit.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  ResizeButton;
  SetEditRect;
end;

procedure TspCustomSpinEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ResizeButton;
  SetEditRect;
end;

procedure TspCustomSpinEdit.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  ResizeButton;
  SetEditRect;
end;

procedure TspCustomSpinEdit.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if FUpDown <> nil then begin
    FUpDown.Enabled := Enabled;
    if Enabled then UpdateBuddy;
    ResizeButton;
  end;
end;

procedure TspCustomSpinEdit.WMPaste(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TspCustomSpinEdit.WMCut(var Message: TWMCut);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TspCustomSpinEdit.CMExit(var Message: TCMExit);
begin
  inherited;
  if CheckValue(Value) <> Value then SetAsFloat(Value);
end;

procedure TspCustomSpinEdit.CMEnter(var Message: TMessage);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then SelectAll;
  inherited;
end;

function TspCustomSpinEdit.GetAsFloat: Double;
begin
  try
    Result := StrToFloat(Text);
    if ValueType <> evtFloat then
      Result := Trunc(Result);
  except
    Result := FMinValue;
    if ValueType <> evtFloat then
      Result := Trunc(FMinValue);
  end;
end;

procedure TspCustomSpinEdit.SetAsFloat(NewValue: Double);
begin
  if ValueType = evtFloat then
    Text := FloatToStrF(CheckValue(NewValue), ffFixed, 15, FDecimal)
  else
    Text := IntToStr(Trunc(CheckValue(NewValue)));
end;

function TspCustomSpinEdit.GetAsInteger: Integer;
begin
  Result := Trunc(GetAsFloat);
end;

procedure TspCustomSpinEdit.SetAsInteger(NewValue: Integer);
begin
  SetAsFloat(NewValue);
end;

procedure TspCustomSpinEdit.SetValueType(NewType: TEditValueType);
begin
  if FValueType <> NewType then begin
    FValueType := NewType;
    Value := GetAsFloat;
    if FValueType = {$IFDEF CBUILDER} vtInt {$ELSE} evtInteger {$ENDIF} then
    begin
      FIncrement := Round(FIncrement);
      if FIncrement = 0 then FIncrement := 1;
    end;
  end;
end;

function TspCustomSpinEdit.IsIncrementStored: Boolean;
begin
  Result := FIncrement <> 1.0;
end;

function TspCustomSpinEdit.IsMaxStored: Boolean;
begin
  Result := (MaxValue <> 0.0);
end;

function TspCustomSpinEdit.IsMinStored: Boolean;
begin
  Result := (MinValue <> 0.0);
end;

function TspCustomSpinEdit.IsValueStored: Boolean;
begin
  Result := (GetAsFloat <> 0.0);
end;

procedure TspCustomSpinEdit.SetDecimal(NewValue: Byte);
begin
  if FDecimal <> NewValue then begin
    FDecimal := NewValue;
    Value := GetAsFloat;
  end;
end;

function TspCustomSpinEdit.CheckValue (NewValue: Double): Double;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue) then begin
    if NewValue < FMinValue then
      Result := FMinValue
    else if NewValue > FMaxValue then
      Result := FMaxValue;
  end;
end;


{ TIntSpinEdit }

constructor TIntSpinEdit.Create(AOwner: TComponent);
begin
  inherited;
  FDecimal := 0;
  FValueType := evtInteger;
end;

function TIntSpinEdit.GetIncrement: Integer;
begin
  Result:= Trunc(FIncrement);
end;

function TIntSpinEdit.GetMax: Integer;
begin
  Result:= Trunc(FMaxValue);
end;

function TIntSpinEdit.GetMin: Integer;
begin
  Result:= Trunc(FMinValue);
end;

function TIntSpinEdit.IsValidChar(Key: Char): Boolean;
begin
  Result:= not(Key in ['.', ',']) and Inherited IsValidChar(Key);
end;

procedure TIntSpinEdit.SetIncrement(ANew: Integer);
begin
  FIncrement:= ANew;
end;

procedure TIntSpinEdit.SetMax(ANew: Integer);
begin
  FMaxValue:= ANew;
end;

procedure TIntSpinEdit.SetMin(ANew: Integer);
begin
  FMinValue:= ANew;
end;

end.
