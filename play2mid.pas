
unit Play2Mid;

(* https://www.freebasic.net/forum/viewtopic.php?p=248014#p248014 *)

interface

uses
  SysUtils;

type
  TPlay2Mid = class
  private
    FFileName: string;
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;
    procedure Play(const playstr: string; const playstr1: string = '');
  private
    function _fbplay_internal_translateNote(toTranslate: string): byte;
    function _fbplay_internal(channel: byte; playstr: string): string;
  end;

implementation

constructor TPlay2Mid.Create(const AFileName: string);
begin
  inherited Create;
  FFileName := AFileName;
end;

destructor TPlay2Mid.Destroy;
begin
  SetLength(FFileName, 0);
  inherited;
end;

function WriteVarLen(Value: integer): string;
begin
  result := Chr(Value and 127);
  while Value > 127 do
  begin
    Value := Value shr 7;
    result := Chr((Value and 127) or 128) + result;
  end;
end;

function WriteFourBytes(Value: integer): string;
begin
  result := Chr(Value and 255);
  Value := Value shr 8;
  result := Chr(Value and 255) + result;
  Value := Value shr 8;
  result := Chr(Value and 255) + result;
  Value := Value shr 8;
  result := Chr(Value and 255) + result;
end;

function TPlay2Mid._fbplay_internal_translateNote(toTranslate: string): byte;
begin
  if      toTranslate = 'c'  then result := 0
  else if toTranslate = 'cs' then result := 1
  else if toTranslate = 'db' then result := 1
  else if toTranslate = 'd'  then result := 2
  else if toTranslate = 'ds' then result := 3
  else if toTranslate = 'eb' then result := 3
  else if toTranslate = 'e'  then result := 4
  else if toTranslate = 'fb' then result := 4
  else if toTranslate = 'f'  then result := 5
  else if toTranslate = 'es' then result := 5
  else if toTranslate = 'fs' then result := 6
  else if toTranslate = 'gb' then result := 6
  else if toTranslate = 'g'  then result := 7
  else if toTranslate = 'gs' then result := 8
  else if toTranslate = 'ab' then result := 8
  else if toTranslate = 'a'  then result := 9
  else if toTranslate = 'as' then result := 10
  else if toTranslate = 'bb' then result := 10
  else if toTranslate = 'b'  then result := 11
  else if toTranslate = 'cb' then result := 11;
end;

function TPlay2Mid._fbplay_internal(channel: byte; playstr: string): string;
var
  tempo: integer = 120;
  note_len: byte = 4;
  note_len_mod: double = 1;
  octave: byte = 4;
  volume: byte = 127;
  note_stack: array[0..128] of byte;
  chord: byte;
  next_event: double = 0;
  duration: double;
  idx: byte;
  number: string;
  ch: char;
  tch: char;
  toTranslate: string;
  p: integer = 1;
  i: integer;
begin
  result := '';
  Initialize(note_stack);
  while p < Length(playstr) do
  begin
    ch := LowerCase(playstr[p]);
    Inc(p);
    if ch = 'n' then
    begin
      number := '';
      tch := playstr[p];
      while (Ord(tch) >= 48) and (Ord(tch) <= 57) do
      begin
        number := number + tch;
        Inc(p);
        if p <= Length(playstr) then
          tch := playstr[p]
        else
          tch := #0;
      end;
      idx := StrToInt(number);
      if idx = 0 then
        next_event := next_event + 60 / tempo * (4 / note_len) / 60
      else
      begin
        duration := 60 / tempo * (4 / note_len);
        result := result + WriteVarLen({Trunc}Round(240 * next_event)) + Chr($90 + channel) + Chr(idx) + Chr(volume);
        next_event := duration * (1 - note_len_mod);
        Inc(note_stack[0]);
        note_stack[note_stack[0]] := idx;
      end;
    end else
    if ch in ['a'..'g'] then
    begin
      duration := 60 / tempo * (4 / note_len);
      toTranslate := ch;
      number := '';
      ch := playstr[p];
      if ch = '-' then
      begin
        toTranslate := toTranslate + 'b';
        Inc(p);
      end else
        if (ch = '+') or (ch = '#') then
        begin
          toTranslate := toTranslate + 's';
          Inc(p);
        end;
      ch := playstr[p];
      while (Ord(ch) >= 48) and (Ord(ch) <= 57) do
      begin
        number := number + ch;
        Inc(p);
        if p <= Length(playstr) then
          ch := playstr[p]
        else
          ch := #0;
      end;
      if StrToIntDef(number, 0) <> 0 then
        duration := duration * 4 / StrToInt(number);
      if ch = '.' then
        duration := duration * 1.5;
      idx := 12 * octave + _fbplay_internal_translateNote(toTranslate);
      result := result + WriteVarLen({Trunc}Round(240 * next_event)) + Chr($90 + channel) + Chr(idx) + Chr(volume);
      next_event := duration * (1 - note_len_mod);
      Inc(note_stack[0]);
      note_stack[note_stack[0]] := idx;
    end else
    if ch = 'p' then
    begin
      number := '';
      ch := playstr[p];
      while (Ord(ch) >= 48) and (Ord(ch) <= 57) do
      begin
        number := number + ch;
        Inc(p);
        if p <= Length(playstr) then
          ch := playstr[p]
        else
          ch := #0;
      end;
      next_event := next_event + 60 / tempo * 4 / StrToInt(number);
    end else
    if ch = '>' then
    begin
      if octave < 7 then Inc(octave);
    end else
    if ch = '<' then
    begin
      if octave > 1 then Dec(octave);
    end else
    if ch = 'o' then
    begin
      number := '';
      ch := playstr[p];
      while (Ord(ch) >= 48) and (Ord(ch) <= 57) do
      begin
        number := number + ch;
        Inc(p);
        if p <= Length(playstr) then
          ch := playstr[p]
        else
          ch := #0;
      end;
      octave := StrToInt(number);
    end else
    if ch = 't' then
    begin
      number := '';
      ch := playstr[p];
      while (Ord(ch) >= 48) and (Ord(ch) <= 57) do
      begin
        number := number + ch;
        Inc(p);
        if p <= Length(playstr) then
          ch := playstr[p]
        else
          ch := #0;
      end;
      tempo := StrToInt(number);
    end else
    if ch = 'l' then
    begin
      number := '';
      ch := playstr[p];
      while (Ord(ch) >= 48) and (Ord(ch) <= 57) do
      begin
        number := number + ch;
        Inc(p);
        if p <= Length(playstr) then
          ch := playstr[p]
        else
          ch := #0;
      end;
      note_len := StrToIntDef(number, 1);
    end else
    if ch = 'm' then
    begin
      ch := LowerCase(playstr[p]);
      Inc(p);
      if ch = 's' then note_len_mod := 3 / 4;
      if ch = 'n' then note_len_mod := 7 / 8;
      if ch = 'l' then note_len_mod := 1;
    end else
    if ch = 'i' then
    begin
      number := '';
      ch := playstr[p];
      while (Ord(ch) >= 48) and (Ord(ch) <= 57) do
      begin
        number := number + ch;
        Inc(p);
        if p <= Length(playstr) then
          ch := playstr[p]
        else
          ch := #0;
      end;
      result := result + WriteVarLen(0) + Chr($C0 + channel) + Chr(StrToInt(number)); 
    end else
    if ch = 'v' then
    begin
      number := '';
      ch := playstr[p];
      while (Ord(ch) >= 48) and (Ord(ch) <= 57) do
      begin
        number := number + ch;
        Inc(p);
        if p <= Length(playstr) then
          ch := playstr[p]
        else
          ch := #0;
      end;
      volume := StrToInt(number);
    end else
    if ch = '{' then
    begin
      chord := 1;
    end else
    if ch = '}' then
    begin
      chord := 0;
    end;
    if chord > 0 then
      if chord = 2 then next_event := 0 else chord := 2
    else
    begin
      for i := 1 to note_stack[0] do
      begin
        result := result + WriteVarLen({Trunc}Round(240 * duration * note_len_mod)) + Chr($80 + channel) + Chr(note_stack[i]) + Chr(0);
        duration := 0;
      end;
      note_stack[0] := 0;
    end;
  end;
end;

procedure TPlay2Mid.Play(const playstr: string; const playstr1: string = '');
var
  Tracks: integer = 0;
  Midi, Track: string;
  F: longint;
begin
  Midi := '';
  
  Track := _fbplay_internal(0, playstr);
  if Length(Track) > 0 then
  begin
    Midi := Midi + 'MTrk' + WriteFourBytes(Length(Track) + 4) + Track + Chr(0) + Chr(255) + Chr(47) + Chr(0);
    Inc(Tracks);
  end;
  
  Track := _fbplay_internal(1, playstr1);
  if Length(Track) > 0 then
  begin
    Midi := Midi + 'MTrk' + WriteFourBytes(Length(Track) + 4) + Track + Chr(0) + Chr(255) + Chr(47) + Chr(0);
    Inc(Tracks);
  end;
  
  Midi := 'MThd' + Chr(0) + Chr(0) + Chr(0) + Chr(6) + Chr(0) + Chr(Ord(Tracks > 1)) + Chr(0) + Chr(Tracks) + Chr(0) + Chr(120) + Midi;
  
  F := FileCreate(FFileName);
  FileWrite(F, Midi[1], Length(Midi));
  FileClose(F);
end;

end.
