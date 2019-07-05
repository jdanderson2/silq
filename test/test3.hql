// TODO: add lifted annotation

// Node := Int(bits=n)
// Node := 𝔹;
// // TODO: edgeOracle lifted?
//edgeOracle_spec := !((const Node x const Node x 𝔹) -> 𝔹);
// edgeOracle_spec := !((const int x const int x 𝔹) -> 𝔹);
// QWTFP_spec := !int x !int x edgeOracle_spec;
// GCQWRegs := Int[] x Int x Int x 𝔹[] x Int x 𝔹;


//def a1(oracle:QWTFP_spec) : !𝔹 x !Node x !Int[n]^rr x !𝔹[][] {
def a1[n:!N](
	const edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹),
	const r:!N) {
	// n, r, edgeOracle = oracle;

	// nn := 2^n; not used 
	rr := 2^r;
	// rbar := max([2*r / 3, 1]); not used
	// rrbar := 2^rbar; 
	tm := 2^(n-r);
	// tw := floor(sqrt(rr));
	tw := floor(sqrt(2^r));

	testTEdge := false:𝔹;

	// tt := a4_HADAMARD_Array_Int(vector(rr,0:int[n])); // a4_HADAMARD( array(rr,0:Int[n]) );
	// i := a4_HADAMARD_Array(0:Int[r]);
	tt := a4_HADAMARD_Array_Int(vector(2^r,0:int[n])); // a4_HADAMARD( array(rr,0:Int[n]) );
	i := a4_HADAMARD_Int(0:int[r]);
	//v := a4_HADAMARD_Array(vector(n,false:B));
	v := a4_HADAMARD_Int(0:int[n]);

	ee := a5_SETUP(edgeOracle, tt);

	for _ in [0..tm) {
		(w, triTestT, triTestTw) := a15_TestTriangleEdges(edgeOracle, tt, ee);
		if !(triTestT == 0 && triTestTw == 0) { 
			phase(π); 
		}
		reverse(a15_TestTriangleEdges[n, 2^r])(w, triTestT, triTestTw, edgeOracle, tt, ee);

		for _ in [0..tw) {
			(tt, i, v, ee) := a6_QWSH(edgeOracle, tt, i, v, ee)
		}	
	}

	//triTestT gets set to true, if triangle found within tt
	//triTestTw gets set to true, if a pair of nodes formes a 
	//triangle with a node from w
	(w, triTestT, triTestTw) := a15_TestTriangleEdges(edgeOracle, tt, ee);

	// ToDo: rewrite this here to qor(testTEdge, [triTestT, triTestTw], [True, True])
	// Todo: high-level should have testTEdge as a return only

	//testTEdge := qor(testTEdge, [(triTestT, true), (triTestTw, true)]);
	testTEdge := X(testTEdge);
	if (triTestT == true && triTestTw == true) { testTEdge := X(testTEdge); }

	// testTMeasure := measure(testTEdge);
  	// wMeasure := measure(w); //wMeasure contains a node of the triangle
  	// ttMeasure := measure(tt); //other two nodes in TMeasure
  	// eeMeasure := measure(ee);
	measure((i,v,triTestT,triTestTw));

  	return measure((testTEdge, w, tt, ee));
}

// // ToDo: discuss this. maybe introduction of read only references. 
// def allEqual[k:!N](const cs: (𝔹, !𝔹)^k) : 𝔹 {
// 	cs0 = [];
// 	cs1 = [];
// 	for l in [0..k) {
// 		cs0~cs[k][0];
// 		cs1~cs[k][1];
// 	}
// 	return cs0 == cs1;
// }

// can be made lifted
// def qor[k:!N](q: 𝔹, const cs: (𝔹, !𝔹)^k) : 𝔹 {
// 	q := !q;
// 	if allEqual(cs) { q := !q; }
// 	return q;
// }


// // Currently not needed
// // in current impl not used
// // def a2_ZERO(b:classical Int) : Int {
// // 	q := b:Int[];
// // 	return q;
// // }

// // in current impl not used
// // def a3_INITIALIZE(reg:classical Int) : Int {
// // 	zreg := a2_Zero(reg);
// // 	hzreg := a4_Hadamard(zreg);
// // 	return hzreg;
// // }

