'Program for the simulation of pigmentation patterns on sea shells
' (c) by Hans Meinhardt, 1995 - 2002

'旼 A word of precaution...  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
'�                                                                         �
'�  The software was written with care but the customer knows that         �
'�  software cannot be produced without errors. Springer-Verlag and the    �
'�  author disclaim any liability for software errors or their             �
'�  consequences.                                                          �
'�                                                                         �
'�  All user rights to the software are held exclusively by the author.    �
'�  Springer-Verlag does not author data and programs but makes them       �
'�  available. Any commercial use or distribution independently of the     �
'�  book is not permitted                                                  �
'읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
' This version is appropriate for MS - BASIC

DEFINT H-N
DECLARE SUB hormone (ila%, ahorm!, ja%, js%)
DECLARE SUB oscillation (ila%, C!, D!, olddecaydiffC!, olddecaydiffD!, ja%, js%)
DECLARE SUB cmessage (itype%, iline%, irow%, ilettercol%, iletterback%, ibackcol%, text$, resp$)
DECLARE SUB gtreturn (inz%, igt%)
DECLARE SUB init (inewscreen%, igraph%, ivorcol%, ibackcol%, ivgashift%)
DECLARE SUB manipulationxt (pcontrol2$, ja%, js%, kinsert%, imxl%, imxl2%, icc%)
DECLARE SUB paramenu ()
DECLARE SUB showprof (inz%, iendm%, dw$, a!(), ja%, js%, icc%)
DECLARE SUB switchscreen (inz%, iactive%, ibackcol%)
DECLARE SUB zeingabe (igt%, iquest%, inz%, i%, f!, LABEL$, text$)

''$INCLUDE "plibxt.inc" ' this line is required ONLY for POWER-BASIC
' $INCLUDE: 'sub-util\scommon.bi' nur f걊 Microsoft-Basic gebraucht

DATA 10,22,55,75,115,180,195,240,310,352,375,425,455,555,585,595,630
programname$ = "SP":
pdir$ = "PARAM\"
basfilename$ = "SP.BAS"
imxl = 300: imyl = 641 '갶er Ky wird max. Zellzahl in XT-Progr. angegeben
imxl2 = imyl / 2: ianzmax = 9: msiluetmax = 800
DIM parnam$(75), flv(60), inv(15), msiluet(msiluetmax)
DIM a(ianzmax, imyl), LABEL$(10)
DIM xa(8), fa(8), am(8), ya(8), f1(8), icol(8), ityp(8), iwi(8)
DIM s$(150)
ihp = 1: igtdelay = 20: inewscreen = 1
diffmax = .4'Maximalwert f걊 die Diffusion
CLS : RANDOMIZE TIMER

parameter:
ON ERROR GOTO 0
CALL paramenu '----- set simulation parameters, choose equation etc.

 '-----------------  start / continuation of program ------------------
SELECT CASE PCONTROL$
CASE "S", "N", "C", "D", "I", "II", "CS"
  dra = 1! - ra - 2! * DA '- sparing simulation time: factor by which
  drb = 1! - rB - 2! * DB '- concentration becomes reduced due to decay and
  drc = 1! - rc - 2! * DC '- diffusion is calculated in advance
  drd = 1! - rd - 2! * DD
  dre = 1! - re - 2! * DE
  drf = 1! - rf - 2! * DF
  drg = 1! - rg - 2! * DG
  drh = 1! - rH - 2! * DH
  ahorm = 0: igrowth = 0: icountk3 = 0
  icountot = 0
  IF PCONTROL$ = "N" OR PCONTROL$ = "D" GOTO newplot
  IF PCONTROL$ = "C" AND iparam < 2 GOTO newplot
    IF PCONTROL$ = "C" THEN
   'IF igt = 0 AND igraph = 12 AND icc = 1 THEN
   CALL cmessage(3, -1, 1, 1, 15, ibackcol, title$, resp$)
   'END IF
    GOTO continue
  END IF
   '---------------------    initial conditions  --------------
  ja = KX: js = ky
  ja = KX: js = ky
  imxnew = imxl2: IF ky > imxnew THEN imxnew = imyl
  FOR i = 1 TO imxnew
    IF PCONTROL$ <> "II" THEN  'II maintains random numbers
    'RND: random numbers between 0.0 and 1.0 lead to �KR% fluctuations
      a(0, i) = ra * (1! + 2 * KR / 100 * (RND - .5)) 'Source density  s
      a(8, i) = 1
      a(9, i) = 1! + 2 * KR / 100 * (RND - .5)
      IF ca > 0 THEN a(0, i) = ca * (1! + 2 * KR / 100 * (RND - .5))
    END IF
    a(1, i) = gA '-- initial condition: A is set to GA in all cells
    a(2, i) = gB '-- B to GB etc.
    a(3, i) = gC
    a(4, i) = gD
    a(5, i) = ge
    a(6, i) = gf
    a(7, i) = gg
  NEXT i

  SELECT CASE KI '---- KI determines particular initial conditions -------
  CASE 1: a(1, ja) = aA: a(3, ja) = aC: a(5, ja) = aE  'left cell
  CASE 2: a(1, ja) = aA: a(3, ja) = aC: a(1, js) = aA: a(3, js) = aC
       a(5, ja) = aE: a(5, js) = aE
  CASE 3:
  jx = js / 2: a(1, jx) = aA: a(3, jx) = aC
       a(5, jx) = aE  'cell in the centre
  CASE 4
    DO WHILE i > 0 'particular cells are initiated during run-time
      mess$ = "# of cell to be initially active (A(#) = aa), <return>=stop"
      CALL zeingabe(igt, 0, 1, i, dummy, dummy$, mess$)
      a(1, i) = aA
    LOOP
  CASE 5, 15
    FOR i = 1 TO 17
    READ ix 'Special cells are red from data statement
    IF ix > js THEN EXIT FOR
    a(1, ix) = aA: a(3, ix) = aC: a(5, ix) = aE
    NEXT i: RESTORE
    IF KI = 15 GOTO STEPPATTERN
  CASE 6 'Random cells are activated at maximum 50 cells distance
    ix = RND * 30
    FOR i = 1 TO 20
    a(1, ix) = aA: a(3, ix) = aC
    ix = ix + RND * 40 + 10
    IF ix > js THEN EXIT FOR
    NEXT i
  CASE 7 'sinusoidal prepattern, used for space-dependent
    amax7 = 0'                    substrate production
    FOR i = 1 TO ky
      a(8, i) = 1! + dy * (COS((i - k2) * 3.14 / K1)) ^ 2 + i * aB / ky
      IF a(8, i) > amax7 THEN amax7 = a(8, i)
    NEXT i
    FOR i = 1 TO ky: a(8, i) = a(8, i) / amax7: NEXT i'Normalization
    '    artificial spatial periodic, stable in time, dy determines
    '    the difference between maxima and minima, K1 the spatial wavelength.
    '    K2 is the phase; AB adds a linear gradient (for Nautilus Pompilius)
