
program mml2mid;

uses
  SysUtils, Play2Mid;

var
  p2m: TPlay2Mid;
  ln, all: string;
  tx: text;

begin
  if (ParamCount = 2) and FileExists(ParamStr(1)) then
  begin
    (* Read text file *)
    Assign(tx, ParamStr(1));
    Reset(tx);
    SetLength(all, 0);
    while not Eof(tx) do
    begin
      ReadLn(tx, ln);
      if (Length(ln) > 0) and (ln[1] <> ';') then
        all := all + ln;
    end;
    Close(tx);
    (* Set MIDI file name *)
    p2m := TPlay2Mid.Create(ParamStr(2));
    (* Create MIDI file *)
    p2m.Play(all);
    p2m.Free;
  end else
    WriteLn('Usage: ', ExtractFileName(ParamStr(0)), ' MML_FILE MIDI_FILE');
end.
