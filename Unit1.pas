unit Unit1;
{$optimization off}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Spin;

type
  TForm1 = class(TForm)
    decrypt: TButton;
    Memo1: TMemo;
    encrypt: TButton;
    fontnum: TScrollBar;
    img1: TImage;
    ScrollBar1: TScrollBar;
    Label1: TLabel;
    Label2: TLabel;
    ScrollBar2: TScrollBar;
    imgz: TImage;
    img3: TImage;
    btn1: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    se1: TSpinEdit;
    btn2: TButton;
    img2: TImage;
    ScrollBar3: TScrollBar;
    lbl3: TLabel;
    mmo1: TMemo;
    mmo2: TMemo;
    ScrollBar4: TScrollBar;
    ScrollBar5: TScrollBar;
    btn3: TButton;
    lbl4: TLabel;
    lbl5: TLabel;
    procedure decryptClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure fontnumChange(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure img1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure img1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ScrollBar2Change(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure se1Change(Sender: TObject);
    procedure encryptClick(Sender: TObject);
    procedure ScrollBar3Change(Sender: TObject);
    procedure ScrollBar4Change(Sender: TObject);
    procedure ScrollBar5Change(Sender: TObject);
    procedure btn3Click(Sender: TObject);
//    procedure showsymbol;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  OriginalStr, TranslateStr : array [0..10000] of string;
  buf,buf_pal   : PByteArray;
  GlobalFileSize:longint;
  fin:file of Byte;
  font_width: array [0..255] of Integer; // ширины символов
  font_start: array [0..255] of longint;// таблица смещений начала символа
  font_array: array [0..500, 0..10000] of Byte; // прямоугольник шрифта
  StartOffsetWidth, StartOffsetOfOffset, dataStart, PenColor, font_w, font_h, abcLen :LongInt;
  pal: PLogPalette;
  hpal: HPALETTE;
  Bitmap: TBitmap;
  kx, ky:Integer;
   curFile:string;

implementation
{$R *.dfm}

Procedure FillFontArrayFromBuf;
var i,j:longint;
begin
 // при запуске заполняем двумерный массив
  for i:=0 to (font_h - 1) do
   for j:=0 to (abcLen - 1) do
    font_array[i,j]:=buf[dataStart + abcLen*i + j];

end;

procedure ShowSymbol;
var
  curpos: LongInt;
  i, j, start, r,g,b,maxnum :LongInt;
  byte1:byte;

begin
 form1.Memo1.Lines.Clear;
 curpos:=Form1.fontnum.Position;

 font_h:=buf[dataStart - 8] - 1;
 font_w:=font_width[curpos];
 start:=font_start[curpos];

 form1.img1.Width:=font_w;
 form1.img1.Height:=font_h;

 Form1.img1.Picture:=nil;
 Form1.img3.Picture:=nil;
 Form1.img2.Picture:=nil;

 Form1.img1.Canvas.Refresh;
 Form1.img3.Canvas.Refresh;
 Form1.img2.Canvas.Refresh;

// ширина всего шрифта
 abcLen:=buf[dataStart - 12 + 0] + 256*buf[dataStart - 12 + 1] + 256*256*buf[dataStart - 12 + 2] + 256*256*256*buf[dataStart - 12 + 3];

 Bitmap := TBitmap.Create;
 Bitmap.PixelFormat := pf8bit;

 Bitmap.Width := font_w;
 Bitmap.Height := font_h;

 pal := nil;

GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);
pal.palVersion := $300;
pal.palNumEntries := 256;
for i := 0 to 255 do
  begin
   pal.palPalEntry[i].peRed := buf_pal[3*i + 0];
   pal.palPalEntry[i].peGreen := buf_pal[3*i + 1];
   pal.palPalEntry[i].peBlue := buf_pal[3*i + 2];
  end;
hpal := CreatePalette(pal^);
if hpal <> 0 then
    Bitmap.Palette:=hpal;


 for i:=0 to (font_h - 1) do
  for j:=0 to (font_w - 1) do
   begin
    byte1:=buf[dataStart + font_start[curpos] + abcLen*i + j];

    r:=buf_Pal[byte1*3 + 0];
    g:=buf_Pal[byte1*3 + 1];
    b:=buf_Pal[byte1*3 + 2];

    form1.img1.Canvas.Pixels [j, i]:= RGB(r,g,b);
    form1.img3.Canvas.Pixels [j, i]:= RGB(r,g,b);

   end;

 Form1.img1.Height:=form1.ScrollBar1.Position * font_h;
 form1.img1.Width:=form1.ScrollBar1.Position * font_width[curpos];
 Form1.img1.Canvas.Refresh;

 form1.Memo1.Lines.Add('Ширина шрифта=' + IntToStr(font_w));
 form1.Memo1.Lines.Add('Высота шрифта=' + IntToStr(font_h));

 form1.se1.value:=font_w;


 form1.Memo1.Lines.Add('Ширина шрифта полная=' + IntToStr(abcLen));
 form1.Memo1.Lines.Add('Номер символа=' + IntToStr(Form1.fontnum.Position+1));


 for i:=0 to (font_h - 1) do
  for j:=0 to (abcLen - 1) do
   begin
    byte1:=font_array[i,j];
    r:=buf_Pal[byte1*3 + 0];
    g:=buf_Pal[byte1*3 + 1];
    b:=buf_Pal[byte1*3 + 2];
    form1.img2.Canvas.Pixels [j, i]:= RGB(r,g,b);
   end;
end;


procedure ReadInitFont (fontnum:Integer);
var
  fname:string;
  i,j, sum, fsize:LongInt;
begin
  if fontnum=0 then fname:='TEXTFONT.CFT';
  if fontnum=1 then fname:='TEXTFNT2.CFT';
  if fontnum=2 then fname:='MEDFONT1.CFT';
  if fontnum=3 then fname:='MEDFONT2.CFT';
  if fontnum=4 then fname:='HARVFONT.CFT';
  if fontnum=5 then fname:='HARVFNT2.CFT';

curFile:=fname;
// грузим шрифт в память, в буфер
FileMode := fmShareDenyNone; // права доступа отключить ругань

AssignFile(fin, fname);
Reset(fin);
GlobalFileSize := FileSize(fin);
GetMem(Buf, GlobalFileSize * 2 ); // выделяем память буфферу
for i:=0 to (GlobalFileSize*2-1) do
 buf[i]:=0;

Blockread(fin, Buf[0], GlobalFileSize);  // читаем весь файл туда
CloseFile (fin);
// INVHELP.PAL

fname:='INVHELP.PAL';
AssignFile(fin, fname);
Reset(fin);
fsize:=FileSize(fin);
GetMem(buf_pal, FSize); // выделяем память буфферу
Blockread(fin, buf_pal[0], FSize);  // читаем весь файл туда
CloseFile (fin);

///////////////////////////

StartOffsetOfOffset:=68; // 44h
StartOffsetWidth:=580;    // 0244h
datastart:=1108;    // 0454h

 i:=0;
 j:=0;
 repeat
    font_width[j]:=buf[StartOffsetWidth + i] + 256 * buf[StartOffsetWidth + i + 1];
    font_start[j]:=buf[StartOffsetOfOffset + i] + 256 * buf[StartOffsetOfOffset + i + 1];

    Inc (i,2);
    inc (j);
 until (i>512);

// form1.Memo1.Lines.Add('Сумма ширин = ' + IntToStr(sum));
// Form1.Memo1.Lines.Add('Сумма нулей = ' + IntToStr(j));
// Form1.Memo1.Lines.Add('Сдвиг на след строку, сумма = ' + IntToStr(sum + j) );

 ShowSymbol;
 //ScrollBar2Change(Sender);

 FillFontArrayFromBuf;
end;



// Пишем DWORD в буфер BUF
// num - число для записи
// off - смещение в блоке
procedure WriteDWord2BUF (num, off:LongInt);
var
  byte0, byte1, byte2, byte3:Byte;
begin
 // Пишем смещение блока
  BYTE3:=Trunc(num/(256*256*256));
  BYTE2:=Trunc ((num - BYTE3 *256*256*256)/(256*256));
  BYTE1:=Trunc ((num - BYTE2*256*256 - BYTE3*256*256*256)/(256));
  BYTE0:=num - BYTE1*256 - BYTE2*256*256 - BYTE3*256*256*256;

  buf[off + 0]:=byte0;
  buf[off + 1]:=byte1;
  buf[off + 2]:=byte2;
  buf[off + 3]:=byte3;
end;


procedure TForm1.decryptClick(Sender: TObject);
var
  buf   : PByteArray;
 i:longint;
fin:file of Byte;
begin

FileMode := fmShareDenyNone; // права доступа отключить ругань
AssignFile(fin, 'DIALOGUE.IDX');
Reset(fin);
GlobalFileSize := FileSize(fin);
GetMem(Buf, GlobalFileSize); // выделяем память буфферу
Blockread(fin, Buf[0], GlobalFileSize);  // читаем весь файл туда
CloseFile (fin);

for i:=0 to (GlobalFileSize - 1) do
 begin
   if ( (buf[i]=13) or (buf[i]=10) ) then Continue;
   buf[i]:=buf[i] xor 170;
 end;

 AssignFile(fin, 'DIALOGUE.IDX.out');
 Rewrite(fin);
 BlockWrite (fin, Buf[0], GlobalFileSize);  // читаем весь файл туда
 CloseFile (fin);

 Memo1.Text:='done';

FreeMem(Buf); // освободить, закрыть и уйти.
end;

procedure TForm1.FormActivate(Sender: TObject);
var cou1, cou2, i:Integer;
f1,f2:TextFile;
str:string;
begin
  ReadInitFont (Form1.ScrollBar3.Position);
  // FillTranslateTable, читаем заполняем оригинал
  AssignFile (f1, 'DIALOGUE.IDX.out');
  Reset(f1);
  cou1:=0;
  while (not(Eof(f1))) do
   begin
    Readln (f1, str);
    OriginalStr[cou1]:=str;
    inc (cou1);
   end;
  CloseFile (f1);
  Form1.ScrollBar4.Min:=0;
  Form1.ScrollBar4.Max:=Trunc((cou1 - 1)/2);

  AssignFile (f1, 'DIALOGUE.IDX.rus.txt');
  Reset(f1);
  cou1:=0;
  while (not(Eof(f1))) do
   begin
    Readln (f1, str);
    TranslateStr[cou1]:=utf8ToAnsi(str);
    inc (cou1);
   end;
  CloseFile (f1);
  Form1.ScrollBar5.Min:=0;
  Form1.ScrollBar5.Max:=Trunc( (cou1 - 1)/2);

ScrollBar4Change(Sender);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
FreeMem(Buf); // освободить, закрыть и уйти.
FreeMem(buf_pal);
FreeMem(pal);
end;

procedure TForm1.fontnumChange(Sender: TObject);
begin
Form1.Memo1.Lines.Clear;

ShowSymbol;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
Form1.img1.Height:=form1.ScrollBar1.Position * font_h;
form1.img1.Width:=form1.ScrollBar1.Position * font_width[Form1.fontnum.Position];
end;

procedure TForm1.img1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  symnum, mx, my, index:LongInt;
begin
kx:=trunc (form1.img1.Width / font_width[Form1.fontnum.Position]);
ky:=trunc (Form1.img1.Height / font_h);
if (Button = mbLeft) then form1.img1.Canvas.Pixels[Trunc(X/kx), Trunc(Y/ky)]:=PenColor;
if (Button = mbRight) then form1.img1.Canvas.Pixels[Trunc(X/kx), Trunc(Y/ky)]:=0;

symnum:=form1.fontnum.Position;
my:=Trunc(Y/ky);
mx:=Trunc(X/kx) + font_start[symnum];

index:=form1.ScrollBar2.Position;
if (Button = mbRight) then index:=0;

font_array[my, mx ]:=index;
end;
// Синий цвет фона - это байт 0, белый - FFh

procedure TForm1.img1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
kx:=trunc (form1.img1.Width / font_width[Form1.fontnum.Position]);
ky:=trunc (Form1.img1.Height / font_h);

label1.Caption:='x=' + inttostr(x) + ' ,y=' + inttostr (y);
Label2.Caption:='Color=' + inttostr (form1.img1.Canvas.Pixels[Trunc(X/kx), Trunc(Y/ky)]);
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
var
  i,j,col, r,g,b:Integer;
begin
 col:=form1.ScrollBar2.Position;
 for i:=0 to 39 do
  for j:=0 to 169 do
    begin
     r:=buf_Pal[col*3 + 0];
     g:=buf_Pal[col*3 + 1];
     b:=buf_Pal[col*3 + 2];

     form1.imgz.Canvas.Pixels [j, i]:= RGB(r,g,b);
    end;
 PenColor:=RGB(r,g,b);
end;

procedure TForm1.btn1Click(Sender: TObject);
var
 delta:Integer; // насколько увеличиваем-уменьшаем ширину
 i,j,k, new_off, curcol, GamePalColor:LongInt;
 symnum, r,g,b, kx, ky, w:integer;
 byte0, byte1:byte;
 f:file of Byte;
begin
 symnum:=form1.fontnum.Position;
 delta:=Form1.se1.Value - font_w;
 if delta>0 then delta:=1;
 if delta<0 then delta:=-1;

  // Если это был пустой символ, то смещение новое создать надо и ширину ему дать
  // 
  if ( (font_start[symnum]=0) and (font_width[symnum]=0) ) then
   begin
    //delta:=Form1.se1.Value;
    font_start[symnum]:=abcLen ;// + delta;
    font_width[symnum]:=delta;
    buf[StartOffsetWidth + symnum*2]:=delta;

    inc (abcLen, delta);
    WriteDWord2BUF(abcLen, (dataStart - 12));
    // разделить блоки, заполнить новый символ и выйти

    // Новое смещение для нового символа
    new_off:=font_start[symnum];
    BYTE0:=Trunc(new_off / 256);     // старший байт
    BYTE1:=new_off - BYTE0 * 256;    // младший байт
    buf[StartOffsetOfOffset + symnum*2 + 0]:=byte1;
    buf[StartOffsetOfOffset + symnum*2 + 1]:=byte0;

    //FillFontArrayFromBuf;
    ShowSymbol;
    btn1Click(Sender);
    Exit;
   end;

  // Сдвигаем всё на дельту
   for i:=0 to (Abs(delta) - 1) do
    for k:=0 to (font_h - 1) do
     for j:=abcLen downto ( (font_start[symnum]) + font_w ) do
      begin
       if (delta>0) then font_array[k, j + 1 + i]:=font_array[k, j + i];
       if (delta<0) then font_array[k, font_start[symnum]+font_w-1 + abclen - j + i]:=font_array[k, font_start[symnum]+font_w-1 + abclen - j + i + 1];
      end;

 // Увеличение ширины
 if (delta>0) then
  begin
    //Надо почистить новое место от сдвинутых чисел
    for i:=0 to (font_h - 1) do
     for j:=0 to (delta - 1) do
       font_array[i,j + font_start[symnum] + font_w]:=0;

  end;
  {
  if (delta<0) then
   begin
   for i:=0 to (Abs(delta) - 1) do
    for k:=0 to (font_h - 1) do
     for j:=(font_start[symnum] + font_w - 1) to abcLen do
       font_array[k, j + i]:=font_array[k, j + 1 + i];

   end;
   }
    // Скорректировать нач смещения следующих символов
    // font_start и buf
    // Все смещения вперемежку, поэтому надо смотреть чтобы было больше текущего
   for i:=0 to 255 do
     begin
      if (font_start[i]>font_start[symnum]) then
       begin
        new_off:=font_start[i] + delta;
        font_start[i]:=new_off;
 
        BYTE0:=Trunc(new_off / 256);  // старший байт
        BYTE1:=new_off - BYTE0 * 256;    // младший байт

        buf[StartOffsetOfOffset + i*2 + 0]:=byte1;
        buf[StartOffsetOfOffset + i*2 + 1]:=byte0;
       end;
     end;

 // корректируем общую ширину шрифта
 abcLen:=abcLen + delta;

 // возвращаем в буфер
 WriteDWord2BUF(abcLen, (dataStart - 12));

 // Корректируем ширины
 font_w:=font_w + delta;
 font_width[symnum]:=font_width[symnum] + delta;
 buf[StartOffsetWidth + symnum*2]:=buf[StartOffsetWidth + symnum*2] + delta;

  // Нужно развернуть font_array в линию buf с учетом новой ширины общей и высоты
  for i:=0 to (font_h - 1) do
   for j:=0 to (abcLen - 1) do
     buf[dataStart + abcLen*i + j]:=font_array[i, j];

  // Корректируем длину глобального файла
  // GlobalFileSize += font_h * abs(delta);
  GlobalFileSize := GlobalFileSize + font_h * delta;

  assignfile (f, 'C:\GAMES\harv_cd\GRAPHIC\FONT\'+curfile);
  Rewrite (f);
  BlockWrite(f, Buf[0], GlobalFileSize);  // читаем весь файл туда
  CloseFile (f);

  ShowSymbol;

  form1.Memo1.Lines.Add('размер файла =' + IntToStr(GlobalFileSize));
  form1.Memo1.Lines.Add('ok');
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  symnum, i, j:LongInt;
begin
 symnum:=form1.fontnum.Position;
 for i:=0 to (font_h - 1) do
  for j:=0 to (font_w - 1) do
   begin
     font_array[i, j + font_start[symnum]]:=0;
   end;

 btn1Click(Sender);
end;

procedure TForm1.se1Change(Sender: TObject);
begin
//  if font_w <> se1.Value then btn1Click(Sender);
end;

procedure TForm1.encryptClick(Sender: TObject);
var
buf_loc :PByteArray;
f: file of Byte;
i,GFileSize:LongInt;
begin
// читаем
FileMode := fmShareDenyNone; // права доступа отключить ругань
AssignFile(f, 'dialogue.idx.final');
Reset(f);
GFileSize:=filesize(f);
GetMem(buf_loc, GFileSize ); // выделяем память буфферу, смещение + 2х2 байта разрешение
Blockread(f, buf_loc[0], GFileSize );  // читаем весь файл туда
CloseFile (f);

// Зашифровываем обратно, пропуская коды 10, 13
for i:=0 to (GFileSize - 1) do
 begin
  if ( (buf_loc[i]=10) or (buf_loc[i]=13) ) then continue;
  buf_loc[i]:=buf_loc[i] xor 170;
 end;

// пишем всё в каталог с игрой
AssignFile(f, 'C:\games\harv_cd\DIALOGUE.IDX');
Rewrite (f);
BlockWrite(f, buf_loc[0], GFileSize );
CloseFile (f);

Memo1.Lines.Add('done.');

end;

procedure TForm1.ScrollBar3Change(Sender: TObject);
begin
ReadInitFont (Form1.ScrollBar3.Position);
end;

procedure TForm1.ScrollBar4Change(Sender: TObject);
begin
Form1.mmo1.Lines.Clear;
Form1.mmo1.Lines.Add (OriginalStr[Form1.ScrollBar4.position*2]);
Form1.mmo1.Lines.Add (OriginalStr[Form1.ScrollBar4.position*2 + 1]);
Form1.lbl4.Caption:=IntToStr(Form1.ScrollBar4.position);
ScrollBar5.Position:=ScrollBar5.Position + 2;
ScrollBar5Change(sender);
end;

procedure TForm1.ScrollBar5Change(Sender: TObject);
begin
Form1.mmo2.Lines.Clear;
Form1.mmo2.Lines.Add (OriginalStr[Form1.ScrollBar4.position*2]);
Form1.mmo2.Lines.Add (TranslateStr[Form1.ScrollBar5.position]);
Form1.lbl5.Caption:=IntToStr(Form1.ScrollBar5.position);
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  f:TextFile;
  i:Integer;
begin
OriginalStr[Form1.ScrollBar4.position*2+1]:=TranslateStr[Form1.ScrollBar5.position];
AssignFile (f, 'dialogue.idx.final');
Rewrite (f);
for i:=0 to (ScrollBar4.Max*2+1) do
 Writeln (f, OriginalStr[i]);
CloseFile (f);
end;

end.
