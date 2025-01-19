function convert(prefix, n)
{
	# 0, 10
	# 1, 19
	# 2, 4
	# 3, 13
	# 5, 18
	# 6, 22
	# 7, 14
	# 8, 20
	# 9, 16
	# 11, 12
	# 15, 21
	# 17, 23
	if (prefix == "v") {
		if (n == 1) {
			x = $3; y = -$4; z = -$2;
		} else if (n == 2) {
			x = -$2; y = $3; z = -$4;
			nx = $2; ny = $3; xz = $4;
		} else if (n == 3) {
			x = -$3; y = -$4; z = $2;
		} else if (n == 5) {
			x = -$4; y = -$2; z = $3;
		} else if (n == 6) {
			x = -$2; y = $4; z = $3;
		} else if (n == 7) {
			x = -$3; y = -$2; z = -$4;
		} else if (n == 8) {
			x = $2; y = $4; z = -$3;
		} else if (n == 9) {
			x = $3; y = -$2; z = $4;
		} else if (n == 11) {
			x = $4; y = -$2; z = -$3;
		} else if (n == 15) {
			x = -$3; y = $4; z = -$2;
		} else if (n == 17) {
			x = -$4; y = -$3; z = -$2;
		}
	}
}
function out(prefix, a, b)
{
	if (prefix == "v") {
		printf("v %0.6f %0.6f %0.6f\n", x, y, z) > o;
	#} else if (prefix == "vn") {
		#printf("vn %.4f %.4f %.4f\n", nx, ny, nz) > o;
	}
	else {
		print > o;
	}
}
function generate(a, b)
{
	o = "techpack_stairway_slope_" a "_" b ".obj";
	print "Will generate" o "!";
	if (a == 0) {
		# zvláštní případ
		while (getline < f) {
			print > o;
		}
	} else {
		while (getline < f) {
			if ($1 == "v" || $1 == "f") {
				convert($1, a);
			}
			out($1, a, b);
		}
	}
	close(f);
	close(o);
}

BEGIN {
	FS = " ";
	f = "techpack_stairway_slope.obj";
	generate(0, 10);
	generate(1, 19);
	generate(2, 4);
	generate(3, 13);
	generate(5, 18);
	generate(6, 22);
	generate(7, 14);
	generate(8, 20);
	generate(9, 16);
	generate(11, 12);
	generate(15, 21);
	generate(17, 23);
}
