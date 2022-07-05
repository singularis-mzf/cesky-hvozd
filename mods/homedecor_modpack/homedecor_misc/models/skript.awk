BEGIN {
	FS = " ";
	OFS = " ";
	i = 0;
	y_min = 1000.0;
	y_max = -1000.0;
	delete inpole;
	delete ypole;
}
{
	inpole[++i] = $0;
	if ($1 ~ /^vn?$/) {
		ypole[i] = y = $3;
		if (y < y_min) {y_min = y}
		if (y > y_max) {y_max = y}
	}
}
END {
	lower_file = "/home/kalandira/ram/lower.obj";
	upper_file = "/home/kalandira/ram/upper.obj";
	for (i = 1; i in inpole; ++i) {
		$0 = inpole[i];
		if ($1 == "v") {
			y = ypole[i];
			y_low = 0.5 * (y + y_max) - 0.25 * (y_max - y_min) - 1.0;
			y_high = 0.5 * (y + y_max) - 1.0;

			y_low = (y - y_min) / (y_max - y_min) * 1.2; # normalizace
			if (y_low < 0.5 * 1.2) {
				y_low -= 0.5;
			}
			y_low -= 0.5 / 2; # globální posun dolu
			y_high = y_low + 0.5;
			print "TRANSFORM " y " => " y_low " and " y_high " (y_min = " y_min ", y_max = " y_max ")" > "/dev/stderr";
			$3 = y_low;
			print > lower_file;
			$3 = y_high;
			print > upper_file;
			continue;
		} else if ($1 == "vn") {
			$3 = 0.5 * ypole[i];
		}
		print > lower_file;
		print > upper_file;
	}
}