CASE 8 'Exponential gradient or bzw sinusoidal distribution of the source
    FOR ix = 1 TO ky:
    a(0, ix) = a(0, ix) * EXP(-aB * (ix - 1)) * (1! + dy * (COS((ix - k2) * 3.14 / (ky))) ^ 2)
    NEXT ix

  CASE 9 'a more step-like distribution
STEPPATTERN:
    FOR i = k2 TO K4: a(8, i) = 1 + dy: NEXT
    FOR i = K1 + 1 TO ky: a(8, i) = a(8, i - K1): NEXT'Repetition after K1 cells
    FOR i = 1 TO ky: a(8, i) = a(8, i) + i * aB / ky: NEXT
    FOR ji = 1 TO DZ
      al = a(8, KX)'smoothing
      FOR i = KX TO ky - 1: a(8, i) = (a(8, i) + a(8, i + 1)) / 2: NEXT i
      FOR i = ky TO KX + 1 STEP -1: a(8, i) = (a(8, i) + a(8, i - 1)) / 2
      NEXT i: NEXT ji
    amax7 = 0 'normalization
    FOR i = 1 TO ky: IF a(8, i) > amax7 THEN amax7 = a(8, i)
    NEXT i
    FOR i = 1 TO ky: a(8, i) = a(8, i) / amax7: NEXT i'normalization
  CASE 10 'particular cell may function as pace-makers
    a(8, ja) = aB 'left cell
  CASE 11 'left and right cells can be pacemaker
    a(8, ja) = aB
    a(8, js) = aB

'------------Special cases for non-shell patterns, gene-activations etc.

  CASE 121 'for gene activation in different cells
    'ca = Efficiency of the genes, cb=Slope of the gradient
    FOR i = 1 TO js: a(8, i) = EXP(cB * (i - 1))
    a(6, i) = ba * a(8, i): NEXT 'Positional Information
    fkr = KR / 100
    FOR iy = 1 TO 4 ' Efficiency of the genes in the autocatalysis
    a(0, iy) = ra * (1 + fkr * RND - .5 * fkr): NEXT

  CASE 123'for Gen-Activation in single cells
    a(1, ja) = aA ' Gene 1 somewhat different
    FOR i = ja TO js: a(8, i) = 0: NEXT
    a(8, js) = aB ' Signal for switching acts only on the last cell

  CASE 124: 'Gene activation in a single cell: threshold
    FOR i = 1 TO js: a(8, i) = 1 + i * aB / ky: a(2, i) = ba * a(8, i)
    NEXT i 'Pos. Inf. in B
 CASE 126 'Small initial gradient, only for hydra-simulation
    FOR ix = 1 TO ky: a(3, ix) = gC * EXP(-aC * (ix - 1)): NEXT ix
   CASE ELSE
    mess$ = "no such initial conditions, use KI between 1 and 11"
    resp$ = "ok": CALL cmessage(4, -1, 1, 15, 4, 0, mess$, resp$)
    GOTO parameter
  END SELECT
  itot& = 0: igrowth = 0: icountk3 = 0
newplot:
  IF PCONTROL$ = "CS" THEN 'Screen not cleared, second pattern drawn
			   'on top of the first
    CALL zeingabe(igt, 1, 1, icol(1), dummy, dummy$, "New colour, 0-14")
  ELSE
  CALL init(inewscreen, igraph, ivorcol, ibackcol, ivgashift)
  END IF
  IF igraph = 12 THEN CALL cmessage(5, -1, 1, 1, 15, ibackcol, LABEL$(0), "")
  icc = 0
simulation:
  icc = icc + 1
  CALL showprof(KD, 1, displaywas$, a(), ja, js, icc) ' Plot on screen
  IF INKEY$ = CHR$(27) THEN GOTO EndSimulation' interrupted with ESC
  IF icountot >= KT OR PCONTROL$ = "I" OR PCONTROL$ = "II" GOTO EndSimulation
  IF PCONTROL$ = "D" GOTO EndSimulation

continue:
 ON ERROR GOTO erroverflow
igrowth = igrowth + 1: icountk3 = icountk3 + 1
IF KG > 0 THEN 'growth by insertion of additional cells if kg>0
IF igrowth >= KG AND js < imyl - 1 THEN
   igrowth = 0
   CALL manipulationxt("G", ja, js, kinsert, imyl, imxl2, icc)
END IF 'K1 determines the mode of insertion
END IF

' Begin of the iterations. After each KP iterations the concentration are
' plotted. This will happens KT times. Altogether KT * KP time steps will
' be calculated.

