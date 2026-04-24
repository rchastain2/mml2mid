# mml2mid

Convert QBasic-style MML to MIDI file.

Pascal version of a [FreeBASIC program](https://www.freebasic.net/forum/viewtopic.php?p=248014#p248014) by [angros47](https://www.freebasic.net/forum/memberlist.php?mode=viewprofile&u=177).

## Usage

```bash
./mml2mid sarabande.txt sarabande.mid
```

There are beautiful Bach transcriptions in [samples-beepy](samples-beepy) folder (coming from the [beepy](https://github.com/vdust/beepy.git) project).

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

  * [beepy](https://github.com/vdust/beepy.git)
  * [GBA MML Music Player](https://github.com/inucat/gba-mml-music-player.git)
  * [MML Player](https://github.com/captainys/MMLPlayer)
  * [FreeBASIC sfx library](https://sourceforge.net/projects/freebasic-sfx-library/)
  * [FreeBASIC sfx library examples](https://codeberg.org/rchastain/fbsfx-library-examples)
