<CsoundSynthesizer>
<CsOptions>
-+rtmidi=alsa -M hw:0,0 -+rtaudio=alsa -o dac
</CsOptions>
; ==============================================
<CsInstruments>

sr	=	48000
ksmps	=	1
;nchnls	=	2
0dbfs	=	0.25

massign(0,"synth_bass")

instr stolen_casio	
; https://schollz.com/blog/phasedistortion/
; does not work very well
    aPi = $M_PI
    kPi = $M_PI
    iAmp = ampmidi(0dbfs)
    kFreqBase = cpsmidib(2)
    kFreqRes = scale2(poscil:k(iAmp, random(0, 0.2)), kFreqBase/2, kFreqBase*2)
    kPdbase = mpulse:a(0dbfs,kFreqBase)
    kPd = trigphasor:k(kPdbase, 2*kPi*kFreqBase/sr, 0, 2*kPi)
    kPdres = trigphasor:k(kPdbase, 2*kPi*kFreqRes/sr, 0, 2*kPi)
    kPdi = scale2:k(2*kPi-kPd, 0, 1, 0, 2*kPi)
    aSnd = lag:k(poscil:k(iAmp, kPdres)*kPdi, 1/kFreqBase)
    aEnv = expon(1, 0.1, 0.5)
        out aSnd*aEnv
    /* display(aPd, 0.11) */
    /* display(aPdres, 0.11) */
    /* display(aSin, 0.9) */
    /* display(aPdi, 0.11) */

endin

instr synth_bass
; trying to replicate the bass from https://music.tutsplus.com/tutorials/programming-essential-subtractive-synth-patches--audio-8962
    iAmp = ampmidi(0dbfs)
    kFreq = cpsmidib(2)
    aEnv = madsr(0.001, 0.001, 0.8, 0.2)
    aWv1 = vco2:a(iAmp, kFreq*0.999, 0)
    aWv2 = vco2:a(iAmp, kFreq*1.001, 0)
    aWv3 = lfo:a(iAmp, sqrt(kFreq), 0)
    aMix = aWv1 + aWv2 + aWv3
    aFilter = lowpass2:a(aMix, kFreq*10, 1)
        out aFilter * aEnv * iAmp
endin

opcode LinVals,i,iiii
    iFirst, iLast, iNumSteps, iThisStep xin
    xout iFirst - (iFirst - iLast) / iNumSteps*iThisStep
endop

instr 1
    iCnt, iStart init 0
    until iCnt > 10 do
        iOct = LinVals(9, 8, 10, iCnt)
        schedule(2, iStart, 1, iOct)
        iCnt += 1
        iStart += LinVals(1/4, 1, 10, iCnt+0.5)
    od
    if (iCnt == 11) then
        schedule(4, iStart, 1)
    endif
endin

instr 2 
    aOut=mode(mpulse(0dbfs, p3), cpsoct(p4), random:i(50, 100))
    out aOut
endin

instr 4
    exitnow
endin

/* schedule(1, 0, 0) */

instr 5
    kcps cpsmidib 2
    iamp ampmidi 0dbfs
    kcf midictrl 1,2,5
    out linenr(
        moogladder(
            vco2(iamp, kcps, 10),
            kcf*(kcps + linenr(kcps, 0.1, 0.1, 0.01)),
            0.7),
        0.01,0.1,0.01)
endin
</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>