def a4_HADAMARD_Array[k:!N](q:𝔹^k) mfree: 𝔹^k {
	for j in [0..k) { q[j] := H(q[j]); }
	return q;
}

def a4_HADAMARD_Int[k:!N](q:int[k]) mfree {
	// for j in [0..k) { q[j] := H(q[j]); }
	// return q;
	return a4_HADAMARD_Array(q as 𝔹^k) as int[k];
}

// def a4_Hadamard_Int2[rr:!N](q:int[log_int(2,rr)]) mfree {
// 	for j in [0..log_int(2,rr)) { q[j] := H(q[j]); }
// 	return q;
// }

// maybe not needed
def a4_HADAMARD_Array_Array[k:!N,l:!N](q:(𝔹^k)^l) mfree: (𝔹^k)^l {
	for i in [0..l) {
		q[i] := a4_HADAMARD_Array(q[i]);
	}
	return q;
}

def a4_HADAMARD_Array_Int[k:!N,l:!N](q:int[k]^l) mfree {
	// for i in [0..l) {
	// 	q[i] := a4_HADAMARD_Int(q[i]);
	// }
	// return q;
	return a4_HADAMARD_Array_Array(q as (B^k)^l) as int[k]^l;
}

// //def a5_SETUP(oracle:!QWTFP_spec, tt:const Node[]) : 𝔹[][] {
def a5_SETUP[n:!N, rr:!N](edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹), 
	const tt:int[n]^rr) mfree: (𝔹^rr)^rr {

	ee := vector(rr,vector(rr,false)):(B^rr)^rr;

	for k in [0..rr) {
		for j in [0..k) {
			ee[k][j] := edgeOracle(tt[j], tt[k], ee[k][j]);
	}	}

	return ee;
}

// // TODO: make high level, ttd, eed allocated in f. 
//TODO: CHANGE ORDER FOR F (-> REVERSE)
// def a6_QWSH(oracle:!QWTFP_spec, tt: Node[], 
// 	i: int, v: Node, ee: 𝔹[][]) : Node[] x int x v x 𝔹[][] {
def a6_QWSH[n:!N, r:!N](
	const edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹), 
	tt:int[n]^(2^r), 
	i:int[r], 
	v:int[n], 
	ee:(𝔹^(2^r))^(2^r) ) mfree //: int[n]^rr x int[r] x int[n] x (𝔹^(2^r))^(2^r) 
	{

	//todo check if capturing here is enough
	// tt:Node[]
	f := lambda (const i: int[r], tt:int[n]^(2^r), ee:(𝔹^(2^r))^(2^r)) mfree . {
		eed := vector(2^r, false):𝔹^(2^r);
		ttd := tt[i]; 									//qram_fetch_Array(i, tt);
		(ee, eed) := a12_FetchStoreE(i, ee, eed);
		eed := a13_UPDATE(edgeOracle, tt, ttd, eed);
		tt := a9_StoreT_Array(i, tt, ttd); //tt = qram_store_Array(i, tt, ttd); // tt[i] := ttd;
		return (ttd, ee, eed, tt);
	};
	
	(i, v) := a7_Diffuse_Pair(i, v);
	(ttd,ee,eed,tt) := f(i,tt,ee);
	(ttd, v) := (v, ttd);
	(tt,ee) := reverse(f)(i,ttd,ee,eed,tt);

	return (tt, i, v, ee);
}


def a7_Diffuse_Array[k:!N](q:𝔹^k) mfree: 𝔹^k {
	q := a4_HADAMARD_Array(q);
	if q == array(k,false) { phase(π); }
	q := a4_HADAMARD_Array(q);
	return q;
}

def a7_Diffuse_Int[k:!N](q:int[k]) mfree: int[k] {
	// q := a4_HADAMARD_Int(q);
	// if q == 0 { phase(π); }
	// q := a4_HADAMARD_Int(q);
	// return q;
	return a7_Diffuse_Array(q as 𝔹^k) as int[k];
}