jrechts = js: jlinks = ja
IF KD = 16 OR KD = 22 THEN jrechts = ja: jlinks = js' cyclic boundary

FOR iprint = 1 TO KP  '-- SECOND LOOP: kp iterations until next plot ------

' Boundary conditions: impermeable; this is achieved by
' giving the cells ja-1 and js+1 the same values as cells ja resp.js
' or , if k1=11, then cyclic
  FOR il = 1 TO KN: a(il, js + 1) = a(il, jrechts): NEXT il 'right border cells
  al = a(1, jlinks): bl = a(2, jlinks) ' virtual left border cells:
  IF KN > 2 THEN cl = a(3, jlinks): dl = a(4, jlinks):
  IF KN > 4 THEN el = a(5, jlinks): fl = a(6, jlinks):  gl = a(7, jlinks)
  IF KN > 7 THEN zhl = a(8, jlinks)

' don't change next line, otherwise the command PE will no longer work
SELECT CASE KE'EQUATIONS  '---- Auswahl der Geleichungen


'      ================ Main equations ==================
CASE 21 '- activator - inhibitor mechanism: B is inhibitor --------------
   FOR i = ja TO js: GOSUB olddecay
     a(1, i) = olddecaydiffA + s * (a * a / B + ba)
     a(2, i) = olddecaydiffB + s * a * a + bb
   NEXT i

CASE 211 '- activator - inhibitor mechanism: B is inhibitor --------------
   'This is a special Version of Eq. 21 for the simulations in two
   'separate fields to show regeneration
   IF K4 = 0 THEN K4 = (js - ja) / 2 + 2
   a(1, K4) = a(1, K4 - 1): a(2, K4) = a(2, K4 - 1):
   FOR i = ja TO K4 - 1: GOSUB olddecay
     a(1, i) = olddecaydiffA + s * (a * a / B + ba)
     a(2, i) = olddecaydiffB + s * a * a + bb
   NEXT i
   al = a(1, K4 + 1): bl = a(2, K4 + 1):
   FOR i = K4 + 1 TO js: GOSUB olddecay
     a(1, i) = olddecaydiffA + s * (a * a / B + ba)
     a(2, i) = olddecaydiffB + s * a * a + bb
   NEXT i


CASE 23 '- activator - inhibitor mechanism: B is inhibitor --------------
   FOR i = ja TO js: GOSUB olddecay
     'with saturation and Michaelis-Menten-cinetics
     a(1, i) = olddecaydiffA + s * (a * a / (sb + B) / (1 + sA * a * a) + ba)
     a(2, i) = olddecaydiffB + s * a * a + bb
   NEXT i

CASE 24 '- activator-depletion mechanism:  ----
     '   a activator,  b substrate,
     '   a(8,i) may contain a stable pattern (normalized to 1)
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1 + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * a(8, i)
	IF a(2, i) < 0 THEN a(2, i) = 0
   NEXT i

CASE 51 '------- Crossings  a: activator, b: substrate c: inhibitor
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a + ba) / (1! + sA * a * a) / (sb + sc * C)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * a(8, i)
     a(3, i) = olddecaydiffC + rc * a
     IF a(2, i) < 0 THEN a(2, i) = 0
   NEXT i

CASE 52 '--- one activator - two substrates
   FOR i = ja TO js: GOSUB olddecay
       aqfs = a * a / (1 + sA * a * a)
       aqb = s * B * aqfs
       aqc = cB * C * aqfs
       a(1, i) = olddecaydiffA + aqb + aqc
       a(2, i) = olddecaydiffB - aqb + bb
       a(3, i) = olddecaydiffC - aqc + bc
   NEXT i
CASE 511 '- activator - inhibitor mechanism: B is inhibitor --------------
   FOR i = ja TO js: GOSUB olddecay
     a(1, i) = olddecaydiffA + C * s * (a * a / B + ba)
     a(2, i) = olddecaydiffB + C * s * a * a + bb
     a(3, i) = olddecaydiffC + bc - sc * a * C
   NEXT i

CASE 512 '------- Crossings  a: activator, b: substrate c: inhibitor
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a + ba) / (1! + sA * a * a) / (sb + sc * C)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - cC * aq + bb
     a(3, i) = olddecaydiffC + rc * a * a
     IF a(2, i) < 0 THEN a(2, i) = 0
   NEXT i

CASE 61 '-- Branches controlled by a hormone  : Olivia Porphyria ----------
     '  Hormone (c) changes lifetime of the inhibitor
   FOR i = ja TO js: GOSUB olddecay
     aq = s * a * a / (1! + sA * a * a) + ba
     a(1, i) = olddecaydiffA + aq / (sb + B)
     a(2, i) = olddecaydiffB + aq + bb
     ahorm = ahorm + rc * a 'hormone production by a
     IF i = js THEN 'averaging
     CALL hormone(3, ahorm, ja, js)
      rbb = rB / C '---- effective inhibitor decay rate
      drb = 1! - 2! * DB - rbb
     END IF
   NEXT i

CASE 71 '-- activation (a, b), enhancement (c, d)
   FOR i = ja TO js: GOSUB olddecay
     'and  extinguishing  (e, f) reaction
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq - cE * a * e
     a(2, i) = olddecaydiffB - aq + bb * (1 + sb * C + cB * D)
     cq = rc * a * (C * C + bc)
     a(3, i) = olddecaydiffC + cq / (sd + D)
     a(4, i) = olddecaydiffD + cq + bd
     eqf = e * e
     eq = re * f * (eqf / (1! + se * eqf) + be)
     a(5, i) = olddecaydiffE + eq + sf * a
     a(6, i) = olddecaydiffF - eq + bf * a + cF * a(8, i)
     IF a(2, i) < 0 THEN a(2, i) = 0'to avoid numerical instabilities
     IF a(6, i) < 0 THEN a(6, i) = 0
   NEXT i

