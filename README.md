# mml2mid

Convert QBasic-style MML to MIDI file.

Pascal version of a [FreeBASIC program](https://www.freebasic.net/forum/viewtopic.php?p=248014#p248014) by [angros47](https://www.freebasic.net/forum/memberlist.php?mode=viewprofile&u=177).

## Usage

```bash
./mml2mid sarabande.txt sarabande.mid
```

Lines starting with `;` are comments. Voices are separated by commas; each voice is written to its own track and MIDI channel (channel 9, used for percussion, is skipped), up to 15 voices. The tempo (`T`) is taken from the first voice.

```
; Three voices
T90 O4 L4 C E G >C,
O3 L2 C G,
O2 L1 C
```

There are beautiful Bach transcriptions in [samples-beepy](samples-beepy) folder (coming from the [beepy](https://github.com/vdust/beepy) project).

## midi2mml

`midi2mml` does the reverse: it converts a quantized MIDI file into an MML file that `mml2mid` can read.

```bash
./midi2mml prelude.mid prelude.txt
./mml2mid prelude.txt prelude-mml.mid
```

- Times are rounded to 1/48 of a quarter note (covers 64th notes and triplets).
- The notes of each track are split into monophonic voices (at most 14).
- The first voice only contains tempo changes (`T`) and rests, because `mml2mid` reads the tempo from the first voice.
- Since MML has no ties, each note gets the longest MML length (`Ln`, possibly dotted) not exceeding its real duration; voices are played legato (`ML`).
- Velocities and program changes become `V` and `I` commands.
- Pitches must stay within `O0`–`O6` (MIDI notes 12 to 95).

## Compilation

```bash
make
```

## TPlay2Mid class

```pascal
uses
  SysUtils, Play2Mid;

(*
========================================================================
 Johann Sebastian Bach
 Sarabande from C Minor Cello Suite (BWV 1011)
 FreeBASIC version 20.09.2020
========================================================================
*)

const
  A = 'O4 L8MLGE-<BMN>CL4<A- L8ML>>C<A-EMNFL4<B L8ML>>D<A-EMNFML<GMN>G MLFE-<BMN>CL4<C';
  B = 'O4 L8MLCE-A-MNGML>D-MNC ML<DFB-MNA-ML>CMN<B- MLA-GDMNE-ML<B-MN>D L2ML<E-.';
  C = 'O4 L8MLB-GDMNE-L4<D- L8ML>B-GEMNFL4<G L8ML>>D-<B-EMNFML<CMN>>C ML<B-A-EMNFL4<F';
  D = 'O3 L8MLE->CFMNE-MLB-MNA ML<D>DGMNFML>CMN<B ML>C<A-F+MNGML<BMN>C ML<G>DGMNF+ML>CMN<B';
  E = 'O5 MLE-C<F+MNGML<AMN>>E- MLL64DE-L16D.L8<A-EMNFML<BMN>G MLFE-<BMN>CML<GMN>B ML<CG>FMNE-L4ML>C';

var
  p2m: TPlay2Mid;
  
begin
  p2m := TPlay2Mid.Create('sarabande.mid');
  p2m.Play('T48' + A + B + A + B + C + D + E + C + D + E + 'P2.');
  p2m.Free;
end.
```

## Links

  * [beepy](https://github.com/vdust/beepy)
  * [C++ MML Player with YM2612 Emulator](https://github.com/captainys/MMLPlayer)
  * [mml2mid (FreeBASIC)](https://codeberg.org/rchastain/fbsfx-library-examples)
  * [sakuramml](https://github.com/kujirahand/sakuramml)