def a7_Diffuse_Array_Array[k:!N,l:!N](q:(𝔹^k)^l) mfree: (𝔹^k)^l {
	q := a4_HADAMARD_Array_Array(q);
	if q == array(l,array(k,false)) { phase(π); }
	q := a4_HADAMARD_Array_Array(q);
	return q;
}

def a7_Diffuse_Pair[k:!N, l:!N](p:int[k], q:int[l]) mfree: int[k] x int[l] {
	p := a4_HADAMARD_Array(p as B^k) as int[k];
	q := a4_HADAMARD_Array(q as B^l) as int[l];
	if q == 0 && p==0 { phase(π); }
	p := a4_HADAMARD_Array(p as B^k) as int[k];
	q := a4_HADAMARD_Array(q as B^l) as int[l];
	return (p,q);
}


def flipWith_Array[l:!N](const p:𝔹^l, q:𝔹^l) mfree : 𝔹^l {
	for i in[0..l) {
		if p[i] { q[i] := X(q[i]); }
	}
	return q;
}

// // Currently not needed
// // def flipWith_Array_Array[k:!Int,l:!Int](p:!Bool^l^k, q:consumed Bool^l^k) {
// // 	for j in [0,k) {
// // 		q[j] := flipWith_Array(p[j], q[j]);
// // 	}
// // 	return q;
// // }

// // questions to original Code, ttj?
def a8_FetchT[n:!N, rr:!N, r:!N](const i:int[r], const tt:𝔹^rr) :  𝔹 {
	ttd := false:B;
	for j in [0..rr) {
		if tt[j] && i == j {
			ttd_ := !ttd;
			forget(ttd = !ttd_);
			ttd := ttd_;
	}	}	
	return ttd;
}

// todo: realize as lifted:
// def a8_FetchT_Array[k:!Int, l:!Int](i:const Int[k], tt:const Node[l][]) lifted : Node[l] {
def a8_FetchT_Array[n:!N, rr:!N, r:!N](const i:int[r], const tt:int[n]^rr) : int[n] {
	ttd := 0:int[n];
	for j in [0..rr) {
		if i == j {
			ttd := flipWith_Array(tt[j] as B^n, ttd as B^n) as int[n];
	}	}	
	return ttd;
}

// // Currently not needed
// // def a9_StoreT[k:!Int](i:Int[k], tt: consumed 𝔹[], ttd:𝔹) : 𝔹[] {
// // 	for j in [0, 2^k) {
// // 		if ttd && i == j {
// // 			tt[j] := !tt[j];
// // 	}	}
// // 	return tt;
// // }

// // todo same as for a8_FetchT
// def a9_StoreT_Array[k:!Int](i:const Int[k], tt: Node[], ttd:const Node) : Node[] {
def a9_StoreT_Array[n:!N, rr:!N, r:!N](const i:int[r], tt: int[n]^rr, const ttd:int[n]) 
	mfree : int[n]^rr {
	for j in [0..rr) {
		if i==j {
			tt[j] := flipWith_Array(ttd as B^n, tt[j] as B^n) as int[n];
	}	}
	return tt;
}

// def a10_FetchStoreT[k:!Int](i:const Int[k], tt:𝔹[], ttd:𝔹) : 𝔹[] x 𝔹 {
def a10_FetchStoreT[rr:!N, r:!N](const i:int[r], tt:B^rr, ttd:𝔹) mfree : 𝔹^rr x 𝔹 {
	for j in [0..rr) {
		if i == j {
			(tt[j], ttd) := (ttd, tt[j]);
		}
	}
	return (tt, ttd);
}

// todo: check if ok!
def a11_FetchE[rr:!N,r:!N](const i:int[r], const qs:(𝔹^rr)^rr) lifted : 𝔹^rr {
    ps := vector(rr,false:𝔹);
    for j in [0..rr) {
        for k in [0..j) {
            if qs[j][k] && i == j { ps[k] := X(ps[k]); }
            if qs[j][k] && i == k { ps[j] := X(ps[j]); }
    }    }
    return ps;
}