CASE 711 '-- activation (ab) and extinguishing  (e,f) reaction
     'as 71 without enhancing reaction
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq - cE * a * e
     a(2, i) = olddecaydiffB - aq + bb
     eqf = e * e
     eq = re * f * (eqf / (1! + se * eqf) + be)
     a(5, i) = olddecaydiffE + eq + sf * a
     a(6, i) = olddecaydiffF - eq + bf * a + cF * a(8, i)
     IF a(2, i) < 0 THEN a(2, i) = 0
     IF a(6, i) < 0 THEN a(6, i) = 0
   NEXT i

CASE 712 '-- activation (ab) and enhancing (c,d) reaction
     'as 71 without extinguishing reaction
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * (1 + sb * C + cB * D) * a(8, i)
     IF a(2, i) < 0 THEN a(2, i) = 0
     cq = rc * a * (C * C + bc)
     a(3, i) = olddecaydiffC + cq / (sd + D)
     a(4, i) = olddecaydiffD + cq + bd
   NEXT i

CASE 713 '-- activation (ab) and enhancing (c,d) reaction
     'as 71 without extinguishing reaction
     'as 712 but for band modulated is live time of the activator
   FOR i = ja TO js:
   dra = 1 - ra / a(8, i) - 2 * DA
   GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * (1 + sb * C + cB * D)
     IF a(2, i) < 0 THEN a(2, i) = 0
     cq = rc * a * (C * C + bc)
     a(3, i) = olddecaydiffC + cq / (sd + D)
     a(4, i) = olddecaydiffD + cq + bd
   NEXT i


CASE 714 '-- sharp dots (d, e) along invisible lines (c)
     'and waves (a, b)
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * (1 + cE * e)
     eq = re * a * C * (e * e + be)
     a(5, i) = olddecaydiffE + eq / (sf + f)
     a(6, i) = olddecaydiffF + eq
   NEXT i

CASE 72 '---  a, b = pigmentation, c, d = enhancement, e = pool
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba * C)
     a(1, i) = olddecaydiffA + aq
     frompool = bb * se * e / (1 + se * e + cE * B) * (1 + sc * C)
     IF frompool > e THEN frompool = e
     a(2, i) = olddecaydiffB - aq + frompool
     cq = rc * a(9, i) * a * (C * C + bc)
     a(3, i) = olddecaydiffC + cq / (sd + D)
     a(4, i) = olddecaydiffD + cq
     a(5, i) = olddecaydiffE + be * a(8, i) - frompool
     IF a(2, i) < 0 THEN a(2, i) = 0
     IF a(5, i) < 0 THEN a(5, i) = 0
   NEXT i

CASE 77 '---------two activator-depletion mechanisms, c kills a
       'plus a stagered dot system that enhances a
       'for Cymbiolacca wisemani
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq - cC * a * C
     a(2, i) = olddecaydiffB - aq + bb * (1 + cE * e)
     IF a(2, i) < 0 THEN a(2, i) = 0
' killing reaction
     cqf = C * C
     cq = a(9, i) * D * (cqf / (1! + sc * cqf) + bc)
     a(3, i) = olddecaydiffC + cq + sd * a
     a(4, i) = olddecaydiffD - cq + bd * a + cd * e
     IF a(4, i) < 0 THEN a(4, i) = 0
'enhancing reaction
     a(5, i) = olddecaydiffE + re * a * a(9, i) / g * (e * e / f + be)
     a(6, i) = olddecaydiffF + rf * e * e / g
     a(7, i) = olddecaydiffG + rg * e
   NEXT i

CASE 91 '---  Clithon
     ' a,b -> pigmentation (AS-system)
     ' c,d -> precondition/background (AI-system)
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * C * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb
     cqf = C ^ 2
     REM a(9,i) = 1 � random fluctuations (given by KR in %)
     cq = rc * a(9, i) * (cqf / (1! + sc * cqf) + bc * a)
     a(3, i) = olddecaydiffC + cq / (D + cd * B + se * e)
     a(4, i) = olddecaydiffD + cq + bd * a(8, i)
     a(5, i) = olddecaydiffE + be * a(8, i) * C'the long term poison
   NEXT i

'CASE ============ Special cases and modified equations ==================

CASE 242 '- Natica euzona
   FOR i = ja TO js:
     dra = 1 - ra * a(8, i) - 2! * DA
     GOSUB olddecay
     aq = a(8, i) * s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * a(8, i)
   NEXT i

CASE 27 'autocatalysis by an inhibition of an inhibition (a and c)
   FOR i = ja TO js: GOSUB olddecay
     a(1, i) = olddecaydiffA + s / (sA + C * C) + ba
     a(2, i) = olddecaydiffB + rB * a
     a(3, i) = olddecaydiffC + rc / (sc + a * a / (sb + B * B))
   NEXT i

CASE 41 ' activator - inhibitor mechanism and feedback on the source (c)
   FOR i = ja TO js: GOSUB olddecay
     aq = C * s * (a * a + ba)    '------    simple rows of dots
     a(1, i) = olddecaydiffA + aq / B
     a(2, i) = olddecaydiffB + aq + bb
     'Source (C)
     a(3, i) = olddecaydiffC + rc * a + bc
  NEXT i
CASE 42 '--Two activ.-inh. systems a, b and c, d. c inhibits also a
   FOR i = ja TO js: GOSUB olddecay
     aq = a * a / (1! + sA * a * a)'    ----    for Junona
     a(1, i) = olddecaydiffA + s * (aq / (B + sb * C) + ba)
     a(2, i) = olddecaydiffB + rB * aq + bb
     cq = rc * a(9, i) * (C * C + bc)
     a(3, i) = olddecaydiffC + cq / D
     a(4, i) = olddecaydiffD + cq
   NEXT i

