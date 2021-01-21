s.boot;

// https://m.youtube.com/watch?v=Vc-RWrWxaCw
// Berlioz original: C1, G1, C2 = 24, 31, 36
// Berlioz comment, MIM Phoenix: C0, G0, D1 = 12, 19, 26
// Montreal Symphony Orchestra: A0, E1, B1 = 21, 28, 35

// bowed string synth according to https://www.soundonsound.com/techniques/practical-bowed-string-synthesis
// 
Server.default.record;
(
    SynthDef(\octobass, { | out, freq = 440, gate = 1, amp = 0.1 |

    var saw, sig, env, lpf, bank, hpf;

    env = Env.adsr(1.5, 0, 10, 1);
    saw = Saw.ar(freq);
    lpf = LPF.ar(saw, 100);
    bank = Klank.ar(`[[12, 60, 65, 100], nil, [0.1,0.5,1,1]], lpf); // lowered eigenmodes of double bass from: http://www.speech.kth.se/prod/publications/files/qpsr/1982/1982_23_4_149-174.pdf
    hpf = HPF.ar(bank, 1000);
    sig = hpf * amp * EnvGen.kr(env, gate, doneAction: Done.freeSelf); 

    Out.ar(out, sig ! 2)

    }).add;

    p = Pbind(
        \instrument, \octobass,
        \midinote, Pseq([440.cpsmidi, 24,31,36, 12,19,26, 21,28,35,42], 1),
        \dur, 1,
        \legato, 0.9,
        \amp, 1
    ).play(quant: 1);
)

Server.default.stopRecording;