def a12_FetchStoreE[rr:!N,r:!N](const i:int[r], qs: (𝔹^rr)^rr, ps: 𝔹^rr) mfree : (𝔹^rr)^rr x 𝔹^rr {

	for j in [0..rr) {
		for l in [0..j) {
			if i == j { (qs[j][l], ps[l]) := (ps[l], qs[j][l]); }
			if i == l { (qs[j][l], ps[j]) := (ps[j], qs[j][l]); }
		}
	}
	return (qs, ps);
}


// def a13_UPDATE(oracle:!QWTFP_spec, tt:const Node[], ttd:const Node, eed:𝔹[]) : 𝔹[] {
def a13_UPDATE[n:!N, rr:!N](edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹), 
	const tt:int[n]^rr, const ttd:int[n], eed:𝔹^rr) mfree : 𝔹^rr {

	//n, r, edgeOracle := oracle;
	for j in [0..rr) {
		eed[j] := edgeOracle(tt[j], ttd, eed[j]);
	}
	return eed;
}

// // Currently not needed. 
// // def a14_SWAP[k:!Int](q: consumed Int[k], p: consumed Int[k]) : Int x Int {
// // 	for j in [0, m) {
// // 		p[j], q[j] = q[j], p[j]; //Swap(p[j], q[j]);
// // 	}
// // 	return q, p;
// // }

// // standard_qram :: Qram
// // standard_qram = Qram {
// //   qram_fetch = a8_FetchT,
// //   qram_store = a9_StoreT,
// //   qram_swap = a10_FetchStoreT
// // }

//def a15_TestTriangleEdges(oracle:!QWTFP_spec, tt:const Node[], ee:const 𝔹[][]) : Node x 𝔹 x 𝔹 {
def a15_TestTriangleEdges[n:!N, rr:!N](
	const edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹),
	const tt:int[n]^rr,
	const ee:(𝔹^rr)^rr) mfree {

	triTestT := a16_TriangleTestT(ee);
	w := a18_TriangleEdgeSearch(edgeOracle, tt, ee, triTestT);
	triTestTw := a17_TriangleTestTw(edgeOracle, tt, ee, w);

	return (w, triTestT, triTestTw);
}

def choose(n:!N, k:!N) lifted : !N;
def logBase(n:!N, a:!N) lifted : !R;
def ceiling(r:!R) lifted : !N;
def floor(r:!R) lifted : !N;
def sqrt(r:!R) lifted : !R;
def max(r:!R[]) lifted : !R;
def log_int(n:!N, a:!N) lifted : !N;

// // Todo: implement choose
def a16_TriangleTestT[rr:!N](const ee:(𝔹^rr)^rr) mfree {
	
	// m := ceiling(logBase(2,choose(rr, 3)));

	f := lambda (const ee:(𝔹^rr)^rr) mfree . {
		//cTri := 0:int[m];
		cTri := 0:int[ceiling(logBase(2,choose(rr, 3)))];
		for i in [0..rr) {
			for j in [i+1..rr) {
				for k in [j+1..rr){
					if ee[j][i] && ee[k][i] && ee[k][j] {
						cTri += 1;
		}	}	}	}
		return cTri;
	};

	cTri := f(ee);
	triTestT := true:𝔹;
	if cTri == 0 { triTestT := X(triTestT); }
	reverse(f)(cTri, ee);
	return triTestT;
}



// // 
// def a17_TriangleTestTw(oralce:!QWTFP_spec, tt:const Node[], ee:const 𝔹[][], w:const Node) lifted : 𝔹 {
def a17_TriangleTestTw[n:!N, rr:!N](edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹),
	const tt:int[n]^rr, const ee:(𝔹^rr)^rr, const w:int[n]) mfree {

	//rr = ee.length;
	//m := ceiling(logBase(2,choose(rr,2)));

	f := lambda(const tt:int[n]^rr, const ee:(𝔹^rr)^rr, const w:int[n]) mfree. {
		eed := vector(rr,false):B^rr;
		for k in [0..rr) {
			eed[k] := edgeOracle(tt[k], w, eed[k]);
		}

		//cTri := 0:int[m];
		cTri := 0:int[ceiling(logBase(2,choose(rr,2)))]; 

		for i in [0..rr) {
			for j in [i+1..rr) {
				if ee[j][i] && eed[i] && eed[j] {
					cTri += 1;
		}	}	}
		return (eed, cTri);
	};

	(eed, cTri) := f(tt, ee, w);

	triTestTW := true:B;
	if cTri == 0 { triTestTW := X(triTestTW); }

	reverse(f)(eed,cTri,tt,ee,w);

	return triTestTW;
}