CASE 43 '- activator - inhibitor mechanism:
     'lifetime of the inhibitior is space-dependent
     ' shifted horizontal lines, one system
   FOR i = ja TO js:
   drb = 1 - rB * a(8, i) - 2 * DB
   GOSUB olddecay
     aq = a * a / (1 + sA * a * a)
     a(1, i) = olddecaydiffA + s * (aq / B + ba)
     a(2, i) = olddecaydiffB + rB * aq
   NEXT i

CASE 44 '-- activation (a, b) and enhancing (c, d) reaction
     ' shifted horizontal lines, two systems
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba + cC * C)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * a(8, i)
     cq = rc * D * (C * C / (1 + sc * C * C) + bc)
     a(3, i) = olddecaydiffC + cq
     a(4, i) = olddecaydiffD - cq + bd
   NEXT i

CASE 53 'shifted dots = c has negative feedback on a and b
   FOR i = ja TO js: GOSUB olddecay
     a(1, i) = olddecaydiffA + s / C * (a * a / B + ba)
     a(2, i) = olddecaydiffB + rB * a * a / C + bb
     a(3, i) = olddecaydiffC + rc * a
   NEXT i

CASE 531 'shifted dots = c has negative feedback on a and b
' f걊 die Bl꼝ter,
' d,e=zweites System, f걊 Polarit꼝
   FOR i = ja TO js: GOSUB olddecay
     a(1, i) = olddecaydiffA + s / (C + cC * D) * (a * a / B + ba)
     a(2, i) = olddecaydiffB + rB * a * a / C + bb
     a(3, i) = olddecaydiffC + rc * a
     dq = rd * a(9, i) * (D * D + bd)
     a(4, i) = olddecaydiffD + dq / e + bd * a
     a(5, i) = olddecaydiffE + dq + be

   NEXT i

CASE 54 'shifted dots triangles =  sum of two inhibitors
   FOR i = ja TO js: GOSUB olddecay
     a(1, i) = olddecaydiffA + s * (a * a + ba) / (sb * B + sc * C)
     a(2, i) = olddecaydiffB + rB * a * a + bb
     a(3, i) = olddecaydiffC + rc * a
 NEXT i

CASE 62 '- Branches controlled by a hormone  : Olivia Porphyria ----------
     '  Hormone (c) changes lifetime of the activator
   FOR i = ja TO js: GOSUB olddecay
     aq = s * a * a / (1! + sA * a * a) + ba
     a(1, i) = olddecaydiffA + aq / (sb + B)
     a(2, i) = olddecaydiffB + aq + bb
     ahorm = ahorm + rc * a '------ hormone production by a
     IF i = js THEN
     CALL hormone(3, ahorm, ja, js)
       raa = ra * C '---- effective inhibitor decay rate
       dra = 1! - 2! * DA - raa
     END IF
   NEXT i

CASE 63 '- Branches controlled by a hormone  : Olivia Porphyria ----------
     '  Hormone (c) changes production rate of substrate b
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1 + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb / (cB + sb * C)
     ahorm = ahorm + rc * a '------ hormone production by a
     IF i = js THEN CALL hormone(3, ahorm, ja, js)
   NEXT i

CASE 64 ' Branches controlled by a hormone  : Olivia Porphyria ----------
     '  Hormone changes lifetime of the inhibitor
     '  two inhibitors are involved (b,d) a: activator, c: hormone
   FOR i = ja TO js: GOSUB olddecay
     aq = s * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq / (sb + sd * D + B)
     a(2, i) = olddecaydiffB + aq + bb
     a(4, i) = olddecaydiffD + rd * a
     ahorm = ahorm + rc * a ' hormone production by a
     IF i = js THEN
     CALL hormone(3, ahorm, ja, js)
       rbb = rB / C '---- effective inhibitor decay rate
       drb = 1! - 2! * DB - rbb
     END IF
   NEXT i

CASE 73 '-- Survival by change of substrate production
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq - sb * a * C
     a(2, i) = olddecaydiffB - aq + bb * C
     a(3, i) = olddecaydiffC + rc * B
   NEXT i

CASE 731 ' Production rate of the substrate increases in non-activated
     ' periods via c
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * C
     a(3, i) = olddecaydiffC + rc / (cC + bc * a)
   NEXT i

CASE 81 '- activator-depletion mechanisms, homogeneous oscillation
'oscillation blocks substrate production or enhances activator destruction
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq - cC * a * C
     a(2, i) = olddecaydiffB - aq + bb / (1 + sb * C)
IF i = js THEN CALL oscillation(3, C, D, olddecaydiffC, olddecaydiffD, ja, js)
   NEXT i

CASE 83 '----- Crossing solution plus oscillations
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a + ba) / (1! + sA * a * a) / (sb + sc * C)
     a(1, i) = olddecaydiffA + aq - cC * D * a
     a(2, i) = olddecaydiffB - aq + bb
     a(3, i) = olddecaydiffC + rc * a
IF i = js THEN CALL oscillation(4, D, e, olddecaydiffD, olddecaydiffE, ja, js)
   NEXT i

CASE 832 ' Crossing solution plus oscillations (de -> ai-system)
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a + ba) / (1! + sA * a * a) / (sb + sc * C)
     a(1, i) = olddecaydiffA + aq - cC * D * a
     a(2, i) = olddecaydiffB - aq + bb * (1 + cB * D)
     a(3, i) = olddecaydiffC + rc * a
     dq = rd * a(9, i) * (D * D + bd)
     a(4, i) = olddecaydiffD + dq / e
     a(5, i) = olddecaydiffE + dq
   NEXT i

