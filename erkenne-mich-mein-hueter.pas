uses
  SysUtils, Play2Mid;

(*
========================================================================
 Johann Sebastian Bach
 Erkenne mich, mein Hüter (BWV 244/15)
 Paul Gerhardt, O Haupt voll Blut und Wunden, 5e strophe
 371 vierstimmige Choralgesänge, n° 98, transposé en mi majeur
========================================================================
*)

(* Erkenne mich, mein Hüter, / Von dir, Quell aller Güter, *)
const
  S1 = 'O4 G+4 O5C+4 O4B4 A4 G+4 F+2 G+2 P8';
  A1 = 'O4 E4 E4 E4 E8 F+8 F+8 E8 E4 D+4 E2 P8';
  T1 = 'O3 B4 A4 B4 O4C+8 O3B8 B4 O4C+4 O3B4 B2 P8';
  B1 = 'O3 E4 A4 G+4 C+8 D+8 E4 O2A4 B4 O3E2 P8';

(* Mein Hirte, nimm mich an! / Ist mir viel Guts getan. *)
const
  S2 = 'O5 D+4 E4 E4 D+8 C+8 D+4 C+1 P8';
  A2 = 'O4 F+4 E8 F+8 G+4 G+4 G+8 F+8 E1 P8';
  T2 = 'O4 C4 O3G+4 O4C+4 C+4 C4 C+1 P8';
  B2 = 'O3 D+4 C+8 D+8 E8 F+8 G+4 O2G+4 O3C+1 P8';

(* Dein Mund hat mich gelabet *)
const
  S5 = 'O5 E4 D+8 C+8 O4B4 O5C+4 D+4 E2 E2 P8';
  A5 = 'O5 C+8 O4B8 A4 G+8 F+8 E4 A4 A4 G+8 F+8 G+2 P8';
  T5 = 'O4 G+4 F+8 E8 D+4 C+8 O3B8 A8 B8 O4C+4 O3B8 A8 B2 P8';
  B5 = 'O4 C+4 O3F+4 G+4 A8 G+8 F+4 E2 E2 P8';

(* Mit Milch und süßer Kost, *)
const
  S6 = 'O4 B4 O5C+4 O4B4 A4 A4 G+1 P8';
  A6 = 'O4 G+4 A4 G+4 G+4 F+4 F1 P8';
  T6 = 'O4 E4 E4 E8 D+8 C+4 C+4 C+1 P8';
  B6 = 'O3 E4 A4 E4 F+8 G+8 A8 B8 O4C+1 P8';

(* Dein Geist hat mich begabet *)
const
  S7 = 'O5 E4 D+8 E8 F+4 E4 D+4 C+2 D+2 P8';
  A7 = 'O4 F+4 F+4 F+4 G+4 F+4 G+4 F+4 F+2 P8';
  T7 = 'O4 C+4 O3B4 B8 A+8 B8 O4C+8 D+8 O3B8 G+8 O4C+8 O3A+4 B2 P8';
  B7 = 'O3 A+4 B4 D+4 G+8 A+8 B4 E4 F+4 O2B2 P8';

(* Mit mancher Himmelslust. *)
const
  S8 = 'O4 G+4 A4 G+4 F+4 B4 G+1';
  A8 = 'O4 E4 E8 D+8 E4 E4 D+4 E1';
  T8 = 'O3 B4 A4 B4 O4C+4 O3F+8 B8 B1';
  B8 = 'O3 E8 D+8 C+4 O2B4 A4 B4 E1';

var
  p2m: TPlay2Mid;

begin
  p2m := TPlay2Mid.Create('erkenne-mich-mein-hueter.mid');
  p2m.PlayVoices([
    'T63 V100 I48 ML L4 ' + S1 + S2 + S1 + S2 + S5 + S6 + S7 + S8,
    'V80 I48 ML L4 ' + A1 + A2 + A1 + A2 + A5 + A6 + A7 + A8,
    'V80 I48 ML L4 ' + T1 + T2 + T1 + T2 + T5 + T6 + T7 + T8,
    'V90 I48 ML L4 ' + B1 + B2 + B1 + B2 + B5 + B6 + B7 + B8
  ]);
  p2m.Free;
end.
