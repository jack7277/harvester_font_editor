unit Unit1;
{$optimization off}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Spin, StrUtils;

type
  TForm1 = class (TForm)
    decrypt: TButton;
    Memo1: TMemo;
    encrypt: TButton;
    fontnum: TScrollBar;
    img1: TImage;
    zoom: TScrollBar;
    Label1: TLabel;
    Label2: TLabel;
    ColorChoose: TScrollBar;
    imgz: TImage;
    img3: TImage;
    SaveFont: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    seSymWidth: TSpinEdit;
    btn2: TButton;
    img2: TImage;
    FontChoose: TScrollBar;
    lbl3: TLabel;
    mmo1: TMemo;
    mmo2: TMemo;
    ScrollBar4: TScrollBar;
    ScrollBar5: TScrollBar;
    _SaveTranslation: TButton;
    lbl4: TLabel;
    lbl5: TLabel;
    chk1: TCheckBox;
    datUnpack: TButton;
    chk2: TCheckBox;
    bmpFontImport: TButton;
    btn1: TButton;
    btn3: TButton;
    btn4: TButton;
    Button1: TButton;
    procedure decryptClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure fontnumChange(Sender: TObject);
    procedure zoomChange(Sender: TObject);
    procedure img1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure img1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ColorChooseChange(Sender: TObject);
    procedure SaveFontClick(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure seSymWidthChange(Sender: TObject);
    procedure encryptClick(Sender: TObject);
    procedure FontChooseChange(Sender: TObject);
    procedure ScrollBar4Change(Sender: TObject);
    procedure ScrollBar5Change(Sender: TObject);
    procedure _SaveTranslationClick(Sender: TObject);
    procedure harvestscrBuilderClick(Sender: TObject);
    procedure datUnpackClick(Sender: TObject);
    procedure bmpFontImportClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  OriginalStr, TranslateStr : array [0..6000] of string;
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

 npc_names_rus_cd3 : array [0..31] of AnsiString;
 npc_names_rus : array [0..30] of AnsiString;
 map_stuff_rus:array [0..25] of AnsiString;

 const map_stuff_eng:array [0..25] of AnsiString=(
'Barber_Shop', 'General_Store', 'The_Lodge',  'Missile_Base',
'Your_House', 'Post_Office', 'Pottsdam_Residence', 'Johnson_Residence',
'The_Lodge', 'Shady_Oaks_Mortuary', 'Cemetery', 'Pottsdam_Residence',
'Abandoned_House', 'Edna''s_Diner', 'The_Lodge', 'Meat_Plant',
'Missile_Base', 'Gein_Memorial_School', 'TV_Station', 'Cemetery',
'Wayward_Hotel', 'Edna''s_Diner', 'Fire_Station', 'The_Lodge',
'Police_Station' , 'Newspaper_Building');

 // cd1-2, имена
 const npc_names_eng:array [0..30] of AnsiString=(
 'Hank', 'Mom', 'Jimmy_James', 'Dad', 'Mr._Pottsdam',
 'Mrs._Pottsdam', 'Stephanie', 'Sheriff_Dwayne', 'Mr._Parsons', 'Mr._Swell',
 'Mr._Pastorelli', 'Karin', 'Edna', 'Fireman', 'Spots',
 'Male_Model', 'Sparky', 'Mrs._Phelps', 'Mr._Moynahan', 'Pat_O''Reilly',
 'Mr._Johnson', 'Colonel_Buster_Monroe', 'Postmaster_Boyle', 'Principal_Herrill', 'Ms._Whaley',
 'PTA_Mom', 'Deputy_Loomis', 'Range_Ryder', 'Mr._McKnight', 'Tetsua_Crumb',
 'Sergeant_at_Arms');

 // cd3 имена NPC
 const npc_names_eng_cd3:array [0..31] of AnsiString=(
 'Valet', 'big_eye', 'cloak_room_attendant', 'Lodge_chef', 'plant',
 'art_curator', 'Chessmaster', 'Cain', 'membership_director', 'maintenance_man',
 'Librarian', 'man_in_suit', 'fat_Elvis', 'woman', 'Cannibal_kid',
 'Priest', 'Follower', 'War_veteran', 'Mr._Pottsdam', 'Madam',
 'Hooker', 'Dark_woman', 'tortured_man', 'Inquisitor', 'Beggar',
 'Gladiator', 'Old_man', 'Old_woman', 'Herrill', 'Grand_Muckey_Muck',
 'Sergeant_At_Arms', 'Stephanie' );

implementation
{$R *.dfm}

procedure TranslateSCR (s_1, s_2, s_3 : string; cd:integer); // cd=3 диск 3, другие значения CD=1
var
  f, fout, frus, ftablerus:TextFile;
  i,j, pos1, pos2, off1, size1, map_stuff_index, npc_names_index, BoxNum, index:Integer;
  OriginalString, s2, srus, str1, tmp1, tmp2:string;
  StupidStr:boolean;
  ANSIstr1 : AnsiString;
  UTFstr1  : UTF8String;
  StrCount, ArrayLen : Integer;

label a1, a2;
begin
 //StrCount := 0;
 AssignFile (f, s_1);  // Английский текст скрипта
 //AssignFile (fout, 'descr.txt');     // Английский список названий предметов и их описаний
 AssignFile (frus, s_2); // Русский текст скрипта
 AssignFile (ftablerus, s_3); // Русский список названий предметов и их описаний

 Reset(f);
 Reset(ftablerus);
 //Rewrite (fout);
 Rewrite (frus);

 while (not(Eof(f))) do
  begin
   Readln (f, OriginalString);  // Читаем строку оригинала cd12\harvest.str, скрипт
   StupidStr:=true; // Думаем, что это строка, которая не несет смысла для перевода

  // Далее идет поиск по OBJECT, поэтому эту функцию суем вперед и делаем пропуск хода
  // так как тут тоже есть слово OBJECT.
  // Правим баг с банками с супом
  // исправлено в GOG версии
   pos1 := Pos('OBJECT "STORECU" "STORE_SOUP"', OriginalString);
   if pos1 <> 0 then
     begin
       StupidStr := False;
       tmp1:='362 221 532 279 50 1  OBJECT "STORECU" "STORE_SOUP"        "" "" "" "" "" "STORE_SOUP_TEXT"        "F" "T" "" "банки_с_супом"';
       Writeln (frus, tmp1);
       Readln (ftablerus, UTFstr1);  // делаем пропуск строки "банки_с_супом"
       if (UTFstr1='') then Readln (ftablerus, UTFstr1);  // пропуск пустой строки
       ANSIstr1 := Utf8ToAnsi(UTFstr1);
 //      Continue;
       goto a1;
     end;

   // убираем комментарии у объекта ADULTMAGCU
   pos1 := pos('ADULTMAGCU', OriginalString);
   if pos1 <> 0 then
    begin
     OriginalString := Trim(OriginalString);
     Delete(OriginalString, 1, 3); // убираем в начале {//
     goto a1;
    end;

   // Ищем BOX и всё что за ним это фраза для перевода
   pos1 := pos('"BOX', OriginalString);
   if pos1 <> 0 then
    for BoxNum:=1 to 4 do
     begin
      pos1:=Pos('"BOX' + inttostr(BoxNum), OriginalString);
      if pos1 <> 0 then   // Нашли BOX
       begin
        StupidStr := False;    // уже не другая строка, обрабатываем и записываем сами
        off1 := pos1 + 7;   // Смещаем указатель за "BOX1", 6 символов + 1 пробел
        size1 := Length(OriginalString) - pos1 - 5; // Берем размер последней фразы
        s2 := Copy(OriginalString, off1, size1); // Копируем фразу в конце строки с BOX1234
        srus:=OriginalString;          // Делаю копию оригинальной строки
        Delete (srus, off1, size1); // Удаляю английскую фразу

        Readln (ftablerus, UTFstr1);   // Читаю русскую фразу
        while (UTFstr1='') do
         Readln (ftablerus, UTFstr1);

        ANSIstr1 := Utf8ToAnsi(UTFstr1);
        ANSIstr1 := trim (ANSIstr1);
        while (ANSIstr1[1]='?') do
         Delete (ANSIstr1, 1, 1);

        str1:=StringReplace(ANSIstr1, ' ', '_', [rfReplaceAll]); // Меняю все пробелы на подчерки
        srus:=srus + str1; // Склеиваю уже русскую строку целиком

        srus:=Trim(srus);   // Обрезаем всю хрень
        if BoxNum=1 then srus:=StringReplace(srus, '"BOX1', '"BOX4', [rfReplaceAll] ); // BOX1 слишком узкий квадрат
        if BoxNum=2 then srus:=StringReplace(srus, '"BOX2', '"BOX4', [rfReplaceAll] ); // BOX2 слишком узкий квадрат, текст не влезат

        // патчим строку с SCHLHL_LOCKER1_LTEXT на BOX4
        //if (pos('SCHLHL_LOCKER1_LTEXT', OriginalString) <> 0) then


        Writeln (frus, srus); // Пишем в русский скрипт HARVEST.SCR.RUS

 //      s2:=Trim(StringReplace(s2, '_', ' ',[rfReplaceAll])); // Здесь заполняем descr.txt с англ фразами
 //      Writeln (fout, s2);                                   // тут пишем
        goto a1;   // Нашли к примеру BOX2 и выходим из цикла
       end;
     end;

   /////// Ищем OBJECT и берем конец фразы ///////////
   pos1:=Pos('OBJECT', OriginalString);
   if pos1<>0 then   // Нашли OBJECT
    begin
     off1 := Length(OriginalString) - 1; // Начало смещения на 1 символ меньше, пропускаем кавычку " закрывающую
     while (OriginalString[off1] <> '"') do Dec(off1); // Идем влево ищем кавычку открывающую
     size1 := Length(OriginalString) - off1 + 1; // Размер последней фразы
     s2 := Trim(Copy(OriginalString, off1, size1));   // Оригинал на англ фразы строки OBJECT, название предметов
     // Пропускаем мусор
     //tmp1:=s2;
     //tmp1:=Trim(StringReplace(str1, '"', '',[rfReplaceAll]));
     if ( (s2[1]='{') or (s2='"NULL_ID"') ) then goto a1; // выходим, мусор

     // уже не другая строка
     StupidStr := False;

     srus := OriginalString; // Делаю копию оригинальной строки
     Delete (srus, off1, size1); // Удаляю английскую фразу
     Readln (ftablerus, UTFstr1);   // Читаю русскую фразу

     while (UTFstr1='') do
      Readln (ftablerus, UTFstr1);

     ANSIstr1 := Trim(Utf8ToAnsi(UTFstr1));

     while (ANSIstr1[1]='?') do Delete (ANSIstr1, 1, 1);

     str1:=StringReplace(ANSIstr1, ' ', '_',[rfReplaceAll]);  // Меняю все пробелы на подчерки
     srus:=srus + str1;  // Склеиваю уже русскую строку целиком
     srus:=Trim(srus);  // Обрезаем всю хрень
     Writeln (frus, srus); // Пишем в русский скрипт HARVEST.SCR.RUS

     goto a1; // выходим
 //    s2:=Trim(StringReplace(s2, '_', ' ',[rfReplaceAll])); // Здесь заполняем descr.txt с англ фразами
 //    Writeln (fout, s2);                                   // тут пишем
    end;

   // Ищем MAP_LOCATION и Название локации, заменяем на русский
    pos1 := Pos('MAP_LOCATION', OriginalString);
    if pos1 <> 0 then
    begin
     ArrayLen := Length (map_stuff_eng);
     for index:=0 to (ArrayLen - 1) do
      begin
       pos1:=Pos(map_stuff_eng[index], OriginalString);
       pos2:=Pos('MAP_LOCATION', OriginalString);
       if ( (pos1<>0) and (pos2<>0) ) then   // Нашли название локации на карте
         begin
           Delete (OriginalString, pos1, Length(map_stuff_eng[index]));
           Insert (map_stuff_rus[index], OriginalString, pos1);
           goto a1; // выходим, запишем изменения
         end;
      end;
    end;
     /// вот досюда, конец.

   // Ищем NPC с пробелом в начале и конце и имя персонажа в конце
    pos1 := Pos(' NPC ', OriginalString);
    if pos1 <> 0 then
    begin
     if cd = 12 then ArrayLen := Length (npc_names_eng);
     if cd = 3 then ArrayLen := Length (npc_names_eng_cd3);

     for index:=0 to (ArrayLen - 1) do
      begin
       if cd = 12 then
        begin
         pos1 := Pos(npc_names_eng[index], OriginalString);
         tmp2 := npc_names_eng[index];
        end;
       if cd = 3 then
        begin
         pos1 := Pos(npc_names_eng_cd3[index], OriginalString);
         tmp2 := npc_names_eng_cd3[index];
        end;
       // обработать OriginalString на полное совпадение имени
       i := pos1;
       while (OriginalString[i - 1] <> '"') do dec(i);
       pos1 := i;
       while (OriginalString[i] <> '"') do inc(i);
       i := i - pos1;
       tmp1 := copy(OriginalString, pos1, i);

       pos2:=Pos(' NPC ', OriginalString);

       if ( (pos1<>0) and (pos2<>0) and (tmp1=tmp2) ) then   // Нашли название локации на карте
         begin
           if cd = 12 then
            begin
             Delete (OriginalString, pos1, Length(npc_names_eng[index]));
             Insert (npc_names_rus[index], OriginalString, pos1);
             goto a1; // выходим, запишем изменения
            end;

           if cd = 3 then
            begin
             Delete (OriginalString, pos1, Length(npc_names_eng_cd3[index]));
             Insert (npc_names_rus_cd3[index], OriginalString, pos1);
             goto a1; // выходим, запишем изменения
            end;
         end;
      end;
    end;

   // конец.
   a1: if (StupidStr = True) then Writeln (frus, OriginalString); // Пишем строки скрипта, не интересующие нас
  end;

 CloseFile (f);
 CloseFile (frus);
 CloseFile (ftablerus);
end;


function getDWORD(offset:LongInt; buf:PByteArray):LongInt ;
begin
 Result:=buf[offset + 0] + 256*buf[offset + 1] + 256*256*buf[offset + 2] + 256*256*256*buf[offset + 3];
end;

function getWORD (offset:LongInt; buf:PByteArray):LongInt;
begin
  Result := buf[offset + 0] + 256*buf[offset + 1];
end;

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
// form1.Memo1.Lines.Clear;
// код под таблице cp1251
 curpos:=Form1.fontnum.Position;

 // высота шрифта, ширина шрифта, стартовый адрес
 font_h := buf[dataStart - 8] - 1;
 font_w := font_width[curpos];
 start := font_start[curpos];

 form1.img1.Width := font_w;
 form1.img1.Height := font_h;

 Form1.img1.Picture := nil;
 Form1.img2.Picture := nil;
 Form1.img3.Picture := nil;

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
    form1.img3.Canvas.Pixels [j+1, i+1]:= RGB(r,g,b);

   end;

 Form1.img1.Height:=form1.zoom.Position * font_h;
 form1.img1.Width:=form1.zoom.Position * font_width[curpos];
 Form1.img1.Canvas.Refresh;

 form1.Memo1.Lines.Add('Ширина шрифта=' + IntToStr(font_w));
 form1.Memo1.Lines.Add('Высота шрифта=' + IntToStr(font_h));

 form1.seSymWidth.value:=font_w;

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
 if fontnum=0 then fname:='.\files\font\TEXTFONT.CFT';
 if fontnum=1 then fname:='.\files\font\TEXTFNT2.CFT';
 if fontnum=2 then fname:='.\files\font\MEDFONT1.CFT';
 if fontnum=3 then fname:='.\files\font\MEDFONT2.CFT';
 if fontnum=4 then fname:='.\files\font\HARVFONT.CFT';
 if fontnum=5 then fname:='.\files\font\HARVFNT2.CFT';
 if fontnum=6 then fname:='.\files\font\_SMALFONT.CFT';
 if fontnum=7 then fname:='.\files\font\FONTWT2.CFT';
 if fontnum=8 then fname:='.\files\font\TYPEFONT.CFT';

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

fname:='.\files\INVHELP.PAL';
AssignFile(fin, fname);
Reset(fin);
fsize:=FileSize(fin);
GetMem(buf_pal, FSize); // выделяем память буфферу
Blockread(fin, buf_pal[0], FSize);  // читаем весь файл туда
CloseFile (fin);
///////////////////////////
StartOffsetOfOffset:=$44; // 44h
StartOffsetWidth:=$0244;    // 0244h
datastart:=$0454;    // 0454h

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

procedure writeDWORD (num, offset:LongInt; var buftmp:PByteArray);
var
  byte0, byte1, byte2, byte3:Byte;
begin
 // Пишем смещение блока
  BYTE3:=Trunc(num/(256*256*256));
  BYTE2:=Trunc ((num - BYTE3 *256*256*256)/(256*256));
  BYTE1:=Trunc ((num - BYTE2*256*256 - BYTE3*256*256*256)/(256));
  BYTE0:=num - BYTE1*256 - BYTE2*256*256 - BYTE3*256*256*256;

  buftmp[offset + 0]:=byte0;
  buftmp[offset + 1]:=byte1;
  buftmp[offset + 2]:=byte2;
  buftmp[offset + 3]:=byte3;
end;

procedure writeWORD (num, offset:LongInt; var buftmp:PByteArray);
var
  byte0, byte1:Byte;
begin
 // Пишем смещение блока
 BYTE1:=Trunc (num / 256);
 BYTE0:=num - BYTE1*256;

 buftmp[offset + 0]:=byte0;
 buftmp[offset + 1]:=byte1;
end;


procedure DexorFile (fname:string);
var
  buf   : PByteArray;
 i:longint;
fin:file of Byte;
globalfilesize:LongInt;
begin
FileMode := fmShareDenyNone; // права доступа отключить ругань
AssignFile(fin, fname);
Reset(fin);
GlobalFileSize := FileSize(fin);
GetMem(Buf, GlobalFileSize); // выделяем память буфферу
Blockread(fin, Buf[0], GlobalFileSize);  // читаем весь файл туда
CloseFile (fin);
for i:=0 to (GlobalFileSize - 1) do
 begin
   if ( (buf[i]=$0D) or (buf[i]=$0A) ) then Continue;
   buf[i]:=buf[i] xor 170;
 end;

AssignFile(fin, fname + '.decrypted');
Rewrite(fin);
BlockWrite (fin, Buf[0], GlobalFileSize);  // читаем весь файл туда
CloseFile (fin);
FreeMem(Buf); // освободить, закрыть и уйти.

end;

procedure TForm1.decryptClick(Sender: TObject);
begin
DexorFile('.\Files\cd12\DIALOGUE.IDX');
DexorFile ('.\Files\cd12\harvest.scr');
DexorFile('.\Files\cd3\harvest.scr');

Memo1.Text:='done';
end;

procedure FillTranslateStr;
var
  cou1, i : Integer;
  f1 : TextFile;
ANSIstr1 : ansistring;
UTFstr1  : UTF8String;
begin
 // 3 файла
 // DIALOGUE.IDX.CD1.TXT - 1265 строк
 // DIALOGUE.IDX.CD1.TXT-2 - 419 строк
 // DIALOGUE.IDX.CD1.TXT-3 - 849 строк
  cou1:=0;
  AssignFile (f1, '.\benoid\DIALOGUE.IDX.CD1.TXT.txt');
  Reset(f1);
  for i:=0 to 1264 do
   begin
    Readln (f1, UTFstr1);
    while (UTFstr1='') do
     readln (f1, UTFstr1);

    ANSIstr1 := Utf8ToAnsi(UTFstr1);
    ANSIstr1 := trim (ANSIstr1);
    while (ANSIstr1[1]='?') do
      Delete (ANSIstr1, 1, 1);

    TranslateStr[cou1] := ANSIstr1;
    inc (cou1);
   end;
  CloseFile (f1);

  AssignFile (f1, '.\benoid\DIALOGUE.IDX.CD1.TXT-2.txt');
  Reset(f1);
  for i:=0 to 418 do
   begin
    Readln (f1, UTFstr1);
    while (UTFstr1='') do
     readln (f1, UTFstr1);

    ANSIstr1 := Utf8ToAnsi(UTFstr1);
    ANSIstr1 := trim (ANSIstr1);
    while (ANSIstr1[1]='?') do
      Delete (ANSIstr1, 1, 1);

    TranslateStr[cou1] := ANSIstr1;
    inc (cou1);
   end;
  CloseFile (f1);

  AssignFile (f1, '.\benoid\DIALOGUE.IDX.CD1.TXT-3.txt');
  Reset(f1);
  for i:=0 to 848 do
   begin
    Readln (f1, UTFstr1);
    while (UTFstr1='') do
     readln (f1, UTFstr1);

    ANSIstr1 := Utf8ToAnsi(UTFstr1);
    ANSIstr1 := trim (ANSIstr1);
    while (ANSIstr1[1]='?') do
      Delete (ANSIstr1, 1, 1);

    TranslateStr[cou1] := ANSIstr1;
    inc (cou1);
   end;
  CloseFile (f1);

 Form1.ScrollBar5.Max := cou1 - 1;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
cou1, i:Integer;
f1,f2:TextFile;
str:string;
ANSIstr1 : ansistring;
UTFstr1  : UTF8String;
begin
  ReadInitFont (Form1.FontChoose.Position);
  // FillTranslateTable, читаем заполняем оригинал
  AssignFile (f1, '.\files\cd12\DIALOGUE.IDX.decrypted');
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

 // 3 файла
 // DIALOGUE.IDX.CD1.TXT - 1265 строк
 // DIALOGUE.IDX.CD1.TXT-2 - 419 строк
 // DIALOGUE.IDX.CD1.TXT-3 - 849 строк
  FillTranslateStr;

  Form1.ScrollBar5.Min := 0;
  Form1.ScrollBar5.Position := 0;

 // Читаем создаем массив русских имен
 AssignFile (f1, '.\benoid\Имена_персонажей,_CD1,_2_(для_единого_написания).txt');
 Reset (f1);
 for i:=0 to 30 do
  begin
   Readln (f1, UTFstr1);
   while (UTFstr1='') do readln (f1, UTFstr1);
   ANSIstr1 := Utf8ToAnsi(UTFstr1);
   ANSIstr1 := trim (ANSIstr1);
   while (ANSIstr1[1]='?') do Delete (ANSIstr1, 1, 1);
   ANSIstr1:=StringReplace(ANSIstr1, '"', '',[rfReplaceAll]);  // убираем кавычки

   npc_names_rus[i] := ANSIstr1;
  end;
 CloseFile (f1);

 AssignFile (f1, '.\benoid\Имена_персонажей,_CD3_(для_единого_написания).txt');
 Reset (f1);
 for i:=0 to 31 do
  begin
   Readln (f1, UTFstr1);
   while (UTFstr1='') do readln (f1, UTFstr1);
   ANSIstr1 := Utf8ToAnsi(UTFstr1);
   ANSIstr1 := trim (ANSIstr1);
   while (ANSIstr1[1]='?') do Delete (ANSIstr1, 1, 1);
   ANSIstr1:=StringReplace(ANSIstr1, '"', '',[rfReplaceAll]);  // убираем кавычки
   npc_names_rus_cd3[i] := ANSIstr1;
  end;
 CloseFile (f1);

 AssignFile (f1, '.\benoid\Map_(Названия_локаций_на_карте).txt');
 Reset (f1);
 for i:=0 to 25 do
  begin
   Readln (f1, UTFstr1);
   while (UTFstr1='') do readln (f1, UTFstr1);
   ANSIstr1 := Utf8ToAnsi(UTFstr1);
   ANSIstr1 := trim (ANSIstr1);
   while (ANSIstr1[1]='?') do Delete (ANSIstr1, 1, 1);
   ANSIstr1:=StringReplace(ANSIstr1, '"', '',[rfReplaceAll]);  // убираем кавычки
   map_stuff_rus[i] := ANSIstr1;
  end;
 CloseFile (f1);

ScrollBar4Change(Sender);
ShowSymbol;
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

procedure TForm1.zoomChange(Sender: TObject);
begin
Form1.img1.Height:=form1.zoom.Position * font_h;
form1.img1.Width:=form1.zoom.Position * font_width[Form1.fontnum.Position];
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

// Синий цвет фона - это байт 0, белый - FFh
index:=form1.ColorChoose.Position;
if (Button = mbRight) then index:=0;

font_array[my, mx ]:=index;
end;

procedure TForm1.img1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
kx:=trunc (form1.img1.Width / font_width[Form1.fontnum.Position]);
ky:=trunc (Form1.img1.Height / font_h);

//label1.Caption:='x=' + inttostr(x) + ' ,y=' + inttostr (y);
//Label2.Caption:='Color=' + inttostr (form1.img1.Canvas.Pixels[Trunc(X/kx), Trunc(Y/ky)]);
end;

procedure TForm1.ColorChooseChange(Sender: TObject);
var
  i,j,col, r,g,b:Integer;
begin
 col:=form1.ColorChoose.Position;
 for i:=0 to 39 do
  for j:=0 to 109 do
    begin
     r:=buf_Pal[col*3 + 0];
     g:=buf_Pal[col*3 + 1];
     b:=buf_Pal[col*3 + 2];

     form1.imgz.Canvas.Pixels [j, i]:= RGB(r,g,b);
    end;
 PenColor:=RGB(r,g,b);
end;

procedure TForm1.SaveFontClick(Sender: TObject);
var
 delta:Integer; // насколько увеличиваем-уменьшаем ширину
 i,j,k, new_off, curcol, GamePalColor:LongInt;
 symnum, r,g,b, kx, ky, w:integer;
 byte0, byte1:byte;
 f:file of Byte;
begin
 symnum:=form1.fontnum.Position;
 delta:=Form1.seSymWidth.Value - font_w;
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
    SaveFontClick(Sender);
    Exit;
   end;

  // Сдвигаем всё на дельту
   for i:=0 to (Abs(delta) - 1) do
    for k:=0 to (font_h - 1) do
     for j:=abcLen downto ( (font_start[symnum]) + font_w ) do
      begin
       if (delta>0) then font_array[k, j + i + 1]:=font_array[k, j + i];
       if (delta<0) then font_array[k, font_start[symnum] + font_w - 1 + abclen - j + i]:=font_array[k, font_start[symnum]+font_w-1 + abclen - j + i + 1];
      end;

 // Увеличение ширины
 if (delta>0) then
  begin
    //Надо почистить новое место от сдвинутых чисел
    for i:=0 to (font_h - 1) do
     for j:=0 to (delta - 1) do
       font_array[i,j + font_start[symnum] + font_w]:=0;
  end;

    // Скорректировать нач смещения следующих символов
    // font_start и buf
    // Все смещения вперемежку, поэтому надо смотреть чтобы было больше текущего
   for i:=0 to 255 do
     begin
      if (font_start[i] > font_start[symnum]) then
       begin
        new_off := font_start[i] + delta;
        font_start[i] := new_off;

        BYTE0 := Trunc(new_off / 256);  // старший байт
        BYTE1 := new_off - BYTE0 * 256;    // младший байт

        buf[StartOffsetOfOffset + i*2 + 0] := byte1;
        buf[StartOffsetOfOffset + i*2 + 1] := byte0;
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

  // удаляем .\files\font\
  if (curFile[1]='.') then Delete (curFile, 1, Length('.\files\font\'));
  assignfile (f, '.\temp\' + curfile);
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

 SaveFontClick(Sender);
end;

procedure TForm1.seSymWidthChange(Sender: TObject);
begin
//  if font_w <> se1.Value then btn1Click(Sender);
end;

procedure XorFile (fname:string);
var
buf_loc :PByteArray;
f: file of Byte;
i,GFileSize:LongInt;
s:string;
begin
// читаем
FileMode := fmShareDenyNone; // права доступа отключить ругань
AssignFile(f, fname );
Reset(f);
GFileSize:=filesize(f);
GetMem(buf_loc, GFileSize ); // выделяем память буфферу, смещение + 2х2 байта разрешение
Blockread(f, buf_loc[0], GFileSize );  // читаем весь файл туда
CloseFile (f);
// Зашифровываем обратно, пропуская коды 10, 13
for i:=0 to (GFileSize - 1) do
 begin
  if ( (buf_loc[i]=$0A) or (buf_loc[i]=$0D) ) then continue;
  buf_loc[i]:=buf_loc[i] xor 170;
 end;

if fname='.\temp\dialogue.idx.final' then s:='.\rus\DIALOGUE.IDX';
if fname='.\temp\_cd12_HARVEST.SCR' then s:='.\rus\harvest.scr';
if fname='.\temp\_cd3_harvest.scr' then s:='.\rus\cd3\harvest.scr';

// пишем всё в каталог с игрой
AssignFile(f, s);
Rewrite (f);
BlockWrite(f, buf_loc[0], GFileSize );
CloseFile (f);
end;

procedure TForm1.encryptClick(Sender: TObject);
begin
XorFile('.\temp\dialogue.idx.final');
XorFile('.\temp\_cd12_HARVEST.SCR');
XorFile('.\temp\_cd3_harvest.scr');
Memo1.Lines.Add('done.');
end;

procedure TForm1.FontChooseChange(Sender: TObject);
begin
ReadInitFont (Form1.FontChoose.Position);
ShowSymbol;
end;

procedure TForm1.ScrollBar4Change(Sender: TObject);
begin
Form1.mmo1.Lines.Clear;
Form1.mmo1.Lines.Add (OriginalStr[Form1.ScrollBar4.position*2]);
Form1.mmo1.Lines.Add (OriginalStr[Form1.ScrollBar4.position*2 + 1]);
Form1.lbl4.Caption:=IntToStr(Form1.ScrollBar4.position);
ScrollBar5.Position := ScrollBar5.Position + 1;
ScrollBar5Change(sender);

if chk1.Checked then _SaveTranslationClick(Sender);
end;

procedure TForm1.ScrollBar5Change(Sender: TObject);
begin
Form1.mmo2.Lines.Clear;
Form1.mmo2.Lines.Add (OriginalStr[Form1.ScrollBar4.position*2]);
Form1.mmo2.Lines.Add (TranslateStr[Form1.ScrollBar5.position]);
Form1.lbl5.Caption:=IntToStr(Form1.ScrollBar5.position);
end;

procedure TForm1._SaveTranslationClick(Sender: TObject);
var
  f, fout:TextFile;
  i, k:Integer;

 s_1, s_2, s_3:string;
 cd : Integer;
 UTFstr1 : UTF8String;
 AnsiStr1 : AnsiString;
 tmpStr : array of string;
begin
OriginalStr[Form1.ScrollBar4.position*2 + 1] := TranslateStr[Form1.ScrollBar5.position];
if chk2.Checked then
 begin
   // Сбрасываем DIALOGUE.IDX ----------------------------------
   for i := 0 to Form1.ScrollBar4.Max do
    OriginalStr[i*2 + 1] := TranslateStr[i];

   AssignFile (f, '.\rus\dialogue.idx');
   Rewrite (f);

   for i := 0 to (ScrollBar4.Max*2 + 1) do
     Writeln (f, OriginalStr[i]);

   CloseFile (f);
   // Сбрасываем DIALOGUE.IDX ----------------------------------

  // Обрабатываем cd 1,2 harvest.scr
  s_1 := '.\files\cd12\HARVEST.SCR.decrypted';
  s_2 := '.\temp\_cd12_HARVEST.SCR';
  s_3 := '.\benoid\Объекты_и_описания_оных_(cd1,_cd2).txt';
  cd := 12;
  TranslateSCR (s_1, s_2, s_3, cd);

  // Обрабатываем cd3 harvest.scr
  s_1 := '.\files\cd3\harvest.scr.decrypted';
  s_2 := '.\temp\_cd3_harvest.scr';
  s_3 := '.\benoid\Объекты_и_описания_оных_(cd3).txt';
  cd := 3;
  TranslateSCR (s_1, s_2, s_3, cd);

  // Создаем dialog.rsp (Ключевые фразы диалогов)
  AssignFile (f, '.\benoid\dialog.rsp_(Ключевые_фразы_диалогов).txt');
  AssignFile (fout, '.\rus\dialog.rsp');

  Reset (f);
  Rewrite (fout);

  for i:=0 to 782 do
   begin
    Readln (f, UTFstr1);
    while (UTFstr1='') do readln (f, UTFstr1);

    ANSIstr1 := Trim(Utf8ToAnsi(UTFstr1));

    while (ANSIstr1[1]='?') do Delete (ANSIstr1, 1, 1);

    // Если оставить writeln, то в конце dialog.rsp добавляется 0Dh, 0Ah, а их не должно быть
    if (i=782) then
     begin
      write (fout, AnsiStr1);
      continue;
     end;

    Writeln (fout, ANSIstr1);
   end;
  CloseFile (f);
  CloseFile (fout);
  //------------------------------------------------------------------

  // ADJHEAD.RCS -----------------------------------------------------
  // Game Hints
  AssignFile (f, '.\benoid\Game_Hints.txt');
  AssignFile (fout, '.\rus\ADJHEAD.RCS');

  Reset (f);
  Rewrite (fout);

  // В списке 24 совета
  for i := 0 to 23 do
   begin
    Readln (f, UTFstr1);
    while (UTFstr1='') do readln (f, UTFstr1);

    ANSIstr1 := Trim(Utf8ToAnsi(UTFstr1));
    while (ANSIstr1[1]='?') do Delete (ANSIstr1, 1, 1);

    Writeln (fout, ANSIstr1);
   end;
  CloseFile (f);
  CloseFile (fout);
  // ADJHEAD.RCS -----------------------------------------------------

  // Патчим harvest.scr для CD1-2
  k := 1;
  AssignFile (f, '.\temp\_cd12_HARVEST.SCR');
  Reset (f);
  SetLength (tmpStr, k);

  while (not(Eof(f))) do
   begin
    readln (f, tmpStr[k - 1]);
    inc (k);
    SetLength (tmpStr, k);
   end;
  CloseFile (f);
  DeleteFile('.\temp\_cd12_HARVEST.SCR');

  // патчим
  tmpStr[1619] := '172 293 199 319 74 1 OBJECT "BARB_OUT" "BARB_CLOSED" "\GRAPHIC\MASKS\BAR2CLOS.BM" "" "" "" "" "" "F" "F"  "" "NULL_ID"';
  tmpStr[2854] := '289 252 331 290 89 1 OBJECT "DNAEXT" "DNA_CLOSED" "\GRAPHIC\MASKS\EDNACLOS.BM" "" "" "" "" "" "F" "F" "" "NULL_ID"';
  tmpStr[6699] := '501 105 50  5 ANIM "TV_FSTD" "\GRAPHIC\ROOMANIM\APPLAUSE.ABM" "APPLAUSE" "T" "T" "T" "F" "F" "F"';
  tmpStr[5]    := '299 0 0 0 2 1 OBJECT "NULL_ID" "EXIT_BM"  "\GRAPHIC\OTHER\EXITSIGN.BM" "" "" "" ""  "" "F" "T" "" "выход"';
  tmpStr[3887] := '257 311 284 328 89 0 OBJECT "STORE_OUT" "STORE_CLOSED" "\GRAPHIC\MASKS\GENCLOSE.BM"   "" "" "" "" "" "F" "F" "" "NULL_ID"';
  tmpStr[5469] := '305 273 331 290 89 1 OBJECT "POST" "POST_CLOSED" "\GRAPHIC\MASKS\POSTCLOS.BM" "" "" "" "" "" "F" "F" "" "NULL_ID"';
  tmpStr[2932] := '102 78 85 15 ANIM "DNAEXT" "\GRAPHIC\ROOMANIM\EDNASIGN.ABM" "DNAEXT_SIGN"      "T" "T" "T" "F" "F" "F"';
  tmpStr[4180] := '413 332 89 15 ANIM "HOTEL" "\GRAPHIC\ROOMANIM\HOTLSIGN.ABM" "HOTLSIGN" "T" "T" "T" "F" "F" "F"';
  tmpStr[3964] := '270 284 54 15 ANIM "STORE_IN" "\GRAPHIC\ROOMANIM\COPIER.ABM"   "COPIER"   "F" "T" "F" "F" "T" "F"'; 

  // записываем назад изменения
  AssignFile (f, '.\rus\cd12\harvest.scr');
  Rewrite (f);
  for i := 0 to (k-1) do
   Writeln (f, tmpstr[i]);
  CloseFile (f);
  // Конец патча harvest.scr для CD1-2

  // Патчим harvest.scr для CD3
    k := 1;
  AssignFile (f, '.\temp\_cd3_HARVEST.SCR');
  Reset (f);
  SetLength (tmpStr, k);

  while (not(Eof(f))) do
   begin
    readln (f, tmpStr[k - 1]);
    inc (k);
    SetLength (tmpStr, k);
   end;
  CloseFile (f);
  DeleteFile('.\temp\_cd3_HARVEST.SCR');

  // патчим
  tmpStr[785] := '516 269 60 15  ANIM "GAMEROOM" "\GRAPHIC\ROOMANIM\GAMEPINB.ABM" "GAMEPINB" "T" "T" "T" "F" "F" "F"';

  // записываем назад изменения
  AssignFile (f, '.\rus\cd3\harvest.scr');
  Rewrite (f);
  for i := 0 to (k-1) do
   Writeln (f, tmpstr[i]);
  CloseFile (f);
  // Конец патча harvest.scr для CD3


  form1.Memo1.Lines.Add('done');
  // XorFile('.\temp\dialogue.idx.final');
  // XorFile('.\temp\_cd12_HARVEST.SCR');
  // XorFile('.\temp\_cd3_harvest.scr');

  Memo1.Lines.Add('done.');
 end;
end;

procedure TForm1.harvestscrBuilderClick(Sender: TObject);
var
 s_1, s_2, s_3:string;
 cd : Integer;
begin
 // Обрабатываем cd 1,2 harvest.scr
  s_1 := '.\files\cd12\HARVEST.SCR.decrypted';
  s_2 := '.\temp\_cd12_HARVEST.SCR';
  s_3 := '.\benoid\Объекты_и_описания_оных_(cd1,_cd2).txt';
  cd := 12;
 TranslateSCR (s_1, s_2, s_3, cd);

 // Обрабатываем cd3 harvest.scr
  s_1 := '.\files\cd3\harvest.scr.decrypted';
  s_2 := '.\temp\_cd3_harvest.scr';
  s_3 := '.\benoid\Объекты_и_описания_оных_(cd3).txt';
  cd := 3;
 TranslateSCR (s_1, s_2, s_3, cd);
 form1.Memo1.Lines.Add('done');
end;

procedure UnpackDat (fname:string);
var
buf   : PByteArray;
GlobalFileSize, pos1, i, fsize:longint;
fin, fout:file of Byte;
dir, fname2:string;
logout : TextFile;
const
  fsize_offset=$90; // смещение от начала, размер файла - 4 байта в LE
  data_offset=$94; // смещение начала данных файла
  path_start = 6;  // смещение начала пути
begin
//ForceDirectories('.\GRAPHIC\ROOMANIM\');
FileMode := fmShareDenyNone; // права доступа отключить ругань
AssignFile(fin, fname);
Reset(fin);
GlobalFileSize := FileSize(fin);
GetMem(Buf, GlobalFileSize); // выделяем память буферу
Blockread(fin, Buf[0], GlobalFileSize);  // читаем весь файл туда
CloseFile (fin);

AssignFile (logout, fname + '.log');
Rewrite (logout);
// Разбираем на файлы, создаем каталоги
pos1:=0;

repeat
dir:='.';
i:=0;
// XFLE = 88 70 76 69
if ( (buf[pos1 + 0] = 88) and (buf[pos1+1]=70) and (buf[pos1+2]=76) and (buf[pos1+3]=69) ) then
 begin
  // посчитали размер файла
  fsize := getDWORD(pos1 + fsize_offset, buf);

  while (buf[pos1 + path_start + i] <> 0) do
  begin
   dir:=dir + chr(buf[pos1 + path_start + i]);
   Inc(i);
  end;
  //form1.memo1.lines.add(ExtractFilePath(dir));
  ForceDirectories(ExtractFilePath(dir));

  Writeln (logout, dir);

  AssignFile(fout, dir);
  Rewrite (fout);
  BlockWrite(fout, buf[pos1+data_offset], fsize );
  CloseFile (fout);
  //form1.memo1.lines.add(ExtractFileName(dir));
 end;
 pos1:=pos1 + fsize + data_offset;
until (pos1>GlobalFileSize);

FreeMem(Buf); // освободить, закрыть и уйти.
CloseFile (logout);

form1.memo1.lines.add ('done');
end;

Procedure CreateBMP (x, y: integer; picfname, palfname : string;offset:LongInt);
var
  buf_pal, buf_raw   : PByteArray;
  Bitmap: TBitmap;
  i,j,k,tmp1 : Integer;
  f, f2 : file of Byte;
  bSize1, bSize2 : LongInt;
  NumColors: integer;

  pal: PLogPalette;
  hpal: HPALETTE;
  i5: Integer;
  r, g, b, shnum : Integer;
begin
assignfile (f, palfname);
assignfile (f2, picfname);

Reset (f);
Reset (f2);

bSize1 := FileSize(f2);
bSize2 := FileSize(f);

if ( (bSize1=0) or (x*y>bSize1) ) then
  begin
    CloseFile (f);
    CloseFile (f2);
    Exit;
  end;

GetMem(buf_raw, bSize1); // выделяем память буфферу
GetMem(buf_pal, bSize2);

Blockread(F, buf_pal[0], bsize2);
Blockread(F2, buf_raw[0], bsize1);  // читаем весь файл туда

Bitmap := TBitmap.Create;
Bitmap.PixelFormat := pf8bit;

Bitmap.Width := x;
Bitmap.Height := y;

// Блок добавки яркости
pal := nil;
GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);
pal.palVersion := $300;
pal.palNumEntries := 256;
//shnum:=Form1.se1.value;
for i := 0 to 255 do
  begin
   pal.palPalEntry[i].peRed := buf_pal[3*i + 0]; //shnum;
   pal.palPalEntry[i].peGreen := buf_pal[3*i + 1]; //shnum;
   pal.palPalEntry[i].peBlue := buf_pal[3*i + 2]; //shnum;
  end;
hpal := CreatePalette(pal^);
if hpal <> 0 then
    Bitmap.Palette := hpal;

k:=0;
k:=offset;
 for i:=0 to (y-1) do
  for j:=0 to (x-1) do
    begin
      tmp1:=buf_raw[k] * 3;
      r:=buf_pal[tmp1+0];//shnum;
      g:=buf_pal[tmp1+1];//shnum;
      b:=buf_pal[tmp1+2];//shnum;
      Bitmap.Canvas.Pixels[j, i] := RGB(r, g, b);
      Inc(k);
    end;
// конец блока добавки яркости
Bitmap.SaveToFile(picfname+'.bmp');
Bitmap.Free;
CloseFile (f);
CloseFile (f2);
FreeMem(buf_pal); // освободить, закрыть и уйти.
FreeMem(buf_raw);
FreeMem(pal);
end;


procedure TForm1.datUnpackClick(Sender: TObject);
var
 //const room_bmp:array [0..18] of AnsiString=(
 searchResult : TSearchRec;
 fname1:string;
 x, y:Integer;
fin:file of Byte;
buf:PByteArray;
path:string;
begin
//UnpackDat('.\rus\cd12\harvest.dat');
UnpackDat('.\cd3\harvest.dat');
//UnpackDat('sound.dat');
{
 if FindFirst('.\GRAPHIC\ROOMS\*.BM', faAnyFile, searchResult) = 0 then
   begin
     repeat
       fname1:=copy(ExtractFileName(searchResult.Name),0,pos('.',searchResult.Name)-1);
       //ShowMessage('Имя файла = '+fname1);
       CreateBMP(640, 480, '.\GRAPHIC\ROOMS\'+fname1+'.BM', '.\GRAPHIC\PAL\'+fname1+'.PAL', 12);
     until FindNext(searchResult) <> 0;

    // Должен освободить ресурсы, используемые этими успешными, поисками
     FindClose(searchResult);
   end;
}

{
 //path:='.\GRAPHIC\ROOMOBJ\';
 path:='.\GRAPHIC\MASKS\';
 if FindFirst(path + '*.BM', faAnyFile, searchResult) = 0 then
   begin
     repeat
       fname1:=copy(ExtractFileName(searchResult.Name),0,pos('.',searchResult.Name)-1);

        FileMode := fmShareDenyNone; // права доступа отключить ругань
        AssignFile(fin, Path + searchResult.name);
        Reset(fin);
        GetMem(buf, FileSize(fin)); // выделяем память буфферу
        Blockread(fin, buf[0], FileSize(fin));  // читаем весь файл туда

       x:=getDWORD(0, buf);
       y:=getDWORD(4, buf);

       CreateBMP(x, y, path + fname1 + '.BM', '.\GRAPHIC\PAL\CD1.PAL', 12);

       CloseFile (fin);
       FreeMem(buf); // освободить, закрыть и уйти.

     until FindNext(searchResult) <> 0;

    // Должен освободить ресурсы, используемые этими успешными, поисками
     FindClose(searchResult);
   end;
    }


Form1.Memo1.Lines.Add('done');
end;

// этот блок целиком написан в Крыму 2013, под море, теплое солнце и
// 
procedure TForm1.bmpFontImportClick(Sender: TObject);
var
bmpFont   : PByteArray;
GlobalFileSize, i, j, symIndx, k:longint;
fin:file of Byte;
bmpH, bmpW, bmpData, col1, col2, lastPos, symoffsetinbmp, sym, cp1251pos : Integer;
// массив ширин шрифта из bmp
bmpFont_width : array [0..65] of Integer;
fname : string;
const
  bmpHoffset=$16; // смещение в BMP от нуля, высота BMP
  bmpWoffset=$12; // смещение в BMP от нуля, ширина BMP
  bmpDataOffset=$0A; // указатель начала raw данных в bmp
begin
{
font_start[symnum] - таблица смещений до начала буквы, в линейном виде
font_width[symnum] - таблица ширин
font_array[i,j] - текущий символ 2х мерная таблица, высота font_h, ширина abcLen, при сохранении разворачивается в buf
}
 fname:='.\finalfonts\flip' + IntToStr(FontChoose.Position + 1) +'.bmp';

 FileMode := fmShareDenyNone; // права доступа отключить ругань
 AssignFile(fin, fname);
 Reset(fin);
 GlobalFileSize := FileSize(fin);
 GetMem(bmpFont, GlobalFileSize); // выделяем память буфферу
 Blockread(fin, bmpFont[0], GlobalFileSize);  // читаем весь файл туда

 bmpH:=getDWORD(bmpHoffset, bmpFont);
 bmpW:=getDWORD(bmpWoffset, bmpFont);
 bmpData:=getDWORD(bmpDataOffset, bmpFont); // =0436h = 1078 начало raw даных

 //Form1.Memo1.Lines.Add(IntToStr(bmpH)+' '+inttostr(bmpW));
 if (bmpH > font_h) then
  begin
   Form1.Memo1.Lines.Add('Несовпадение высот BMP и CFT');
   Exit;
  end;
 // заполняем массив ширин из BMP файла
 symIndx:=0; // индекс символа, в BMP идет А-Яа-я
 lastPos:=0;

 // ищем границы букв и заполняю таблицу ширин символов из BMP
 for j:=0 to (bmpW - 2) do
   begin
    col1:=bmpFont[bmpData + 0*bmpW + j]; // первого ряда мне оказалось достаточно
    col2:=bmpFont[bmpData + 0*bmpW + j + 1];
    // зеленый фон = 170 , $AA
    // синий фон символа = 83 , $53
    if (  ((col1=$AA) and (col2=$53)) or ((col1=$53) and (col2=$AA)) ) then
     begin
      bmpFont_width[symIndx]:=j - lastPos + 1; // записываем ширину
      lastPos:=j + 1;                          // смещаем последний указатель
      inc (symIndx);
     end;
   end;
 // заполняю ширину последней буквы я маленькой
 bmpFont_width[65]:=bmpW - lastPos;

 // еще надо проконтролировать большой шрифт, там маленьких букв нет
 if form1.FontChoose.Position>=4 then bmpFont_width[32]:=bmpW - lastPos;
 // закончили заполнять ширину шрифтов из BMP

 // сравниваем ширины текущего символа и из BMP
 // затем высчитываем смещение в raw bmp тек символа и заполняем массив новой буквой
 // диапазоны font_width[form1.fontnum.Position] 32-255 и bmpFont_width[65] 0-65
 //Form1.Memo1.Lines.Add(IntToStr(font_width[form1.fontnum.Position]));  // ширина, 7 для Ё
 //Form1.Memo1.Lines.Add(IntToStr(form1.fontnum.Position+1));            // позиция в вин, 167+1
 //Form1.Memo1.Lines.Add(IntToStr(bmpFont_width[7-1]));
 // form1.fontnum.Position + 1 = 168 - это Ё, 7 буква в алфавите BMP
 // form1.fontnum.Position+1 = 184 - это ё, 33+7 в алфавите BMP
 // 192 - А (1 буква)
 // 223 - Я (33 буква)
 // 224 - а (33 + 1 буква)
 // 255 - я (33 + 33 буква)

 //
 sym:=0;
 cp1251pos:=form1.fontnum.Position + 1;

 if (cp1251pos = 168 ) then sym:=7; // 7 буква Ё
 if (cp1251pos = 184 ) then sym:=33 + 7; // 33 + 7 буква ё
 if ( (cp1251pos>=192) and (cp1251pos<=197) ) then sym:=cp1251pos - 191;
 if ( (cp1251pos>=198) and (cp1251pos<=223) ) then sym:=cp1251pos + 1 - 191;

 if ( (cp1251pos>=224) and (cp1251pos<=229) ) then sym:=cp1251pos - 190;
 if ( (cp1251pos>=230) and (cp1251pos<=255) ) then sym:=cp1251pos + 1 - 190;

 if sym=0 then Exit; // не выбрана русская буква

// проверка ширин и корректировка
  while ( (font_width[form1.fontnum.Position] <> bmpFont_width[sym - 1]) ) do
   begin
    Form1.seSymWidth.Value:=bmpFont_width[sym - 1];
    SaveFontClick(Sender);
   end;

  if ( (font_width[form1.fontnum.Position] = bmpFont_width[sym - 1]) ) then
   begin
    Form1.Memo1.Lines.Add('Ширина из CFT и BMP файла совпадают.');

    symoffsetinbmp:=0; // ищем смещение начала изображения
    for i:=0 to (sym-2) do // -1 потому что с нуля, еще -1 потому что ДО буквы, а не после
     inc (symoffsetinbmp, bmpfont_width[i]); // нашли смещение-начало буквы, сумма ширин букв идущих до

   k := 1;
   if form1.FontChoose.Position>=2 then k:=1; //почему то у 2х таблиц смещена ширина
   if form1.FontChoose.Position>=4 then k:=4;

   // заполняем букву из бмп в font_array
   for i:=0 to (bmpH - 1) do  // координата Y ноль сверху слева
    for j:=0 to (bmpFont_width[sym-1] -1 ) do // координата X
     begin         //начало изображения + смещение до буквы + ряд Y + текущий X
       col1:=bmpFont[bmpData + symoffsetinbmp + i*(bmpW + k) + j ];

       if ( (col1=$53) or (col1=$AA) ) then col1:=0;  // пропускаем зеленый и синий фон из бмп
       font_array[i, j + font_start[form1.fontnum.Position]]:=col1;
     end;
   // сохраняем
   SaveFontClick(sender);
   // обновляем картинку
   ShowSymbol;
   end;

 CloseFile (fin);
 FreeMem(bmpFont); // освободить, закрыть и уйти.
end;

procedure TForm1.btn1Click(Sender: TObject);
var i, j, k : Integer;
begin
//font_width: array [0..255] of Integer; // ширины символов
//font_start: array [0..255] of longint;// таблица смещений начала символа
//font_array: array [0..500, 0..10000] of Byte; // прямоугольник шрифта
// опускаем вниз каждую букву, прямоугольник, ширина font_width

// высота шрифта, ширина шрифта, стартовый адрес
// font_h := buf[dataStart - 8] - 1;
// font_w := font_width[curpos];
// start := font_start[curpos];

for k := 32 to 165 do
 for i := (font_h - 1) downto 0 do
  for j := font_start[k] to (font_start[k] + font_width[k] - 1) do
   begin
    if i<>0 then
     font_array[i, j] := font_array[i-1, j]
            else
     font_array[i, j] := 0;

   end;
ShowSymbol;
end;



procedure Dat_Rusify (fname:string; cd:Integer);
var
Datsbuf, bmpin : PByteArray;
DatFileSize, bmpFileSize, pos1, bmpPos, BMPw, BMPh, totalpics, fsize, i, j, k, delta:longint;
fin, fout:file of Byte;
fname2, Path : string;
logout, pics2replace : TextFile;
files : array of string;
  f : TFileStream;
  s : AnsiString;

const
XFLE_DATA_OFFSET = $A0;
XFLE_BMPw_OFFSET = $94;
XFLE_BMPh_OFFSET = $98;

begin
FileMode := fmShareDenyNone; // права доступа отключить ругань

f := TFileStream.Create(fname, fmOpenRead);
f.position := 0;
setlength(s, f.size);
f.readBuffer(s[1], f.size);
f.free;

// читаем весь DAT файл в память
AssignFile(fin, fname);
Reset(fin);
DatFileSize := FileSize(fin);
GetMem(Datsbuf, DatFileSize); // выделяем память буферу
Blockread(fin, Datsbuf[0], DatFileSize);  // читаем весь файл harvest.dat туда
CloseFile (fin);
// прочитали весь DAT файл в память

// Теперь заполняем список файлов.BM для замены
AssignFile (pics2replace, '.\rus\rooms\pics2replace.txt');
Reset (pics2replace);

totalpics:=0;
while (not(Eof(pics2replace))) do
 begin
  SetLength (files, totalpics + 1);
  readln (pics2replace, files[totalpics]);
  inc (totalpics);
 end;
CloseFile (pics2replace);

// Заполнили список имен файлов
for i:= 0 to (totalpics - 1) do // все имена
 begin
  fname2 := Files[i];
  if fname2 = '\ROOMOBJ\BRNTFLYR.RAW' then fname2 := '\ROOMOBJ\BRNTFLYR.BM';
  if fname2 = '\INVENTRY\BRNTFLYRsmall.RAW' then fname2 := '\INVENTRY\BRNTFLYR.BM';
  if fname2 = '\ROOMOBJ\BUTTON.RAW' then fname2 := '\ROOMOBJ\BUTTON.BM';
  if fname2 = 'MAILBOX.RAW' then fname2 := 'MAILBOX.BM';
  if fname2 = 'TIPS.RAW' then fname2 := 'TIPS.BM';
  if fname2 = 'GAMEOVER_OTHER.BM' then fname2 := '\OTHER\GAMEOVER.BM';
  if fname2 = 'GAMEOVER_ROOMS.BM' then fname2 := '\ROOMS\GAMEOVER.BM';

  pos1 := posex (fname2, s, 0);

  if pos1 <> 0 then
   begin
    Path := '.\rus\rooms\bm\' + fname2 + '.bmp';
    if fname2 = '\ROOMOBJ\BRNTFLYR.BM' then Path := '.\rus\rooms\bm\BRNTFLYR.RAW';
    if fname2 = '\INVENTRY\BRNTFLYR.BM' then Path := '.\rus\rooms\bm\BRNTFLYRsmall.RAW';
    if fname2 = '\ROOMOBJ\BUTTON.BM' then Path := '.\rus\rooms\bm\BUTTON.RAW';
    if fname2 = 'MAILBOX.BM' then Path := '.\rus\rooms\bm\MAILBOX.RAW';
    if fname2 = 'TIPS.BM' then Path := '.\rus\rooms\bm\TIPS.RAW';
    if fname2 = '\OTHER\GAMEOVER.BM' then Path := '.\rus\rooms\bm\GAMEOVER_OTHER.BM.BMP';
    if fname2 = '\ROOMS\GAMEOVER.BM' then Path := '.\rus\rooms\bm\GAMEOVER_ROOMS.BM.BMP';
    if fname2 = '\ROOMS\INVITE.BM' then path := '.\rus\rooms\bm\INVITE.BM.BMP';
    if fname2 = '\ROOMS\CLUE.BM' then path := '.\rus\rooms\bm\CLUE.BM.BMP';

    AssignFile(fin, Path);
    Reset(fin);

    bmpFileSize := FileSize(fin);
    GetMem(bmpin, bmpFileSize); // выделяем память буферу
    Blockread(fin, bmpin[0], bmpFileSize);  // читаем весь файл harvest.dat туда
    CloseFile (fin);

    // Отодвигаем указатель назад до двоеточия (':' = $3A) после XFLE
    while (datsbuf[pos1] <> $3A) do
     Dec (pos1);

    // Делаем еще -5 = XFLE
    Dec (pos1, 5);

    BMPw := getDWORD(pos1 + XFLE_BMPw_OFFSET, Datsbuf);
    BMPh := getDWORD(pos1 + XFLE_BMPh_OFFSET, Datsbuf);

    // передвигаем указатель на начало данных
    //inc (pos1, $A0);

    // берем указатель данных BMP
    bmpPos := getDWORD($0A, bmpin);
    if fname2 = '\ROOMOBJ\BRNTFLYR.BM' then bmpPos := 0;
    if fname2 = '\INVENTRY\BRNTFLYR.BM' then bmpPos := 0;
    if fname2 = '\ROOMOBJ\BUTTON.BM' then bmpPos := 0;
    if fname2 = 'MAILBOX.BM' then bmpPos := 0;
    if fname2 = 'TIPS.BM' then bmpPos := 0;

    Move (bmpin[bmpPos], Datsbuf[pos1 + XFLE_DATA_OFFSET], BMPw * BMPh);
    Form1.memo1.lines.add (fname2);
   end;

   if (pos1 = 0) then Form1.memo1.lines.add (fname2 + ' is in another castle.');
   if (pos1 <> 0) then FreeMem (bmpin);
 end;

 if cd=1 then Path := '.\rus\cd12\out\harvest.dat';
 if cd=3 then Path := '.\rus\cd3\out\harvest.dat';

 AssignFile(fout, path);
 Rewrite (fout);
 BlockWrite (fout, Datsbuf[0], DatFileSize);
 CloseFile (fout);
end;


procedure TForm1.btn3Click(Sender: TObject);
begin
//cd1-2 = 1
Dat_rusify ('.\rus\cd12\HARVEST.DAT', 1);

//cd3 = 3
//Dat_rusify ('.\rus\cd3\HARVEST.DAT', 3);
end;

procedure encodeABM (path, filename, ext:string);
var
abmBuf, RLEbuf, BMPbuf : PByteArray;
NUM, NUMidx, abmFileSize, bmpFileSize, bmpDataStart, pos1, bmpPos, BMPw, BMPh, totalpics, fsize, idx, RLEidx, j, k, cnt, framesTOTAL, frameNUM, maxRAWsize, i:longint;
RLEidxstart, NUMmax, number, offset, maxBuf : LongInt;
fin, fout:file of Byte;
fname2, FULLpath : string;
log, pics2replace : TextFile;
files : array of string;
  f : TFileStream;
  s : AnsiString;
  eigthZero : boolean;
 cByte : Byte;
begin
 // Читаем оригинальный файл .ABM с анимацией
 // в буфер abmBuf[]
 AssignFile(fin, path + '\IN_ABM\' + filename + '.ABM');
 Reset(fin);
 abmFileSize := FileSize(fin);
 GetMem(abmBuf, abmFileSize); // выделяем память буферу
 Blockread(fin, abmBuf[0], abmFileSize);  // читаем весь файл туда
 CloseFile (fin);
 //--------------------------------------------

 // Сохраняем количество кадров во framesTOTAL
 framesTOTAL := getDWORD(0, abmBuf);
 GetMem(RLEbuf, abmFileSize*20);

 // первое начало кодированного кадра со смещения 8
 idx := 8;
 RLEidx:=8;

 {
 if filename = 'POINTERS' then
  begin
   idx := 19313;
   RLEidx := 8;
  end;
 }
 
 writeDWORD(framesTOTAL, 0, RLEbuf);

 maxBuf := 0;
 for i := 1 to framesTOTAL do
 begin
  //Readln (log, RLEidx);
  frameNUM := i;

  // Читаем очередной BMP/RAW кадр
  FULLpath := path + '\' + filename +'\' + filename + '_' + IntToStr(frameNUM) + EXT;
  AssignFile (fin, FULLpath);
  Reset(fin);
  bmpFileSize := FileSize(fin);
  GetMem(BMPbuf, bmpFileSize); // выделяем память буферу
  Blockread(fin, BMPbuf[0], bmpFileSize);  // читаем весь файл туда
  CloseFile (fin);

  // берем из BMP файла размеры X, Y
  BMPw := getDWORD ($12, BMPbuf);
  BMPh := getDWORD ($16, BMPbuf);

  if filename = 'EDNASIGN' then begin BMPw := 141; BMPh := 121; end;
  if filename = 'GAMEPINB' then begin BMPw := 79; BMPh := 79; end;
  if filename = 'COPIER'   then begin BMPw := 63; BMPh := 19; end;

  if filename = 'POINTERS' then
   begin
    if frameNUM = 1  then begin BMPw := 16; BMPh := 25; end;
    if frameNUM = 2  then begin BMPw := 17; BMPh := 26; end;
    if frameNUM = 3  then begin BMPw := 19; BMPh := 25; end;
    if frameNUM = 4  then begin BMPw := 19; BMPh := 25; end;
    if frameNUM = 5  then begin BMPw := 16; BMPh := 25; end;
    if frameNUM = 6  then begin BMPw := 16; BMPh := 25; end;
    if frameNUM = 7  then begin BMPw := 18; BMPh := 25; end;
    if frameNUM = 8  then begin BMPw := 19; BMPh := 25; end;
    if frameNUM = 9  then begin BMPw := 18; BMPh := 25; end;
    if frameNUM = 10 then begin BMPw := 17; BMPh := 25; end;

    if ((frameNUM >= 11) and (frameNUM <= 20)) then begin BMPw := 22; BMPh := 23; end;

    if frameNUM = 21 then begin BMPw := 23; BMPh := 16; end;
    if frameNUM = 22 then begin BMPw := 23; BMPh := 16; end;
    if ((frameNUM >= 23) and (frameNUM <= 29)) then begin BMPw := 23; BMPh := 17; end;
    if frameNUM = 30 then begin BMPw := 23; BMPh := 16; end;

    if frameNUM = 31 then begin BMPw := 24; BMPh := 24; end;
    if frameNUM = 32 then begin BMPw := 24; BMPh := 24; end;
    if frameNUM = 33 then begin BMPw := 24; BMPh := 24; end;
    if frameNUM = 34 then begin BMPw := 23; BMPh := 23; end;
    if frameNUM = 35 then begin BMPw := 22; BMPh := 22; end;
    if frameNUM = 36 then begin BMPw := 22; BMPh := 21; end;
    if frameNUM = 37 then begin BMPw := 22; BMPh := 22; end;
    if frameNUM = 38 then begin BMPw := 23; BMPh := 23; end;
    if frameNUM = 39 then begin BMPw := 24; BMPh := 24; end;
    if frameNUM = 40 then begin BMPw := 24; BMPh := 24; end;

    if ((frameNUM >= 41) and (frameNUM <= 50)) then begin BMPw := 25; BMPh := 25; end;

    if frameNUM = 51 then begin BMPw := 19; BMPh := 19; end;
    if frameNUM = 52 then begin BMPw := 19; BMPh := 20; end;
    if frameNUM = 53 then begin BMPw := 19; BMPh := 20; end;
    if frameNUM = 54 then begin BMPw := 19; BMPh := 21; end;
    if frameNUM = 55 then begin BMPw := 19; BMPh := 21; end;
    if frameNUM = 56 then begin BMPw := 19; BMPh := 21; end;
    if frameNUM = 57 then begin BMPw := 19; BMPh := 20; end;
    if frameNUM = 58 then begin BMPw := 19; BMPh := 20; end;
    if frameNUM = 59 then begin BMPw := 19; BMPh := 20; end;
    if frameNUM = 60 then begin BMPw := 20; BMPh := 19; end;

    if ((frameNUM >= 61) and (frameNUM <= 70)) then begin BMPw := 26; BMPh := 26; end;

    if frameNUM = 71 then begin BMPw := 23; BMPh := 23; end;
    if frameNUM = 72 then begin BMPw := 22; BMPh := 23; end;
    if frameNUM = 73 then begin BMPw := 17; BMPh := 23; end;
    if frameNUM = 74 then begin BMPw := 17; BMPh := 23; end;
    if frameNUM = 75 then begin BMPw := 22; BMPh := 23; end;
    if frameNUM = 76 then begin BMPw := 23; BMPh := 23; end;
    if frameNUM = 77 then begin BMPw := 22; BMPh := 23; end;
    if frameNUM = 78 then begin BMPw := 17; BMPh := 23; end;
    if frameNUM = 79 then begin BMPw := 17; BMPh := 23; end;
    if frameNUM = 80 then begin BMPw := 22; BMPh := 23; end;
   end;

  {
  FULLpath := path + '\' + filename + '\' + filename + '_' + IntToStr(frameNUM) + EXT;
  AssignFile (fin, FULLpath);
  Reset(fin);
  bmpFileSize := FileSize(fin);
  GetMem(BMPbuf, bmpFileSize); // выделяем память буферу
  Blockread(fin, BMPbuf[0], bmpFileSize);  // читаем весь файл туда
  CloseFile (fin);
  }

  // максимальный буфер среди всех кадров
  maxRAWsize := BMPw * BMPh;
  if maxRAWsize > maxBuf then maxBuf := maxRAWsize;
  writeDWORD (maxBuf, 4, RLEbuf);

  // начинается ABM файла со смещений кадра
  // 2 смещения по X Y , каждое по 4 байта, пишем нули
  writeDWORD (0, RLEidx + 0, RLEbuf);
  writeDWORD (0, RLEidx + 4, RLEbuf);

  // пишем разрешение кадра, сперва X, затем Y
  writeDWORD (BMPw, RLEidx + 8, RLEbuf);
  writeDWORD (BMPh, RLEidx + 12, RLEbuf);

  // packed byte = 1 сжато, 0 = не сжато.
  RLEbuf [RLEidx + 16] := 1;

  // размер данных, сжатых или нет
  writeDWORD (maxRAWsize, RLEidx + 17, RLEbuf);

  if filename = 'POINTERS' then number := 18692; // для pointers.abm
  if filename = 'WAIT' then number := 49208; // wait.abm
  if filename = 'EDNASIGN' then number := 28728;
  if filename = 'GAMEPINB' then number := 16440;
  if filename = 'COPIER' then number := 16440;
  offset := RLEidx + 21;
  writeWORD (number, offset, RLEbuf);

  if filename = 'POINTERS' then number := 104; // для pointers.abm
  if filename = 'WAIT' then number := 87; // wait.abm
  if filename = 'EDNASIGN' then number := 49;
  if filename = 'GAMEPINB' then number := 39;
  if filename = 'COPIER' then number := 39;
  offset := RLEidx + 23;
  writeWORD (number, offset, RLEbuf);

  // пропускаем заголовок 25 байт
  inc (RLEidx, 25);
  //inc (idx, 25);

  // запоминаем позицию начала кодированных байт
  RLEidxstart := RLEidx;

  // Вот тут начинаем сжимать BMP и писать в RLE буфер
  if ext = '.RAW' then bmpDataStart := 0;
  if ext = '.BMP' then bmpDataStart := getDWORD($0A, BMPbuf);

//  Move (BMPbuf[bmpDataStart], RLEbuf[RLEidx], maxRAWsize);
//  inc (RLEidx, maxRAWsize);

  //Move(BMPbuf[0], RLEbuf[RLEidxstart], bmpFileSize);
  //inc (RLEidx, bmpFileSize);

  // жмем BMP
  NUMmax := 0;
 // if filename<>'POINTERS' then

 while ((bmpDataStart + 1) <= bmpFileSize) do
   begin
    cByte := BMPbuf[bmpDataStart];
    NUM := 1;
    // пакуем одинаковые байты
    while ( ((bmpDataStart + 1) <= bmpFileSize) and (BMPbuf[bmpDataStart + 1] = cByte) ) do
     begin
      inc (NUM); // увеличиваем счетчик одинаковых байт
      inc (bmpDataStart); // и переходим к следующему байту BMP
      if NUM >= 127 then
      begin
       if NUM > NUMmax then NUMmax := NUM;
       Break; // в данной версии RLE их не может быть >127
       end;
     end;

   // есть повторы >=2
    if NUM >= 2 then
     begin
      RLEbuf[RLEidx + 0] := NUM + $80; // пишем количество повторов
      RLEbuf[RLEidx + 1] := cByte;     // и сам байт
      inc (RLEidx, 2); // смещаем указатель сжатых данных на следующий
      inc (bmpDataStart); // переходим к следующему байту
      if NUM > NUMmax then NUMmax := NUM;
      Continue;
     end;

    // нет повторов, след байт не равен предыдущему
    NUMidx := RLEidx;
    NUM := 1;

    while ( ((bmpDataStart + 1) <= bmpFileSize) and (BMPbuf[bmpDataStart + 1] <> BMPbuf[bmpDataStart])) do
     begin
      RLEbuf[NUMidx] := NUM;
      RLEbuf[RLEidx + 1] := BMPbuf[bmpDataStart];

      Inc (NUM);
      inc (bmpDataStart);
      inc (RLEidx);
      if NUM >= 127 then
       begin
        if NUM > NUMmax then NUMmax := NUM;
        Break;
       end;
     end;

    if NUM >= 2 then
     begin
      inc (RLEidx);
      if NUM > NUMmax then NUMmax := NUM;
     end;
   end;


  // пишем в заголовок размер кодированных данных
  writeDWORD (RLEidx - RLEidxstart, RLEidxstart - 8, RLEbuf);

  // фикс для WAIT. перезаполняю таблицу кадра
  if filename='WAIT' then
   begin
    RLEbuf[RLEidxstart - 9] := 1;
    writeWORD(49208, RLEidxstart - 4, RLEbuf);
    writeWORD(87, RLEidxstart - 2, RLEbuf);
   end;

  // заполняю таблицу
  if filename='POINTERS' then
   begin
    RLEbuf[RLEidxstart - 9] := 1;
    writeWORD(18692, RLEidxstart - 4, RLEbuf);
    writeWORD(104, RLEidxstart - 2, RLEbuf);
   end;

  FreeMem (BMPbuf);
 end;

 //AssignFile (fout, '.\rus\ANIMATION\OUT_ABM\' + filename + '.ABM');
 AssignFile (fout, '.\Files\ABM\' + filename + '.ABM');
 Rewrite (fout);
 BlockWrite (fout, RLEbuf[0], RLEidx);
 CloseFile (fout);

 FreeMem (abmBuf);
 FreeMem (RLEbuf);

 Form1.Memo1.Lines.add ('done');
end;

procedure decodeABM (fname:string);
var
abmBuf, deRLEbuf : PByteArray;
abmFileSize, pos1, bmpPos, BMPw, BMPh, totalpics, fsize, idx, deRLEidx, j, k, cnt, framesTOTAL, frameNUM, RAWsize:longint;
pkdByte, PackedSize, unk3, unk4, offX, offY, RLEdatasize, i2 : LongInt;
fin, fout:file of Byte;
fname2, Path : string;
logout, pics2replace : TextFile;
files : array of string;
  f : TFileStream;
  s : AnsiString;
  eigthZero : boolean;
begin
 AssignFile(fin, fname);
 Reset(fin);
 abmFileSize := FileSize(fin);
 GetMem(abmBuf, abmFileSize); // выделяем память буферу
 Blockread(fin, abmBuf[0], abmFileSize);  // читаем весь файл туда
 CloseFile (fin);

 // лог смещений до кадра
 AssignFile (logout, 'anim_offsets.txt');
 Rewrite (logout);

 framesTOTAL := getDWORD(0, abmBuf);
 RAWsize := getDWORD($4, abmBuf);

 idx := $8;

 for frameNUM := 1 to framesTOTAL do
 begin
  // читаем заголовок
  offX := getDWORD (idx + 0, abmBuf); // смещение кадра по x
  offY := getDWORD (idx + 4, abmBuf); // смещение кадра по y

  BMPw := getDWORD(idx + 8, abmBuf);
  BMPh := getDWORD(idx + 12, abmBuf);

  pkdByte := abmBuf[idx + 16];     // =1 изображение сжато, 0 - нет
  PackedSize := getDWORD(idx + 17, abmBuf); // RLE packed size RAW
  unk3 := getWORD(idx + 21, abmBuf);  // хуй знат что за числа
  unk4 := getWORD(idx + 23, abmBuf);  // хуй знат что за числа

  Write (logout, 'offset=' + inttostr(idx) + ', ');
  write (logout, 'x=' + inttostr(BMPw) + ', ');
  write (logout, 'y=' + inttostr(BMPh) + ', ');
  write (logout, 'x*y=' + inttostr (BMPw * BMPh) + ', ');
  write (logout, inttostr(offX) + ', ' + inttostr(offY) + ', ');
  write (logout, inttostr(pkdByte) + ', ' + inttostr(PackedSize) + ', ' + inttostr(unk3) + ', ' + inttostr(unk4));
  Writeln (logout, '');

  if ((BMPw = 0) or (BMPh = 0) or (BMPw = 1) or (BMPh = 1)) then
   begin
     Form1.Memo1.Lines.Add('bmp x,y=0; error');
     Continue;
   end;

  GetMem (deRLEbuf, BMPw*BMPh*20);
  deRLEidx := 0;

  // двигаем указатель на данные
  inc (idx, 25);

  while ( deRLEidx < (BMPw * BMPh) ) do
   begin
    // уникальные байты
    if abmBuf[idx] < $80 then
     begin
      cnt := abmBuf[idx];
      inc (idx); // пропускаем счетчик байт

      for j := 1 to (cnt) do
       begin
       deRLEbuf[deRLEidx] := abmBuf[idx];
       inc (deRLEidx);
       Inc (idx);
       end;
     end;
    // количество повторов
    if abmBuf[idx] > $80 then
     begin
      cnt := abmBuf[idx] - $80;
      for j := 1 to cnt do
       begin
       deRLEbuf[deRLEidx] := abmBuf[idx + 1];
       inc (deRLEidx);
       end;
      inc (idx, 2);
     end;
   end;

   AssignFile (fout, fname + inttostr(frameNUM) + '.raw');
   Rewrite (fout);
   BlockWrite (fout, deRLEbuf[0], BMPw*BMPh);
   CloseFile (fout);

   CreateBMP(BMPw, BMPh, fname + inttostr(frameNUM) + '.raw', '.\GRAPHIC\PAL\GENINSD.PAL', 0);
   //DeleteFile(fname + inttostr(frameNUM) + '.raw');

   FreeMem (deRLEbuf);
  end;

  CloseFile (logout);
  FreeMem (abmBuf);

  Form1.Memo1.Lines.add ('done');
end;

procedure TForm1.btn4Click(Sender: TObject);
var
  path : string;
   searchResult : TSearchRec;
 fname1:string;
 x, y:Integer;
fin:file of Byte;
buf:PByteArray;
begin
decodeABM('.\FILES\ABM\COPIER.ABM');
 {
 path:='.\files\abm\';
 if FindFirst(path + '*.ABM', faAnyFile, searchResult) = 0 then
   begin
     repeat
       fname1:=copy(ExtractFileName(searchResult.Name),0,pos('.',searchResult.Name)-1);
       decodeABM(path + fname1 + '.abm');
     until FindNext(searchResult) <> 0;

    // Должен освободить ресурсы, используемые этими успешными, поисками
     FindClose(searchResult);
   end;
  }
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
//encodeABM('.\rus\ANIMATION', 'EDNASIGN', '.RAW');
//encodeABM('.\rus\ANIMATION', 'applause', '.BMP');
//encodeABM('.\rus\ANIMATION', 'HOTLSIGN', '.BMP');
//encodeABM('.\rus\ANIMATION', 'GAMEPINB', '.RAW');
//encodeABM('.\rus\ANIMATION', 'WAIT', '.BMP');
encodeABM('.\rus\ANIMATION', 'COPIER', '.RAW');
end;

end.