CASE 84 'triangles with global stop, two inhibitors, hormone and oscillation
     'a=activator, b,c inhibitors; cd = oscillation, e=hormone
   FOR i = ja TO js: GOSUB olddecay
     a(1, i) = olddecaydiffA + s * (a * a / ((1 + sA * a * a) * (B + sc * C + sf * f)) + ba) - cC * a * D
     a(2, i) = olddecaydiffB + s * a * a + bb'rb in 54
     a(3, i) = olddecaydiffC + rc * a
     ahorm = ahorm + rf * a '------ AD gets hormone input
     IF i = js THEN
     CALL oscillation(4, D, e, olddecaydiffD, olddecaydiffE, ja, js)
     CALL hormone(6, ahorm, ja, js)
     END IF
   NEXT i

CASE 85 '-- Branches versus triangles: antagonistic action of the
     'c-d oscillation
   FOR i = ja TO js:
   drb = (1 - rbb - 2 * DB)
   GOSUB olddecay
      rbb = rB * (1 + cB * D) / (1 + cC * C)' effective inhibitor decay rate
      drb = 1! - 2! * DB - rbb
     aq = s * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq / (sb + se * e + B)
     a(2, i) = B * (1 - rbb - 2 * DB) + DB * (bl + a(2, i + 1)) + aq
     cq = rc * a(8, i) * (C * C + bc)
     a(3, i) = olddecaydiffC + cq / (sd + D)
     a(4, i) = olddecaydiffD + cq
     a(5, i) = olddecaydiffE + re * a
   NEXT i

CASE 86 'three inhibitors (b,e,f) and oscillation - L. hieroglyphica
   FOR i = ja TO js
      C = a(3, i): D = a(4, i)
      rbb = rB * (1 + cB * D + cd * C) / (1 + cC * C)'---- effective Inhibitor
      drb = 1! - 2! * DB - rbb           '     Zerfallsrate
   GOSUB olddecay
     aq = s * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq / (sb + sf * f + se * e + B)
     a(2, i) = B * (1 - rbb - 2 * DB) + DB * (bl + a(2, i + 1)) + aq + bb
     cq = rc * a(8, i) * (C * C + bc)         'c and d - > oscillation
     a(3, i) = olddecaydiffC + cq / (sd + D)  '= A-I system
     a(4, i) = olddecaydiffD + cq
     a(5, i) = olddecaydiffE + re * a
     a(6, i) = olddecaydiffF + rf * a
   NEXT i

CASE 87 'Activator-substrate plus two additional inhibitors
     '=> three inhibitory actions
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * ((a * a + ba) / (1! + sA * a * a)) / (D + sb * C)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb
     a(3, i) = olddecaydiffC + rc * a
     a(4, i) = olddecaydiffD + bd * a
   NEXT i

CASE 92 ' a,b -> pigmentation (AS-system)
     ' c,d -> precondition/background (AI-system)
   FOR i = ja TO js: GOSUB olddecay
     aq = s * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb * C
     cq = rc * a(9, i) * (C * C / (1! + sc * C * C) + bc)
     a(3, i) = olddecaydiffC + cq / (bd + D)
     a(4, i) = olddecaydiffD + cq
   NEXT i

CASE 93 ' a,b -> pigmentation (AS-system)
     ' c,d -> precondition/background (AI-system)
     ' e,f -> Extinguishing system (AS-system)
   FOR i = ja TO js: GOSUB olddecay
     aq = s * C * B * (a * a / (1! + sA * a * a) + ba)
     a(1, i) = olddecaydiffA + aq
     a(2, i) = olddecaydiffB - aq + bb
     cqf = C * C
     cq = rc * a(9, i) * D * (cqf / (1! + sc * cqf) + bc * a)
     a(3, i) = olddecaydiffC + cq - cC * C * e
     a(4, i) = olddecaydiffD - cq + bd
     'extinguishing reaction
     eqf = e ^ 2
     eq = re * f * (eqf / (1! + se * eqf) + be + cE * C)
     a(5, i) = olddecaydiffE + eq
     a(6, i) = olddecaydiffF - eq + bf * C
  NEXT i


' CASE ==========  Other simulations, such as Gene-Activation, Hydra....

CASE 121 'Activation of several genes by a graded morphogen distribution
    'e = Repressor, f = positional information
    'sa, sb, sc.. = Efficiency of the genes in the autokatalyse
    ' a(i,iy)= ra+(1 +- Fluctuations)
    ' cb slope of the gradient
    ' e = a measure for the antagonistic reaction, competition
    ' f = positionnal information
    ' ba absolute influence of the morphogen
   FOR i = ja TO js: GOSUB olddecay' :
    e = sA * a * a + sb * B * B + sc * C * C + sd * D * D
    dq = sd * a(0, 4) * D * D: a(4, i) = olddecaydiffD + (dq + f * a(3, i)) / e
    cq = sc * a(0, 3) * C * C: a(3, i) = olddecaydiffC + (cq + f * a(2, i)) / e
    bq = sb * a(0, 2) * B * B: a(2, i) = olddecaydiffB + (bq + f * a(1, i)) / e
    aq = sA * a(0, 1) * a * a: a(1, i) = olddecaydiffA + aq / e
    a(5, i) = olddecaydiffE + aq + bq + cq + dq
    a(6, i) = ba * a(8, i)
   NEXT i

  CASE 123 'Activation of several genes in a single cell
'  i=Gene Nr., not, as usual, the position
   FOR i = ja TO js: GOSUB olddecay
	aq = a * a / (1! + sA * a * a)
	a(2, i) = a(8, i) * ba
	a(1, i) = olddecaydiffA + s * (aq / C + B)
	ahorm = ahorm + rc * aq
	IF i = js THEN
	a(3, 1) = a(3, 1) * (1! - rc) + ahorm
	FOR iic = ja TO js
	  a(3, iic) = a(3, 1)
	NEXT iic
	ahorm = 0
	END IF
   NEXT i

