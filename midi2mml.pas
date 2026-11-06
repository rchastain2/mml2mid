program midi2mml;

uses
  SysUtils, Classes, Math;

const
  Grid = 48;
  NoteNames: array[0..11] of string = ('C', 'C+', 'D', 'D+', 'E', 'F', 'F+', 'G', 'G+', 'A', 'A+', 'B');
  Divisors: array[0..13] of integer = (1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 192);

type
  TNote = record
    StartTick, EndTick: Int64;
    Key, Velocity: byte;
  end;
  TNoteArray = array of TNote;

  TTrack = record
    Notes: TNoteArray;
    Prog: integer;
  end;

  TTempo = record
    Tick: Int64;
    MicroSec: integer;
  end;

  TLength = record
    Units: integer;
    Token: string;
  end;

  TWriter = class
  private
    FBar, FPos, FNextBar: integer;
    FOctave: integer;
    FLines: TStringList;
    FCur: string;
    procedure Advance;
    procedure Flush;
  public
    constructor Create(ABar: integer);
    destructor Destroy; override;
    procedure Token(const ATok: string; ALength: integer);
    procedure Raw(const ATok: string);
    procedure Rest(AUnits: integer);
    procedure Note(AKey: integer; AUnits: integer);
    function Text: string;
    property Pos: integer read FPos;
  end;

var
  Lengths: array of TLength;
  BestCount: array of integer;
  BestChoice: array of integer;
  Division: integer;
  Tracks: array of TTrack;
  Tempos: array of TTempo;
  SigNum, SigDen: integer;

procedure InitLengths;
var
  i, j, u: integer;
  l: TLength;

  procedure Add(AUnits: integer; const AToken: string);
  begin
    SetLength(Lengths, Length(Lengths) + 1);
    Lengths[High(Lengths)].Units := AUnits;
    Lengths[High(Lengths)].Token := AToken;
  end;

begin
  for i := 0 to High(Divisors) do
  begin
    u := 4 * Grid div Divisors[i];
    Add(u, IntToStr(Divisors[i]));
    if u * 3 mod 2 = 0 then
      Add(u * 3 div 2, IntToStr(Divisors[i]) + '.');
  end;
  for i := 1 to High(Lengths) do
  begin
    l := Lengths[i];
    j := i - 1;
    while (j >= 0) and (Lengths[j].Units < l.Units) do
    begin
      Lengths[j + 1] := Lengths[j];
      Dec(j);
    end;
    Lengths[j + 1] := l;
  end;
  SetLength(BestCount, 1);
  SetLength(BestChoice, 1);
  BestCount[0] := 0;
  BestChoice[0] := -1;
end;

procedure GrowTable(AUnits: integer);
var
  x, i, c, best, choice: integer;
begin
  if AUnits < Length(BestCount) then
    Exit;
  x := Length(BestCount);
  SetLength(BestCount, AUnits + 1);
  SetLength(BestChoice, AUnits + 1);
  while x <= AUnits do
  begin
    best := MaxInt;
    choice := -1;
    for i := 0 to High(Lengths) do
      if Lengths[i].Units <= x then
      begin
        c := BestCount[x - Lengths[i].Units] + 1;
        if c < best then
        begin
          best := c;
          choice := i;
        end;
      end;
    BestCount[x] := best;
    BestChoice[x] := choice;
    Inc(x);
  end;
end;

function Decompose(AUnits: integer): TStringArray;
var
  parts: TStringArray;
  i: integer;
begin
  GrowTable(AUnits);
  parts := nil;
  while AUnits > 0 do
  begin
    i := BestChoice[AUnits];
    SetLength(parts, Length(parts) + 1);
    parts[High(parts)] := Lengths[i].Token;
    Dec(AUnits, Lengths[i].Units);
  end;
  result := nil;
  SetLength(result, Length(parts));
  for i := 0 to High(parts) do
    result[i] := parts[High(parts) - i];
end;

function TokenUnits(const ATok: string): integer;
var
  i: integer;
begin
  for i := 0 to High(Lengths) do
    if Lengths[i].Token = ATok then
      Exit(Lengths[i].Units);
  result := 0;
end;

function LargestLE(AUnits: integer): integer;
var
  i: integer;
begin
  for i := 0 to High(Lengths) do
    if Lengths[i].Units <= AUnits then
      Exit(i);
  result := -1;
end;

function Quantize(ATick: Int64): integer;
begin
  result := Round(ATick * Grid / Division);
end;

constructor TWriter.Create(ABar: integer);
begin
  inherited Create;
  FBar := ABar;
  FPos := 0;
  FNextBar := ABar;
  FOctave := -1;
  FLines := TStringList.Create;
  FCur := '';
end;

destructor TWriter.Destroy;
begin
  FLines.Free;
  inherited;
