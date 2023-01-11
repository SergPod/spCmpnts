##unit spFormPlacement
{}
Provides simple class TAppFormIniFile on base TWinIni. It partially replaces   
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
way as TWinIni. }

##unit spIntFloatEdit;
{
Hystorically (199x) I used TSpinEdit and TRxSpinEdit based on the VCL unit Spin.
TSpinEdit was installed on Sample tab of Delphi IDE. It makes difficult migration 
to Lazarus and Delphi where Rx components were not avaialable. 
On base TSpinEdit I've created 3 Numerical EditLine
TIntSpinEdit (like TSpinEdit in Delphi and Lazarus)
TFloatSpinEdit (like TFloatSpinEdit in Lazarus)
TExtSpinEdit (like TRxSpinEdit )

spIntFloatEdit.pas can be used in the Delphi 10.3 (uses spIntFloatEdit)
porting code to Delphi without Rx library we need replace in code 
  TRxSpinEdit by TExtSpinEdit

porting code to Lazarus we need replace in code 
  spIntFloatEdit by Spin in "uses" sections (uses Spin)
  TIntSpinEdit by TSpinEdit see also //$DEFINE FS_DECIMAL }
