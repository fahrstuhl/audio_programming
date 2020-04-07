s.boot;
(
Server.default.record;
// trying to replicate the bass from https://music.tutsplus.com/tutorials/programming-essential-subtractive-synth-patches--audio-8962
SynthDef(\bass, { |out, freq = 440, gate = 1, amp = 0.1|
    var wv1, wv2, filter, env, sig;

    env = Env.adsr(0.0, 1.0, 0.0, 0.1);
    wv1 = LFSaw.ar(freq);
    wv2 = LFSaw.ar(freq*0.99);
    filter = RLPF.ar(Mix([wv1,wv2]), freq*2, 1);
    sig = filter * amp * EnvGen.kr(env, gate, doneAction: Done.freeSelf); 

    Out.ar(out, sig ! 2)
}).add;

p = Pbind(
    \instrument, \bass,
    \midinote, Pseq([40,35,30,25,20], 1),
    \dur, 0.5,
    \legato, 0.7,
    \amp, 0.7
).play(quant: 1);
)

Server.default.stopRecording;

(
    var notes, on, off;
    MIDIClient.init;
    MIDIIn.connectAll;

    notes = Array.newClear(128);

    on = MIDIFunc.noteOn({ |veloc, num, chan, src|
        notes[num] = Synth(\bass, [\freq, num.midicps, \amp, veloc * 0.05]);
    });

    off = MIDIFunc.noteOff({ |veloc, num, chan, src|
        notes[num].release;
    });

    q = {on.free; off.free;};
)
q.value;