end;

procedure TWriter.Flush;
begin
  FLines.Add(FCur);
  FCur := '';
end;

procedure TWriter.Advance;
begin
  while FPos >= FNextBar do
  begin
    Flush;
    Inc(FNextBar, FBar);
  end;
end;

procedure TWriter.Raw(const ATok: string);
begin
  Advance;
  if FCur = '' then
    FCur := ATok
  else
    FCur := FCur + ' ' + ATok;
end;

procedure TWriter.Token(const ATok: string; ALength: integer);
begin
  Raw(ATok);
  Inc(FPos, ALength);
end;

procedure TWriter.Rest(AUnits: integer);
var
  part: integer;
  tok: string;
begin
  while AUnits > 0 do
  begin
    Advance;
    part := Min(AUnits, FNextBar - FPos);
    for tok in Decompose(part) do
      Token('P' + tok, TokenUnits(tok));
    Dec(AUnits, part);
  end;
end;

procedure TWriter.Note(AKey: integer; AUnits: integer);
var
  octave: integer;
  pre: string;
begin
  octave := AKey div 12 - 1;
  if (octave < 0) or (octave > 6) then
    raise ERangeError.CreateFmt('Note out of MML range: %d', [AKey]);
  pre := '';
  if octave <> FOctave then
  begin
    if (FOctave >= 0) and (octave = FOctave + 1) then
      pre := '>'
    else if (FOctave >= 0) and (octave = FOctave - 1) then
      pre := '<'
    else
      pre := Format('O%d ', [octave]);
    FOctave := octave;
  end;
  Token(pre + NoteNames[AKey mod 12] + Decompose(AUnits)[0], AUnits);
end;

function TWriter.Text: string;
var
  s: string;
begin
  if FCur <> '' then
    Flush;
  result := '';
  for s in FLines do
    if s <> '' then
    begin
      if result <> '' then
        result := result + LineEnding;
      result := result + s;
    end;
end;

function ReadVarLen(const AData: TBytes; var AIndex: integer): Int64;
var
  b: byte;
begin
  result := 0;
  repeat
    b := AData[AIndex];
    Inc(AIndex);
    result := (result shl 7) or (b and 127);
  until b < 128;
end;

function ReadBE(const AData: TBytes; AIndex, ACount: integer): Int64;
var
  i: integer;
begin
  result := 0;
  for i := 0 to ACount - 1 do
    result := (result shl 8) or AData[AIndex + i];
end;

function NoteLess(const A, B: TNote): boolean;
begin
  if A.StartTick <> B.StartTick then Exit(A.StartTick < B.StartTick);
  if A.EndTick <> B.EndTick then Exit(A.EndTick < B.EndTick);
  if A.Key <> B.Key then Exit(A.Key < B.Key);
  result := A.Velocity < B.Velocity;
end;

function NoteLessForSplit(const A, B: TNote): boolean;
begin
  if A.StartTick <> B.StartTick then Exit(A.StartTick < B.StartTick);
  if A.Key <> B.Key then Exit(A.Key > B.Key);
  if A.EndTick <> B.EndTick then Exit(A.EndTick < B.EndTick);
  result := A.Velocity < B.Velocity;
end;

type
  TNoteLess = function(const A, B: TNote): boolean;

procedure SortNotes(var ANotes: TNoteArray; ALess: TNoteLess);

  procedure QSort(L, R: integer);
  var
    i, j: integer;
    p, t: TNote;
  begin
    while L < R do
    begin
      p := ANotes[(L + R) div 2];
      i := L;
      j := R;
      repeat
        while ALess(ANotes[i], p) do Inc(i);
        while ALess(p, ANotes[j]) do Dec(j);
        if i <= j then
        begin
          t := ANotes[i];
          ANotes[i] := ANotes[j];
          ANotes[j] := t;
          Inc(i);
          Dec(j);
        end;
      until i > j;
      if j - L < R - i then
      begin
        QSort(L, j);
        L := i;
      end else
      begin
        QSort(i, R);
        R := j;
      end;
    end;
  end;

begin
  if Length(ANotes) > 1 then
    QSort(0, High(ANotes));
end;

procedure ReadMidi(const AFileName: string);
var
  fs: TFileStream;
  d: TBytes;
  i, j, n, k, ln, trackEnd: integer;
  tick: Int64;
  s, rs, hi, ty, key, vel: byte;
  onTick: array[0..127] of Int64;
  onVel: array[0..127] of byte;
  onActive: array[0..127] of boolean;
  notes: TNoteArray;
  prog: integer;
  tt: TTempo;

  procedure CloseNote(AKey: byte);
  begin
    SetLength(notes, Length(notes) + 1);
    notes[High(notes)].StartTick := onTick[AKey];
    notes[High(notes)].EndTick := tick;
    notes[High(notes)].Key := AKey;
    notes[High(notes)].Velocity := onVel[AKey];
    onActive[AKey] := false;
  end;

