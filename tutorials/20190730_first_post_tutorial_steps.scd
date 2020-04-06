s.boot;
{SinOsc.kr(1/0.1, -pi/2, 0.5, 0.5)}.plot(0.2);
{SinOsc.ar(SinOsc.kr(1/0.1, -pi/2, 0.5, 0.5)*440+440)}.plot(0.2);
(
    SynthDef(\wahp, { |out, freq=440, amp=0.2, gate = 1, dur=0.1|
        var signal,
        env = Env.adsr(0.1,0.1,0.1,0.1);
        signal = Mix(
            VarSaw.ar(SinOsc.kr(1/dur, -pi/2, 0.5, 0.5)*freq+freq)
            /* SinOsc.ar(freq) */
            * EnvGen.kr(env, gate, doneAction: Done.freeSelf) * amp);
        Out.ar(out, signal ! 2);
    }).add;
    (\instrument: \wahp, \midinote: 72, \dur: 0.2).play;
)

(
    SynthDef(\bass, { |out, freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15, detune = 1.005, preamp = 4|
        var    sig,
        env = Env.adsr(0.01, 0.3, 0.4, 0.1);
        freq = Lag.kr(freq, slideTime);
        sig = Mix(SinOsc.ar([freq, freq * detune])).distort * amp
        * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
        sig = LPF.ar(sig, ffreq);
        Out.ar(out, sig ! 2)
    }).add;
)


(
    p = Pbind(
        \instrument, \wahp,
        [\midinote, \dur], Pseq([[76,0.2],[37,0.25],[38,0.3],[39,0.4],[40,0.5]], 1),
    ).play;
)
p.stop;

(
    var notes, on, off;
    MIDIClient.init;
    MIDIIn.connectAll;

    notes = Array.newClear(128);
    on = MIDIFunc.noteOn({ |veloc, num, chan, src|
        notes[num] = Synth(\default, [\freq, num.midicps,
            \amp, veloc * 0.00315]);
        });

    off = MIDIFunc.noteOff({ |velo, num, chan, src|
        notes[num].release;
    });

    q = { on.free; off.free; };
)

q.value;