// TODO: why does this compile?
// //CHECK for Consumed and so on
// def a18_TriangleEdgeSearch(oracle:!QWTFP_spec, tt:const Node[], ee:const 𝔹[][], triTestT:const 𝔹) : Node {
def a18_TriangleEdgeSearch[n:!N, rr:!N](
	const edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹),
	const tt: int[n]^rr, 
	const ee: (𝔹^rr)^rr, 
	const triTestT:𝔹) mfree {
	
	// n, r, edgeOracle := oracle;
	tG := floor(π/4 * sqrt(2^n));

	w := 0:int[n]; //array(n,False);//0:Node[n];
	w := a4_HADAMARD_Int(w);

	for _ in [0..tG) {
		cTri := a19_GCQWalk(edgeOracle, tt, ee, w, triTestT);

		if triTestT == 0 && !(cTri == false) { phase(π); }

		reverse(a19_GCQWalk[n, rr])(cTri, edgeOracle, tt, ee, w, triTestT);
		w := a7_Diffuse_Int(w);
	}
	return w;
}


// // triTestT needs to be consumed
// // or break up the tuple structure -> maybe even lifted
// def a19_GCQWalk(oracle:!QWTFP_spec, tt:const Node[], ee:const 𝔹[][], 
// 	w:const Node, triTestT:const 𝔹) : Int {
def a19_GCQWalk[n:!N, rr:!N](
	//oracle:!QWTFP_spec, 
	const edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹),
	const tt: int[n]^rr, 
	const ee: (𝔹^rr)^rr, 
	const w: int[n], 
	const triTestT: 𝔹) mfree {

	r := log_int(2,rr);
	rbar := floor(max([2 * r / 3, 1]));  
	// rrbar := 2^(floor(max([2*r/3,1])));
	rrbar := floor(2^rbar); // here actually integer
	tbarm := max([rr / rrbar, 1]);
	tbarw := floor(sqrt(2^(rrbar)));

	cTri := 0:int[2^(floor(max([2*log_int(2,rr)/3,1])))];
	tau := vector(2^(floor(max([2*log_int(2,rr)/3,1]))),0:int[r]);
	iota := 0:int[rbar];
	sigma := 0:int[r];
	eew := vector(2^(floor(max([2*log_int(2,rr)/3,1]))),false:𝔹);

	for k in [ 0..rrbar ) {
		tau[k] := a4_HADAMARD_Int(tau[k]);
	}
	iota := a4_HADAMARD_Int(iota);
	sigma := a4_HADAMARD_Int(sigma);

	// for j in [0..eew.length) {
	for j in [ 0..rrbar ) {
		eew[j] := edgeOracle(tt[tau[j]], w, eew[j])
	}

	for j in [ 0..rrbar ) {
		for k in [ j+1..rrbar ) {
			if ee[tau[j]][tau[k]] && eew[j] && eew[k] {
				cTri += 1;
	}	}	}

	for _ in [0..tbarm) {
		if triTestT == 0 && !(cTri == 0) { phase(π); }
		//gcqwRegs := (tau, iota, sigma, eew, cTri, triTestT);
		for _ in [0..tbarw) {
			// gcqwRegs := a20_GCQWStep(tt, ee, w, gcqwRegs);
			(tau, iota, sigma, eew, cTri) := a20_GCQWStep[n,r,rbar,2^(floor(max([2*log_int(2,rr)/3,1]))),rr](edgeOracle, tt, ee, w, tau, iota, sigma, eew, cTri);
		}
	}
	// // Why is this forget here valid? deleted in with the reverse in a18?
	forget( tau = vector(2^(floor(max([2*log_int(2,rr)/3,1]))),0:int[r]) );
	forget( iota = (0:int[rbar]) );
	forget( sigma = (0:int[r]) );
	forget( eew = vector(2^(floor(max([2*log_int(2,rr)/3,1]))),false:𝔹) );

	return cTri;
}