begin
  fs := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(d, fs.Size);
    if fs.Size > 0 then
      fs.ReadBuffer(d[0], fs.Size);
  finally
    fs.Free;
  end;
  if (Length(d) < 14) or (Chr(d[0]) + Chr(d[1]) + Chr(d[2]) + Chr(d[3]) <> 'MThd') then
    raise Exception.Create('Not a MIDI file: ' + AFileName);
  Division := ReadBE(d, 12, 2);
  if Division and $8000 <> 0 then
    raise Exception.Create('SMPTE time division is not supported');
  SigNum := 3;
  SigDen := 4;
  i := 14;
  while i + 8 <= Length(d) do
  begin
    n := ReadBE(d, i + 4, 4);
    j := i + 8;
    trackEnd := Min(j + n, Length(d));
    i := j + n;
    tick := 0;
    rs := 0;
    FillChar(onActive, SizeOf(onActive), 0);
    notes := nil;
    prog := -1;
    while j < trackEnd do
    begin
      Inc(tick, ReadVarLen(d, j));
      s := d[j];
      if s < $80 then
        s := rs
      else
        Inc(j);
      if s = $FF then
      begin
        ty := d[j];
        Inc(j);
        ln := ReadVarLen(d, j);
        if ty = $51 then
        begin
          tt.Tick := tick;
          tt.MicroSec := ReadBE(d, j, 3);
          SetLength(Tempos, Length(Tempos) + 1);
          Tempos[High(Tempos)] := tt;
        end else
        if (ty = $58) and (tick = 0) then
        begin
          SigNum := d[j];
          SigDen := 1 shl d[j + 1];
        end;
        Inc(j, ln);
      end else
      if (s = $F0) or (s = $F7) then
      begin
        ln := ReadVarLen(d, j);
        Inc(j, ln);
      end else
      begin
        rs := s;
        hi := s and $F0;
        if (hi = $C0) or (hi = $D0) then
        begin
          if (hi = $C0) and (prog < 0) then
            prog := d[j];
          Inc(j);
          Continue;
        end;
        key := d[j];
        vel := d[j + 1];
        Inc(j, 2);
        if (hi = $90) and (vel > 0) then
        begin
          if onActive[key] then
            CloseNote(key);
          onTick[key] := tick;
          onVel[key] := vel;
          onActive[key] := true;
        end else
        if (hi = $80) or (hi = $90) then
        begin
          if onActive[key] then
            CloseNote(key);
        end;
      end;
    end;
    if Length(notes) > 0 then
    begin
      SortNotes(notes, @NoteLess);
      SetLength(Tracks, Length(Tracks) + 1);
      Tracks[High(Tracks)].Notes := notes;
      Tracks[High(Tracks)].Prog := prog;
    end;
  end;
  for i := 1 to High(Tempos) do
  begin
    tt := Tempos[i];
    k := i - 1;
    while (k >= 0) and ((Tempos[k].Tick > tt.Tick) or ((Tempos[k].Tick = tt.Tick) and (Tempos[k].MicroSec > tt.MicroSec))) do
    begin
      Tempos[k + 1] := Tempos[k];
      Dec(k);
    end;
    Tempos[k + 1] := tt;
  end;
end;

type
  TLanes = array of TNoteArray;

function SplitVoices(ANotes: TNoteArray): TLanes;
var
  i, l, best, dist, bestDist, j: integer;
  lane: TNoteArray;
  avg: array of double;
  a: double;
begin
  result := nil;
  SortNotes(ANotes, @NoteLessForSplit);
  for i := 0 to High(ANotes) do
  begin
    best := -1;
    bestDist := MaxInt;
    for l := 0 to High(result) do
      if result[l][High(result[l])].EndTick <= ANotes[i].StartTick then
      begin
        dist := Abs(integer(result[l][High(result[l])].Key) - ANotes[i].Key);
        if dist < bestDist then
        begin
          bestDist := dist;
          best := l;
        end;
      end;
    if best < 0 then
    begin
      SetLength(result, Length(result) + 1);
      best := High(result);
    end;
    SetLength(result[best], Length(result[best]) + 1);
    result[best][High(result[best])] := ANotes[i];
  end;
  SetLength(avg, Length(result));
  for l := 0 to High(result) do
  begin
    a := 0;
    for j := 0 to High(result[l]) do
      a := a + result[l][j].Key;
    avg[l] := a / Length(result[l]);
  end;
  for i := 1 to High(result) do
  begin
    lane := result[i];
    a := avg[i];
    j := i - 1;
    while (j >= 0) and (avg[j] < a) do
    begin
      result[j + 1] := result[j];
      avg[j + 1] := avg[j];
      Dec(j);
    end;
    result[j + 1] := lane;
    avg[j + 1] := a;
  end;
