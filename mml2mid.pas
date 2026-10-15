
program mml2mid;

uses
  SysUtils, Play2Mid;

var
  p2m: TPlay2Mid;
  ln, all: string;
  tx: text;

begin
  if ParamCount <> 2 then
  begin
    WriteLn('Usage: ', ExtractFileName(ParamStr(0)), ' MML_FILE MIDI_FILE');
    ExitCode := 1;
    Exit;
  end;
  if not FileExists(ParamStr(1)) then
  begin
    WriteLn('Error: file not found: ', ParamStr(1));
    ExitCode := 1;
    Exit;
  end;
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
  try
    (* Create MIDI file *)
    try
      p2m.PlayVoices(all.Split([',']));
    except
      on e: Exception do
      begin
        WriteLn('Error: ', e.Message);
        ExitCode := 1;
      end;
    end;
  finally
    p2m.Free;
  end;
end.