// def a20_GCQWStep(oracle:!QWTFP_spec, tt:const Node[], ee:const 𝔹[][], w:const Node, 
// 	gcqwRegs:GCQWRegs) : GCQWRegs {
def a20_GCQWStep[n:!N, r:!N, rbar:!N, rrbar:!N, rr:!N](
	const edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹), 
	const tt: int[n]^rr, 
	const ee: (𝔹^rr)^rr, 
	const w: int[n], 
	// ##########################################################################
	// gcqwRegs:(int[r]^rrbar x int[rbar] x int[r] x 𝔹^rrbar x int[rrbar] x 𝔹)
	// ##########################################################################
	tau:int[r]^rrbar, 
	// tau:int[log_int(2,rr)]^floor(2^max([2*log_int(2,rr)/3,1])),
	iota:int[rbar],
	// iota:int[floor(max([2 * log_int(2,rr) / 3, 1]))],
	sigma:int[r],
	// sigma:int[log_int(2,rr)],
	eew:𝔹^rrbar,
	// eew:𝔹^floor(2^max([2*log_int(2,rr)/3,1])),
	cTri:int[rrbar],
	// cTri:int[floor(2^max([2*log_int(2,rr)/3,1]))]
	// triTestT:𝔹
	) mfree //: int[r]^rrbar x int[rbar] x int[r] x 𝔹^rrbar x int[rrbar] x 𝔹 
	{

	//(tau, iota, sigma, eew, cTri, triTestT) := gcqwRegs;

	(iota, sigma) := a7_Diffuse_Pair(iota, sigma);

	(tau, taud, eewd, cTri, eew) := help_a20_2(tau, eew, cTri, edgeOracle, w, iota, tt, ee);
	(taud, sigma) := (sigma, taud); //a14_SWAP(taud, sigma);
	// (tau, eew, cTri) := reverse(help_a20_2)(tau, taud, eewd, cTri, eew, edgeOracle, w, iota, tt, ee);
	(tau, eew, cTri) := reverse(help_a20_2[n,r,rr,rbar,rrbar])(tau, taud, eewd, cTri, eew, edgeOracle, w, iota, tt, ee);

	return (tau, iota, sigma, eew, cTri);
}


// // todo: add w
// def help_a20_2(tau:const Int[], iota:const Int, eew: 𝔹[],
// 	cTri: Int, tt:const Node[], ee:const 𝔹[][], r:!Int, 
// 	rr:!Int, rrbar:!Int, n:!Int) :
// 	Node x 𝔹[] x Int x 𝔹 x 𝔹[] {

def help_a20_2[n:!N, r:!N, rr:!N, rbar:!N, rrbar:!N](
	// tau:int[log_int(2,rr)]^floor(2^max([2*log_int(2,rr)/3,1])), // 
	tau:int[r]^rrbar, 
	// eew:𝔹^floor(2^max([2*log_int(2,rr)/3,1])), // 
	eew:𝔹^rrbar,
	// cTri:int[floor(2^max([2*log_int(2,rr)/3,1]))], // 
	cTri:int[rrbar], 
	const edgeOracle:((const int[n] x const int[n] x 𝔹) !->mfree 𝔹), 
	const w:int[n], 
	// const iota:int[floor(max([2 * log_int(2,rr) / 3, 1]))], // 
	const iota:int[rbar],
	const tt:int[n]^rr, 
	const ee:(𝔹^rr)^rr ) mfree //: int[r]^rrbar x int[r] x 𝔹 x int[rrbar] x 𝔹^rrbar 
	{

	eewd := false:B;

	taud := tau[iota]; 
	(eew, eewd) := a10_FetchStoreT(iota, eew, eewd);

	for k in [ 0..floor(2^max([2*log_int(2,rr)/3,1])) ) {
		if ee[taud][tau[k]] && eewd && eew[k] {
			cTri -= 1;
	}	}

	eewd := edgeOracle(tt[taud], w, eewd);
	tau := a9_StoreT_Array(iota, tau, taud);

	return (tau, taud, eewd, cTri, eew);
}
