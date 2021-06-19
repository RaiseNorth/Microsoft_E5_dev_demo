unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Windows, Controls, Graphics, Dialogs, StdCtrls, zstream;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    SeleccionarArc: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    selectedFile: string;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  dlg: TOpenDialog;
begin
   selectedFile := '';
   dlg := TOpenDialog.Create(nil);
   try
     dlg.Filter := 'All files (*.*)|*.*';
     if dlg.Execute then
     begin
       if fileExists(dlg.Filename) then
       begin
         selectedFile := dlg.Filename;
         SeleccionarArc.Text := selectedFile;
       end;
     end
     else
       ShowMessage('No file selected');
   finally
    dlg.Free;
   end;
end;

function Swap32(const Value: LongWord): LongWord;
begin
  Result := Swap(Word(Value)) shl 16 + Swap(Word(Value shr 16));
end;

function UnZipCofing(Fname: string): string;
var
  ds: TDecompressionStream;
  ms, fs, tmpfs: TMemoryStream;
  ss: TStringStream;
  bufferSize, blockSize, nextOff: LongWord;
begin
  fs := TMemoryStream.Create;
  tmpfs := TMemoryStream.Create;
  ms := TMemoryStream.Create;
  ss := TStringStream.Create('');
  if not FileExists(Fname) then
  begin
    exit;
  end;
  try
    fs.LoadFromFile(Fname);
    nextOff := 60;
    while nextOff > 0 do
    begin
      fs.Seek(nextOff, soFromBeginning);
      fs.Read(bufferSize, SizeOf(bufferSize));
      bufferSize := Swap32(bufferSize);
      fs.Read(blockSize, SizeOf(blockSize));
      blockSize := Swap32(blockSize);
      fs.Read(nextOff, SizeOf(nextOff));
      nextOff := Swap32(nextOff);
      tmpfs.Clear;
      tmpfs.CopyFrom(fs, blockSize);
      tmpfs.Position := 0;
      ds := TDecompressionStream.Create(tmpfs);
      ms.SetSize(bufferSize);
      ZeroMemory(ms.Memory, bufferSize);
      ms.Position := 0;
      ds.Read(ms.Memory^, bufferSize);
      ss.CopyFrom(ms, 0);
      ds.Free;
    end;
    Result := ss.DataString;
  finally
    fs.Free;
    tmpfs.Free;
    ms.Free;
    ss.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   if (selectedFile = '') or (not fileExists(selectedFile)) then
   begin
      ShowMessage('Not a valid file path');
   end
   else
   begin
     UnZipCofing(selectedFile);
     ShowMessage('Completed!');
   end;
end;

end.