CASE 124 'Only one gene, with threshold
   FOR i = ja TO js: GOSUB olddecay
	a(1, i) = olddecaydiffA + ra * a * a / (1! + sA * a * a) + B
	a(2, i) = ba * a(8, i) ' Morphogen concentration, for display
   NEXT i

CASE 126 'HY- - Hydra hypostome, tentacles and foot
   FOR i = ja TO js: GOSUB olddecay
	aq = C * s * (a * a + ba)
	a(1, i) = olddecaydiffA + aq / B
	a(2, i) = olddecaydiffB + aq + bb
	'Source
	IF rc > 0 THEN a(3, i) = olddecaydiffC + rc * a + bc - rc * C * f
	dfq = D * D + bd
	dq = C * cd * dfq / (1 + sd * dfq) / (1 + cE * a)
	a(4, i) = olddecaydiffD + dq / e
	a(5, i) = olddecaydiffE + dq + be
	'Foot
	fq = rf * (f * f + bf) / C
	a(6, i) = olddecaydiffF + fq / g
	a(7, i) = olddecaydiffG + fq + bg * C
   NEXT i


CASE 127 ' Activator-inhibitor-system feedback on the source
'   if sc>0: Activator has the influence
'   if cc>0: Inhibitor has the influence, must become slower at higher
'      source density otherwhise numerically instable
   FOR i = ja TO js: GOSUB olddecay
	aq = C * s * (a * a + ba)
	a(1, i) = olddecaydiffA + aq / B
	a(2, i) = olddecaydiffB + aq + bb
	'Source
	a(3, i) = olddecaydiffC + sc * a + cC * B / C + bc
   NEXT i

CASE 128 'A set of each other on long range activating but locally exclusive
' activator-inhibitor-Systems: an alternative way to generate polarity
   FOR i = ja TO js: GOSUB olddecay
       rep = a * a + C * C + e * e + g * g

       a(1, i) = olddecaydiffA + s * (a + ba * C) ^ 2 / B / rep
       a(2, i) = olddecaydiffB + rB * a * a

       a(3, i) = olddecaydiffC + a(9, i) * rc * (C + ba * (a + e)) ^ 2 / D / rep
       a(4, i) = olddecaydiffD + rd * C ^ 2

       a(5, i) = olddecaydiffE + a(9, i + js) * re * (e + ba * (C + g)) ^ 2 / f / rep
       a(6, i) = olddecaydiffF + rf * e ^ 2

       a(7, i) = olddecaydiffG + a(9, 2 * i) * rg * (g + ba * e) ^ 2 / zh / rep
       a(8, i) = olddecaydiffH + rH * (g + ba * e) ^ 2
NEXT i

CASE 131 'Growth cone-- two antagonists
'  b=uniformely distributed inhibitor s'=s/(sc+c)
   FOR i = ja TO js: GOSUB olddecay:
   a(1, i) = olddecaydiffA + s / (sc + C) * (a * a / B + ba) / (1! + sA * a * a)
   a(3, i) = olddecaydiffC + bc * a
   a(4, i) = s
   ahorm = ahorm + s / (sc + C) * a * a + bb
   IF i = js THEN CALL hormone(2, ahorm, ja, js)
   NEXT i

CASE 132 'for chemotactic orientation, AI system
' B is inhibitor is uniformly distributed within the cell
   FOR i = ja TO js: GOSUB olddecay:
   a(1, i) = olddecaydiffA + s * (a * a / B + ba) / (1! + sA * a * a)
   ahorm = ahorm + s * a * a + bb
	IF i = js THEN CALL hormone(2, ahorm, ja, js)
   a(3, i) = s
   NEXT i



 '-------------- End of equations ---------------------------------------------
