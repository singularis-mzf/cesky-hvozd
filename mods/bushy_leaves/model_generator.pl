# Model generator (use with „Linux: Kniha kouzel“)
# (c) 2022 Singularis <singularis@volny.cz>
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
my @faces;

sub get_v # (x, y, z)
{
	typy(@ARG) =~ /\Asss\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my $text = sprintf("v %.6f %.6f %.6f", @ARG);
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
	my $text = sprintf("vt %.4f %.4f", @ARG);
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

sub add_face # ([v, vt, vn]x4)
{
	typy(@ARG) =~ /\AAAAA\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	$faces[alength(@faces)] = sprintf("f %d/%d/%d %d/%d/%d %d/%d/%d %d/%d/%d",
		$ARG[0]->[0] + 1, $ARG[0]->[1] + 1, $ARG[0]->[2] + 1,
		$ARG[1]->[0] + 1, $ARG[1]->[1] + 1, $ARG[1]->[2] + 1,
		$ARG[2]->[0] + 1, $ARG[2]->[1] + 1, $ARG[2]->[2] + 1,
		$ARG[3]->[0] + 1, $ARG[3]->[1] + 1, $ARG[3]->[2] + 1);
}

sub g
{
	typy(@ARG) =~ /\As\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	printf("g %s\n", @ARG);
	@index_to_v = @index_to_vt = ();
	%v_to_index = %vt_to_index = ();
	@index_to_vn = ();
	return 0;
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
	printf("s off\n");
	foreach my $face (@faces) {
		printf("%s\n", $face);
	}
}

sub ctverec
{
	# ([tex_x_min, tex_x_max], [tex_y_min, tex_y_max], [x_min, x_max], [y_min, y_max], [z_min, z_max])
	typy(@ARG) =~ /\AAA(sAA|AsA|AAs)\z/ or die("Chybné typy parametrů: ".typy(@ARG));
	my ($tex_x, $tex_y, $x, $y, $z) = @ARG;

	my $vt0 = get_vt($tex_x->[0], $tex_y->[0]);
	my $vt1 = get_vt($tex_x->[1], $tex_y->[0]);
	my $vt2 = get_vt($tex_x->[1], $tex_y->[1]);
	my $vt3 = get_vt($tex_x->[0], $tex_y->[1]);

	my ($v0, $v1, $v2, $v3, $vn);

	if (typy($x) eq "s") {
		$v0 = get_v($x, $y->[0], $z->[0]);
		$v1 = get_v($x, $y->[1], $z->[0]);
		$v2 = get_v($x, $y->[1], $z->[1]);
		$v3 = get_v($x, $y->[0], $z->[1]);
		$vn = get_vn(1, 0, 0);
	} elsif (typy($y) eq "s") {
		$v0 = get_v($x->[0], $y, $z->[0]);
		$v1 = get_v($x->[1], $y, $z->[0]);
		$v2 = get_v($x->[1], $y, $z->[1]);
		$v3 = get_v($x->[0], $y, $z->[1]);
		$vn = get_vn(0, 1, 0);
	} else {
		$v0 = get_v($x->[0], $y->[0], $z);
		$v1 = get_v($x->[1], $y->[0], $z);
		$v2 = get_v($x->[1], $y->[1], $z);
		$v3 = get_v($x->[0], $y->[1], $z);
		$vn = get_vn(0, 0, 1);
	}

	add_face([$v0, $vt0, $vn], [$v1, $vt1, $vn], [$v2, $vt2, $vn], [$v3, $vt3, $vn]);
	return 0;
}

my ($x, $y);

g("skupa");
$x = [-4/16.0, 4/16.0];
$y = [8/16.0, 12/16.0];
ctverec($x, $y, 0.0/16, $x, $y);
$x = [-8/16.0, 8.0/16.0];
$y = [4/16.0, 8/16.0];
ctverec($x, $y, 0/16.0, $x, $y);
$x = [-12/16.0, 12.0/16.0];
$y = [-4/16.0, 4/16.0];
ctverec($x, $y, 0/16.0, $x, $y);
$x = [-8/16.0, 8.0/16.0];
$y = [-8/16.0, -4/16.0];
ctverec($x, $y, 0/16.0, $x, $y);
$x = [-4/16.0, 4.0/16.0];
$y = [-12/16.0, -8/16.0];
ctverec($x, $y, 0/16.0, $x, $y);
# flush();

# g("skupb");
# vodorovná část:
my $full_model = 0;
if ($full_model) {
	$x = [-4/16.0, 4/16.0];
	$y = [8/16.0, 12/16.0];
	ctverec($x, $y, $x, 0.0/16, $y);
	$x = [-8/16.0, 8.0/16.0];
	$y = [4/16.0, 8/16.0];
	ctverec($x, $y, $x, 0/16.0, $y);
	$x = [-12/16.0, 12.0/16.0];
	$y = [-4/16.0, 4/16.0];
	ctverec($x, $y, $x, 0/16.0, $y);
	$x = [-8/16.0, 8.0/16.0];
	$y = [-8/16.0, -4/16.0];
	ctverec($x, $y, $x, 0/16.0, $y);
	$x = [-4/16.0, 4.0/16.0];
	$y = [-12/16.0, -8/16.0];
	ctverec($x, $y, $x, 0/16.0, $y);
} else {
	$x = [-8/16.0, 8.0/16.0];
	$y = [-8/16.0, 8.0/16.0];
	ctverec($x, $y, $x, 0/16.0, $y);
}

$x = [-4/16.0, 4/16.0];
$y = [8/16.0, 12/16.0];
ctverec($x, $y, $x, $y, 0.0/16);
$x = [-8/16.0, 8.0/16.0];
$y = [4/16.0, 8/16.0];
ctverec($x, $y, $x, $y, 0.0/16);
$x = [-12/16.0, 12.0/16.0];
$y = [-4/16.0, 4/16.0];
ctverec($x, $y, $x, $y, 0.0/16);
$x = [-8/16.0, 8.0/16.0];
$y = [-8/16.0, -4/16.0];
ctverec($x, $y, $x, $y, 0.0/16);
$x = [-4/16.0, 4.0/16.0];
$y = [-12/16.0, -8/16.0];
ctverec($x, $y, $x, $y, 0.0/16);
flush();
