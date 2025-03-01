# Model generator
# (c) 2022,2025 Singularis <singularis@volny.cz>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

my @index_to_v;
my %v_to_index;
my @index_to_vt;
my %vt_to_index;
my @index_to_vn;
my %vn_to_index;
my (@faces1, @faces2, @faces3, @faces4, @faces5, @faces6);
my @faces = (0, \@faces1, \@faces2, \@faces3, \@faces4, \@faces5, \@faces6);
my @v_scale = (1, 1, 1);
my @v_shift = (0, 0, 0);
my @vt_scale = (1, 1);
my @vt_shift = (0, 0);

# 1 = top = +y
# 2 = bottom = -y
# 3 = right = +x
# 4 = left = -x
# 5 = back = +z
# 6 = front = -z

sub reset_mesh
{
	@index_to_v = ();
	@index_to_vn = ();
	@index_to_vt = ();
	%v_to_index = ();
	%vn_to_index = ();
	%vt_to_index = ();
	foreach my $i (1, 2, 3, 4, 5, 6) {
		@{$faces[$i]} = ();
	}
}

sub get_v # (x, y, z)
{
	typy(@ARG) =~ /\Asss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my $x = $ARG[0] * $v_scale[0] + $v_shift[0];
	my $y = $ARG[1] * $v_scale[1] + $v_shift[1];
	my $z = $ARG[2] * $v_scale[2] + $v_shift[2];
	my $text = sprintf("v %.6f %.6f %.6f", $x, $y, $z);
	my $result = $v_to_index{$text};
	if (!defined($result)) {
		$result = alength(@index_to_v);
		$v_to_index{$text} = $result;
		$index_to_v[$result] = $text
	}
	return $result;
}

sub get_vt # (x, y)
{
	typy(@ARG) =~ /\Ass\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my $x = $ARG[0] * $vt_scale[0] + $vt_shift[0];
	my $y = $ARG[1] * $vt_scale[1] + $vt_shift[1];
	my $text = sprintf("vt %.4f %.4f", $x, $y);
	my $result = $vt_to_index{$text};
	if (!defined($result)) {
		$result = alength(@index_to_vt);
		$vt_to_index{$text} = $result;
		$index_to_vt[$result] = $text
	}
	return $result;
}

sub get_vn # (x, y, z)
{
	typy(@ARG) =~ /\Asss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my $text = sprintf("vn %.4f %.4f %.4f", @ARG);
	my $result = $vn_to_index{$text};
	if (!defined($result)) {
		$result = alength(@index_to_vn);
		$vn_to_index{$text} = $result;
		$index_to_vn[$result] = $text
	}
	return $result;
}

sub add_face # (strana, [v, vt, vn]x4)
{
	typy(@ARG) =~ /\AsAAAA\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my $strana = shift(@ARG);
	my $f = $faces[$strana];
	$f->[alength(@{$f})] = sprintf("f %d/%d/%d %d/%d/%d %d/%d/%d %d/%d/%d",
		$ARG[0]->[0] + 1, $ARG[0]->[1] + 1, $ARG[0]->[2] + 1,
		$ARG[1]->[0] + 1, $ARG[1]->[1] + 1, $ARG[1]->[2] + 1,
		$ARG[2]->[0] + 1, $ARG[2]->[1] + 1, $ARG[2]->[2] + 1,
		$ARG[3]->[0] + 1, $ARG[3]->[1] + 1, $ARG[3]->[2] + 1);
}

sub flush_to_string
{
	typy(@ARG) eq "" or die("Chybné typy parametrů: ".typy(@ARG));
	my $result = join("\n", @index_to_v, @index_to_vt, @index_to_vn, "g top\ns off", @faces1,
		"g bottom\ns off", @faces2, "g right\ns off", @faces3, "g left\ns off", @faces4,
		"g back\ns off", @faces5, "g front\ns off", @faces6, "");
	reset_mesh();
	return $result;
}

sub flush
{
	typy(@ARG) eq "" or die("Chybné typy parametrů: ".typy(@ARG));
	foreach my $v (@index_to_v) {
		printf("%s\n", $v);
	}
	foreach my $vt (@index_to_vt) {
		printf("%s\n", $vt);
	}
	foreach my $vn (@index_to_vn) {
		printf("%s\n", $vn);
	}
	printf("g top\ns off\n");
	foreach my $face (@faces1) {
		printf("%s\n", $face);
	}
	printf("g bottom\ns off\n");
	foreach my $face (@faces2) {
		printf("%s\n", $face);
	}
	printf("g right\ns off\n");
	foreach my $face (@faces3) {
		printf("%s\n", $face);
	}
	printf("g left\ns off\n");
	foreach my $face (@faces4) {
		printf("%s\n", $face);
	}
	printf("g back\ns off\n");
	foreach my $face (@faces5) {
		printf("%s\n", $face);
	}
	printf("g front\ns off\n");
	foreach my $face (@faces6) {
		printf("%s\n", $face);
	}
	reset_mesh();
}