CASE ELSE: GOTO nosuchequation
 END SELECT
   NEXT iprint
   itot& = itot& + KP
  icountot = icountot + 1
  IF K3 > 0 AND icountk3 = K3 THEN  'Possible change of parameters during calculation
    SELECT CASE K4'  K3: Number of printouts after which the change occurs
    CASE 0
    CASE 1'  K4 Type of change,  DZ new parameter
      mess$ = "Basic activator production ba changed from" + STR$(ba) + " to" + STR$(DZ)
      ba = DZ
    CASE 2
      mess$ = "decay rate of b (inhibitor of substrate) changed from" + STR$(rB) + " to" + STR$(DZ)
      rB = DZ: drb = 1! - rB - 2! * DB
    CASE 3
      mess$ = "bb = basic inhibitor/substrate production changed from" + STR$(bb) + " to" + STR$(DZ)
      bb = DZ
    CASE 4
      mess$ = "decay rate of the activator a changed from" + STR$(ra) + " to" + STR$(DZ)
      ra = DZ: dra = 1! - ra - 2! * DA
    CASE 5
      mess$ = "Activator concentration will be modified in a fraction of the field"
      istart = ja: istop = js
      CALL zeingabe(igt, 1, 1, istart, dummy, dummy$, "Perturbation starts at cell")
      CALL zeingabe(igt, 1, 1, istop, dummy, dummy$, "Perturbation stops at cell")
      IF istart < ja THEN istart = ja
      IF istop = 0 OR istop > js THEN istop = js
      CALL zeingabe(igt, 0, 2, istop, factor, dummy$, "modifying factor, 1= unchanged")
      FOR i = istart TO istop
      a(1, i) = factor * a(1, i): NEXT i
      mess$ = ""
    CASE 6
      FOR ix = 1 TO js: a(1, ix) = a(1, ix) * DZ: NEXT
      mess$ = "the activator concentration modified via dz by a factor " + STR$(DZ)
    CASE 7
      mess$ = "production and decay rate of C changed from" + STR$(rc) + " to" + STR$(DZ)
      rc = DZ: drc = 1! - rc - 2! * DC
    CASE 8
      mess$ = "saturation (sa) of the activator a changed from" + STR$(sA) + " to" + STR$(DZ)
      sA = DZ
    CASE 9
      mess$ = "CB changed from" + STR$(cB) + " to" + STR$(DZ)
      cB = DZ
    CASE 10
      mess$ = "concentration of an array to be selected can be changed"
      CALL manipulationxt("A", ja, js, kinsert, imxl, imxl2, icc)
    CASE 11
      mess$ = "Diffusion rate of activator and inhibitor is set to zero"
      DA = 0: DB = 0: dra = 1 - ra: drb = 1 - rB
    CASE 12
      mess$ = "array C is set to DZ between ja+10 and js-10"
      FOR i = ja + 10 TO js - 10: a(3, i) = DZ: NEXT i
    CASE 13
      mess$ = "DW=(displaywhat) is set to a => only the a distribution is shown"
      displaywas$ = "a"
    CASE 14
      mess$ = "Influx to the pool (be) changed from" + STR$(be) + " to " + STR$(DZ)
      be = DZ
    CASE 15
      mess$ = "array A is set to DZ = " + STR$(DZ) + "between ja+10 and js-10"
      FOR i = ja + 10 TO js - 10: a(1, i) = DZ: NEXT i
   CASE 16 'Exponential gradient or bzw sinusoidal distribution of the source
    mess$ = ""
    IF dy > 0 THEN
	    ' density (for chemotactic reorientation)
    mess$ = "Orientation of the gradient will be changed"
    k2 = k2 + ky / 4 + RND * ky / 3: IF k2 > ky THEN k2 = k2 - ky
    icountk3 = 0
    inv(12) = k2
    FOR ix = 1 TO ky:
    a(0, ix) = ra * (1! + 2 * KR / 100 * (RND - .5)) 'new Source density
    a(0, ix) = a(0, ix) * EXP(-aB * (ix - 1)) * (1! + dy * (COS((ix - k2) * 3.14 / (ky))) ^ 2)
    NEXT ix
    END IF
    CASE ELSE
     mess$ = "No such modification is implemented, K4 must be 1... 15"
    CALL gtreturn(0, 0)
    END SELECT
    IF mess$ > "" AND igraph <> 9 THEN CALL cmessage(7, -1, 1, 15, 2, ibackcol, mess$, "OK")
  END IF
    GOTO simulation

   '------------------------- END OF LOOP 1 ----------------------------

nosuchequation:
    mess$ = "no equation of this type (KE) is available"
    CALL switchscreen(3, iactive, ibackcol)
    CALL cmessage(4, -1, 1, 15, 4, ibackcol, mess$, "OK")
    GOTO parameter


EndSimulation:
  CALL showprof(KD, 99, displaywas$, a(), ja, js, icc)
  IF igraph = 9 THEN CALL switchscreen(3, iactive, ibackcol)
  iparam = 2: ipcontrol = 0
  GOTO parameter

erroverflow:
mess$ = "Error, presumable an overflow, num. instability, zero-division"
resp$ = "ok": CALL cmessage(4, -1, 1, 15, 4, 0, mess$, resp$)
RESUME parameter


CASE "M"
  CALL manipulationxt(pcontrol2$, ja, js, kinsert, imyl, imxl2, icc)
  IF igraph = 9 THEN CALL switchscreen(3, iactive, ibackcol)
  ipcontrol = 0

END SELECT
GOTO parameter


olddecay:
      a = a(1, i): B = a(2, i): s = a(0, i):
      olddecaydiffA = dra * a + DA * (al + a(1, i + 1)): al = a
      olddecaydiffB = drb * B + DB * (bl + a(2, i + 1)): bl = B
       IF KN > 2 THEN
	C = a(3, i): D = a(4, i):
	olddecaydiffC = drc * C + DC * (cl + a(3, i + 1)): cl = C
	olddecaydiffD = drd * D + DD * (dl + a(4, i + 1)): dl = D
	IF KN > 4 THEN
	  e = a(5, i): f = a(6, i): g = a(7, i):
	  olddecaydiffE = dre * e + DE * (el + a(5, i + 1)): el = e
	  olddecaydiffF = drf * f + DF * (fl + a(6, i + 1)): fl = f
	  olddecaydiffG = drg * g + DG * (gl + a(7, i + 1)): gl = g
	  IF KN > 7 THEN
	  zh = a(8, i):
	  olddecaydiffH = drh * zh + DH * (zhl + a(8, i + 1)): zhl = zh
	END IF
	END IF
      END IF
RETURN

END  '==================  End of Main-program  ==========

SUB hormone (ila, ahorm, ja, js)
SHARED a(), flv()
rx = flv(7 * ila - 2)
       a(ila, 1) = a(ila, 1) * (1! - rx) + ahorm / (js - ja + 1)
       FOR iic = ja TO js
	 a(ila, iic) = a(ila, 1)
       NEXT iic
       ahorm = 0
  EXIT SUB
END SUB

SUB oscillation (ila, C, D, olddecaydiffC, olddecaydiffD, ja, js)
SHARED a(), flv()
     ila7 = 7 * ila
     cqf = C * C
     cq = flv(ila7 - 2) * D * (cqf / (1! + flv(ila7) * cqf) + flv(ila7 - 1))
     C = olddecaydiffC + cq
     D = olddecaydiffD - cq + flv(ila7 + 6)
     FOR jic = 1 TO js
     a(ila, jic) = C
     a(ila + 1, jic) = D
     NEXT jic
  EXIT SUB
END SUB

