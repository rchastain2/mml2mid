
unit Play2Mid;

(* https://www.freebasic.net/forum/viewtopic.php?p=248014#p248014 *)

interface

uses
  SysUtils, Math;

type
  TPlay2Mid = class
  private
    FFileName: string;
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;
    procedure Play(const playstr: string; const playstr1: string = '');
    procedure PlayVoices(const AVoices: array of string);
  private
    function _fbplay_internal(channel: byte; playstr: string; tempomap: boolean): string;
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

const
  NoteOffsets: array['a'..'g'] of shortint = (9, 11, 0, 2, 4, 5, 7);
  TicksPerQuarter = 480;

function TPlay2Mid._fbplay_internal(channel: byte; playstr: string; tempomap: boolean): string;
var
  tempo: integer = 120;
  note_len: byte = 4;
  note_len_mod: double = 7 / 8;
  octave: byte = 4;
  volume: byte = 127;
  note_stack: array[0..128] of byte;
  chord: boolean = false;
  position: double = 0;
  duration: double = 0;
  last_tick: integer = 0;
  track: string = '';
  idx: byte;
  number: string;
  ch: char;
  offset: shortint;
  p: integer = 1;

  function NextChar: char;
  begin
    if p <= Length(playstr) then
      result := playstr[p]
    else
      result := #0;
  end;

  function ReadNumber: string;
  begin
    result := '';
    while NextChar in ['0'..'9'] do
    begin
      result := result + playstr[p];
      Inc(p);
    end;
  end;

  function ReadLength: double;
  var
    n: integer;
  begin
    n := StrToIntDef(ReadNumber, 0);
    if n = 0 then
      n := note_len;
    result := 4 / n;
  end;

  procedure Emit(const atime: double; const adata: string);
  var
    tick: integer;
  begin
    tick := Max(Round(atime * TicksPerQuarter), last_tick);
    track := track + WriteVarLen(tick - last_tick) + adata;
    last_tick := tick;
  end;

  procedure NoteOn(const akey: byte);
  begin
    Emit(position, Chr($90 + channel) + Chr(akey) + Chr(volume));
    Inc(note_stack[0]);
    note_stack[note_stack[0]] := akey;
  end;

  procedure ReleaseNotes;
  var
    i: integer;
  begin
    if note_stack[0] = 0 then
      Exit;
    for i := 1 to note_stack[0] do
      Emit(position + duration * note_len_mod, Chr($80 + channel) + Chr(note_stack[i]) + Chr(0));
    note_stack[0] := 0;
    position := position + duration;
  end;

begin
  FillChar(note_stack, SizeOf(note_stack), 0);
  while p <= Length(playstr) do
  begin
    ch := LowerCase(playstr[p]);
    Inc(p);
    if ch = 'n' then
    begin
      idx := EnsureRange(StrToIntDef(ReadNumber, 0), 0, 84);
      duration := 4 / note_len;
      if idx = 0 then
        position := position + duration
      else
        NoteOn(idx + 11);
    end else
    if ch in ['a'..'g'] then
    begin
      offset := NoteOffsets[ch];
      if NextChar = '-' then
      begin
        Dec(offset);
        Inc(p);
      end else
        if NextChar in ['+', '#'] then
        begin
          Inc(offset);
          Inc(p);
        end;
      duration := ReadLength;
      if NextChar = '.' then
        duration := duration * 1.5;
      NoteOn(EnsureRange(12 * (octave + 1) + offset, 0, 127));
    end else
    if ch = 'p' then
    begin
      duration := ReadLength;
      if NextChar = '.' then
        duration := duration * 1.5;
      position := position + duration;
    end else
    if ch = '>' then
    begin
      if octave < 6 then Inc(octave);
    end else
    if ch = '<' then
    begin
      if octave > 0 then Dec(octave);
    end else
    if ch = 'o' then
    begin
      octave := EnsureRange(StrToIntDef(ReadNumber, octave), 0, 6);
    end else
    if ch = 't' then
    begin
      tempo := EnsureRange(StrToIntDef(ReadNumber, tempo), 32, 255);
      if tempomap then
        Emit(position, Chr($FF) + Chr($51) + Chr(3) + Copy(WriteFourBytes(60000000 div tempo), 2, 3));
    end else
    if ch = 'l' then
    begin
      note_len := Max(StrToIntDef(ReadNumber, 1), 1);
    end else
    if ch = 'm' then
    begin
      ch := LowerCase(NextChar);
      Inc(p);
      if ch = 's' then note_len_mod := 3 / 4;
      if ch = 'n' then note_len_mod := 7 / 8;
      if ch = 'l' then note_len_mod := 1;
    end else
    if ch = 'i' then
    begin
      number := ReadNumber;
      if number <> '' then
        Emit(position, Chr($C0 + channel) + Chr(EnsureRange(StrToInt(number), 0, 127)));
    end else
    if ch = 'v' then
    begin
      volume := EnsureRange(StrToIntDef(ReadNumber, volume), 0, 127);
    end else
    if ch = '{' then
    begin
      chord := true;
    end else
    if ch = '}' then
    begin
      chord := false;
    end;
    if not chord then
      ReleaseNotes;
  end;
  result := track;
end;

procedure TPlay2Mid.Play(const playstr: string; const playstr1: string = '');
begin
  PlayVoices([playstr, playstr1]);
end;

procedure TPlay2Mid.PlayVoices(const AVoices: array of string);
var
  Tracks: integer = 0;
  Midi, Track: string;
  F: longint;
  i, channel: integer;
begin
  if Length(AVoices) > 15 then
    raise EArgumentException.Create('Too many voices (15 at most)');
  Midi := '';
  for i := 0 to High(AVoices) do
  begin
    channel := i;
    if channel >= 9 then
      Inc(channel);
    Track := _fbplay_internal(channel, AVoices[i], Tracks = 0);
    if Length(Track) > 0 then
    begin
      Midi := Midi + 'MTrk' + WriteFourBytes(Length(Track) + 4) + Track + Chr(0) + Chr(255) + Chr(47) + Chr(0);
      Inc(Tracks);
    end;
  end;

  Midi := 'MThd' + Chr(0) + Chr(0) + Chr(0) + Chr(6) + Chr(0) + Chr(Ord(Tracks > 1)) + Chr(0) + Chr(Tracks) + Chr(TicksPerQuarter shr 8) + Chr(TicksPerQuarter and 255) + Midi;

  F := FileCreate(FFileName);
  if F = -1 then
    raise EInOutError.Create('Cannot create ' + FFileName);
  try
    if FileWrite(F, Midi[1], Length(Midi)) <> Length(Midi) then
      raise EInOutError.Create('Cannot write ' + FFileName);
  finally
    FileClose(F);
  end;
end;

end.