sub ctverec
{
	# (strana, [tex_x_min, tex_x_max], [tex_y_min, tex_y_max], [x_min, x_max], [y_min, y_max], [z_min, z_max], normal_value, do_reverse, do_vt_shift)
	typy(@ARG) =~ /\AsAA(sAA|AsA|AAs)sss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($strana, $tex_x, $tex_y, $x, $y, $z, $n_value, $do_reverse, $do_vt_shift) = @ARG;

	my $vt0 = get_vt($tex_x->[0], $tex_y->[0]);
	my $vt1 = get_vt($tex_x->[1], $tex_y->[0]);
	my $vt2 = get_vt($tex_x->[1], $tex_y->[1]);
	my $vt3 = get_vt($tex_x->[0], $tex_y->[1]);

	if ($do_vt_shift) {
		($vt0, $vt1, $vt2, $vt3) = ($vt1, $vt2, $vt3, $vt0);
	}

	my ($v0, $v1, $v2, $v3, $vn);

	if (typy($x) eq "s") {
		$v0 = get_v($x, $y->[0], $z->[0]);
		$v1 = get_v($x, $y->[1], $z->[0]);
		$v2 = get_v($x, $y->[1], $z->[1]);
		$v3 = get_v($x, $y->[0], $z->[1]);
		$vn = get_vn($n_value, 0, 0);
	} elsif (typy($y) eq "s") {
		$v0 = get_v($x->[0], $y, $z->[0]);
		$v1 = get_v($x->[1], $y, $z->[0]);
		$v2 = get_v($x->[1], $y, $z->[1]);
		$v3 = get_v($x->[0], $y, $z->[1]);
		$vn = get_vn(0, $n_value, 0);
	} else {
		$v0 = get_v($x->[0], $y->[0], $z);
		$v1 = get_v($x->[1], $y->[0], $z);
		$v2 = get_v($x->[1], $y->[1], $z);
		$v3 = get_v($x->[0], $y->[1], $z);
		$vn = get_vn(0, 0, $n_value);
	}

	if ($do_reverse) {
		add_face($strana, [$v0, $vt0, $vn], [$v1, $vt1, $vn], [$v2, $vt2, $vn], [$v3, $vt3, $vn]);
	} else {
		add_face($strana, [$v3, $vt3, $vn], [$v2, $vt2, $vn], [$v1, $vt1, $vn], [$v0, $vt0, $vn]);
	}
	return 0;
}

sub nodebox_mx
{
	typy(@ARG) =~ /\Assssss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($x_min, $y_min, $z_min, $x_max, $y_max, $z_max) = @ARG;
	if ($x_min > $x_max) {($x_min, $x_max) = ($x_max, $x_min)}
	if ($y_min > $y_max) {($y_min, $y_max) = ($y_max, $y_min)}
	if ($z_min > $z_max) {($z_min, $z_max) = ($z_max, $z_min)}
	return ctverec(4, [-$y_min + 0.5, -$y_max + 0.5], [$z_min + 0.5, $z_max + 0.5], $x_min, [$y_min, $y_max], [$z_min, $z_max], -1, 0, 1);
}

sub nodebox_px
{
	typy(@ARG) =~ /\Assssss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($x_min, $y_min, $z_min, $x_max, $y_max, $z_max) = @ARG;
	if ($x_min > $x_max) {($x_min, $x_max) = ($x_max, $x_min)}
	if ($y_min > $y_max) {($y_min, $y_max) = ($y_max, $y_min)}
	if ($z_min > $z_max) {($z_min, $z_max) = ($z_max, $z_min)}
	return ctverec(3, [$y_min + 0.5, $y_max + 0.5], [$z_min + 0.5, $z_max + 0.5], $x_max, [$y_min, $y_max], [$z_min, $z_max], 1, 1, 1);
}

sub nodebox_my
{
	typy(@ARG) =~ /\Assssss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($x_min, $y_min, $z_min, $x_max, $y_max, $z_max) = @ARG;
	if ($x_min > $x_max) {($x_min, $x_max) = ($x_max, $x_min)}
	if ($y_min > $y_max) {($y_min, $y_max) = ($y_max, $y_min)}
	if ($z_min > $z_max) {($z_min, $z_max) = ($z_max, $z_min)}
	return ctverec(2, [-$x_min + 0.5, -$x_max + 0.5], [-$z_min + 0.5, $z_max + 0.5], [$x_min, $x_max], $y_min, [$z_min, $z_max], -1, 1, 0);
}

sub nodebox_py
{
	typy(@ARG) =~ /\Assssss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($x_min, $y_min, $z_min, $x_max, $y_max, $z_max) = @ARG;
	if ($x_min > $x_max) {($x_min, $x_max) = ($x_max, $x_min)}
	if ($y_min > $y_max) {($y_min, $y_max) = ($y_max, $y_min)}
	if ($z_min > $z_max) {($z_min, $z_max) = ($z_max, $z_min)}
	return ctverec(1, [-$x_min + 0.5, -$x_max + 0.5], [$z_min + 0.5, $z_max + 0.5], [$x_min, $x_max], $y_max, [$z_min, $z_max], 1, 0, 0);
}

