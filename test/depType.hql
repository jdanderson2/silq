
def main(){
	n := 32;
	x := 0: !int[n];
	n = 20; // error
}

def foo(){ // error
	n := 32;
	x := 0: !int[n];
	return x;
}

def main2(n:!ℕ){
	x := foo();
	y := x : !int[n];
}

