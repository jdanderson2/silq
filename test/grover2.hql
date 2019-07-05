def round(x:!R) lifted :!N;
def sqrt(x:!R) lifted :!R;

def groverDiffusion[n:!N](cand:uint[n]) mfree: uint[n] {
	for k in [0..n) { cand[k] := H(cand[k]); }
	if cand!=0 {
		phase(π);
	}
	for k in [0..n) { cand[k] := H(cand[k]); }
	return cand;
}

def grover[n:!N](f:!(const uint[n] -> lifted B)):!N{
	nIterations:= round(π / 4 * sqrt(2^n));
	cand:=0:uint[n];
    for k in [0..n) { cand[k] := H(cand[k]); }

	for k in [0..nIterations){
        b := f(cand);
		if b {
			phase(π);
		}
		forget(b = f(cand));
		cand:=groverDiffusion(cand);
	}
	return measure(cand) as !N;
}