end;

function LaneMML(const ALane: TNoteArray; ABar, AProg: integer; out AEnd: integer): string;
var
  w: TWriter;
  idx, s, e, nxt, dur, vol, li: integer;
begin
  w := TWriter.Create(ABar);
  try
    w.Raw('ML');
    if AProg >= 0 then
      w.Raw('I' + IntToStr(AProg));
    vol := -1;
    for idx := 0 to High(ALane) do
    begin
      s := Quantize(ALane[idx].StartTick);
      e := Quantize(ALane[idx].EndTick);
      if s > w.Pos then
        w.Rest(s - w.Pos);
      dur := Max(e - s, 1);
      if idx < High(ALane) then
      begin
        nxt := Quantize(ALane[idx + 1].StartTick);
        dur := Min(dur, nxt - s);
      end;
      li := LargestLE(dur);
      if li < 0 then
        Continue;
      if ALane[idx].Velocity <> vol then
      begin
        vol := ALane[idx].Velocity;
        w.Raw('V' + IntToStr(vol));
      end;
      w.Note(ALane[idx].Key, Lengths[li].Units);
    end;
    AEnd := w.Pos;
    result := w.Text;
  finally
    w.Free;
  end;
end;

function Conductor(AEnd, ABar: integer): string;
var
  w: TWriter;
  i, pos, bpm, count: integer;
  chPos, chBpm: array of integer;
  all: array of TTempo;
begin
  if (Length(Tempos) = 0) or (Tempos[0].Tick > 0) then
  begin
    SetLength(all, Length(Tempos) + 1);
    all[0].Tick := 0;
    all[0].MicroSec := 500000;
    for i := 0 to High(Tempos) do
      all[i + 1] := Tempos[i];
  end else
    all := Copy(Tempos);
  SetLength(chPos, Length(all));
  SetLength(chBpm, Length(all));
  count := 0;
  for i := 0 to High(all) do
  begin
    pos := Quantize(all[i].Tick);
    bpm := EnsureRange(Round(60000000 / all[i].MicroSec), 32, 255);
    if (count > 0) and (chPos[count - 1] = pos) then
      chBpm[count - 1] := bpm
    else if (count = 0) or (chBpm[count - 1] <> bpm) then
    begin
      chPos[count] := pos;
      chBpm[count] := bpm;
      Inc(count);
    end;
  end;
  w := TWriter.Create(ABar);
  try
    for i := 0 to count - 1 do
    begin
      if chPos[i] > w.Pos then
        w.Rest(chPos[i] - w.Pos);
      w.Raw('T' + IntToStr(chBpm[i]));
    end;
    if AEnd > w.Pos then
      w.Rest(AEnd - w.Pos);
    result := w.Text;
  finally
    w.Free;
  end;
end;

var
  bar, t, l, laneEnd, endPos, nVoices: integer;
  lanes: TLanes;
  voices: TStringList;
  output: string;
  tx: text;

begin
  if ParamCount <> 2 then
  begin
    WriteLn('Usage: ', ExtractFileName(ParamStr(0)), ' MIDI_FILE MML_FILE');
    ExitCode := 1;
    Exit;
  end;
  if not FileExists(ParamStr(1)) then
  begin
    WriteLn('Error: file not found: ', ParamStr(1));
    ExitCode := 1;
    Exit;
  end;
  InitLengths;
  voices := TStringList.Create;
  try
    try
      ReadMidi(ParamStr(1));
      bar := Grid * 4 * SigNum div SigDen;
      endPos := 0;
      for t := 0 to High(Tracks) do
      begin
        lanes := SplitVoices(Tracks[t].Notes);
        for l := 0 to High(lanes) do
        begin
          voices.Add(LaneMML(lanes[l], bar, Tracks[t].Prog, laneEnd));
          endPos := Max(endPos, laneEnd);
        end;
      end;
      nVoices := voices.Count;
      if nVoices + 1 > 15 then
        raise Exception.CreateFmt('Too many voices: %d (14 at most, plus the tempo voice)', [nVoices]);
      voices.Insert(0, Conductor(endPos, bar));
      output := voices[0];
      for l := 1 to voices.Count - 1 do
        output := output + LineEnding + ',' + LineEnding + voices[l];
      Assign(tx, ParamStr(2));
      Rewrite(tx);
      WriteLn(tx, output);
      Close(tx);
      WriteLn(nVoices, ' voices, ', endPos div bar, ' bars');
    except
      on e: Exception do
      begin
        WriteLn('Error: ', e.Message);
        ExitCode := 1;
      end;
    end;
  finally
    voices.Free;
  end;
end.