sub nodebox_mz
{
	typy(@ARG) =~ /\Assssss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($x_min, $y_min, $z_min, $x_max, $y_max, $z_max) = @ARG;
	if ($x_min > $x_max) {($x_min, $x_max) = ($x_max, $x_min)}
	if ($y_min > $y_max) {($y_min, $y_max) = ($y_max, $y_min)}
	if ($z_min > $z_max) {($z_min, $z_max) = ($z_max, $z_min)}
	return ctverec(6, [-$x_min + 0.5, -$x_max + 0.5], [$y_min + 0.5, $y_max + 0.5], [$x_min, $x_max], [$y_min, $y_max], $z_min, -1, 0, 0);
}

sub nodebox_pz
{
	typy(@ARG) =~ /\Assssss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($x_min, $y_min, $z_min, $x_max, $y_max, $z_max) = @ARG;
	if ($x_min > $x_max) {($x_min, $x_max) = ($x_max, $x_min)}
	if ($y_min > $y_max) {($y_min, $y_max) = ($y_max, $y_min)}
	if ($z_min > $z_max) {($z_min, $z_max) = ($z_max, $z_min)}
	return ctverec(5, [$x_min + 0.5, $x_max + 0.5], [$y_min + 0.5, $y_max + 0.5], [$x_min, $x_max], [$y_min, $y_max], $z_max, 1, 1, 0);
}

sub nodebox
{
	# (x_min, y_min, z_min, x_max, y_max, z_max)
	typy(@ARG) =~ /\Assssss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($x_min, $y_min, $z_min, $x_max, $y_max, $z_max) = @ARG;
	# top (+y):
	ctverec(1, [$x_max + 0.5, $x_min + 0.5], [$z_min + 0.5, $z_max + 0.5], [$x_min, $x_max], $y_max, [$z_min, $z_max], 1, 0, 0);
	# bottom (-y):
	ctverec(2, [$x_max + 0.5, $x_min + 0.5], [$z_max + 0.5, $z_min + 0.5], [$x_min, $x_max], $y_min, [$z_min, $z_max], -1, 1, 0);
	# right (+x):
	ctverec(3, [$y_min + 0.5, $y_max + 0.5], [$z_min + 0.5, $z_max + 0.5], $x_max, [$y_min, $y_max], [$z_min, $z_max], 1, 1, 1);
	# left (-x):
	ctverec(4, [$y_max + 0.5, $y_min + 0.5], [$z_min + 0.5, $z_max + 0.5], $x_min, [$y_min, $y_max], [$z_min, $z_max], -1, 0, 1);
	# back (+z):
	ctverec(5, [$x_min + 0.5, $x_max + 0.5], [$y_min + 0.5, $y_max + 0.5], [$x_min, $x_max], [$y_min, $y_max], $z_max, 1, 1, 0);
	# front (-z):
	ctverec(6, [$x_max + 0.5, $x_min + 0.5], [$y_min + 0.5, $y_max + 0.5], [$x_min, $x_max], [$y_min, $y_max], $z_min, -1, 0, 0);
}

sub trashcan_normal
{
	# stěna +z (úplná):
	nodebox(-0.375, -0.5, 0.3125, 0.375, 0.5, 0.375);
	# stěna -z (úplná):
	nodebox(-0.375, -0.5, -0.375, 0.375, 0.5, -0.3125);
	# stěna +x:
	nodebox(0.3125, -0.5, -0.3125, 0.375, 0.5, 0.3125);
	# stěna -x:
	nodebox(-0.375, -0.5, -0.3125, -0.3125, 0.5, 0.3125);
	# bottom:
	nodebox_py(-0.3125, -0.5, -0.3125, 0.3125, -0.4375, 0.3125);
	nodebox_my(-0.3125, -0.5, -0.3125, 0.3125, -0.4375, 0.3125);
	return flush_to_string();
}

my $file;

mkdir("out");
open(my $f1, ">:utf8", "out/trash_can_normal.obj") or die("Nelze otevřít soubor!");
$file = $f1;
fprintf($file, "%s", trashcan_normal());
close($f1) or die("Chyba zápisu!");

open(my $f2, ">:utf8", "out/trash_can_small_center.obj") or die("Nelze otevřít soubor!");
$file = $f2;
@v_scale = ( 0.666666,  0.666666,  0.666666);
@v_shift = ( 0.000000, -0.166667,  0.000000);
fprintf($file, "%s", trashcan_normal());
close($f2) or die("Chyba zápisu!");

open(my $f3, ">:utf8", "out/trash_can_small.obj") or die("Nelze otevřít soubor!");
$file = $f3;
@v_scale = ( 0.666666,  0.666666,  0.666666);
@v_shift = ( 0.000000, -0.166667,  0.200000);
fprintf($file, "%s", trashcan_normal());
close($f3) or die("Chyba zápisu!");

# flush();
# my $s = flush_to_string();
# printf("%s", $s);

