# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Bio-Graphics-DecoratedGene.t'

#Test case for image maps
#########################

use strict;
use warnings;

use Test::More tests => 31;
BEGIN { 
	use_ok('Bio::Graphics::Glyph::decorated_transcript'); 
	use_ok('Bio::Graphics'); 
	use_ok('Bio::Graphics::Panel'); 
	use_ok('Bio::DB::SeqFeature::Store'); 
	use_ok('Bio::Graphics::Feature'); 
	use_ok('File::Basename'); 
};

#########################

# load features
my $store = Bio::DB::SeqFeature::Store->new
(
	-adaptor => 'memory', 
	-dsn => 't/data/decorated_transcript_t1.gff'
);
isa_ok( $store, 'Bio::DB::SeqFeature::Store' );

can_ok('Bio::DB::SeqFeature::Store', qw(features));

my ($gene_minus) =  $store->features(-name => 'PFA0680c-minus');
is ($gene_minus->name, 'PFA0680c-minus' , "get features from store");  	

# draw panel
can_ok('Bio::Graphics::Panel', qw(offset key_style width pad_left add_track));
my @args = (	-length    => $gene_minus->end-$gene_minus->start+102,
	-offset     => $gene_minus->start-100,
	-key_style => 'between',
	-width     => 1024,
	-pad_left  => 100);

my $panel = new_ok('Bio::Graphics::Panel' => \@args);
can_ok($panel, qw(add_track));
add_tracks($panel);

my $panel2;
SKIP: {
    eval{ require GD::SVG };
    skip "GD::SVG not installed", 6 if $@;

	my @args2 = (	-length    => $gene_minus->end-$gene_minus->start+102,
		-offset     => $gene_minus->start-100,
		-key_style => 'between',
		-width     => 1024,
		-pad_left  => 100,
		-image_class=>'GD::SVG');
	$panel2 = new_ok('Bio::Graphics::Panel' => \@args2);

	can_ok($panel2, qw(add_track));
	add_tracks($panel2);
}

sub add_tracks
{
	my $panel = shift;
	
	# ruler
	can_ok($panel, qw(add_track));
	$panel->add_track(
		Bio::Graphics::Feature->new(-start => $gene_minus->start-100, -end => $gene_minus->end),
		-glyph  => 'arrow',
		-bump   => 0,
		-double => 1,
		-tick   => 2
	);
	ok(1, 'ruler made');
	
	$panel->add_track
	(
		$gene_minus,
		-glyph => 'decorated_gene',
		-decoration_visible => 1,
		-box_subparts => 3,
		-link => '$name',
		-title => '$name',	
		-height => 12,
		-decoration_color		=> 'white',
		-decoration_label_position => '', #the default is inside,
		-decoration_label_color => 'black'
	);
	ok(1, 'track1 added');
	
	$panel->add_track
	(
		$gene_minus,
		-glyph => 'decorated_gene',
		-decoration_visible => 1,
		-box_subparts => 3,	
		-link => '$name',
		-title => '$name',	
		-height => 12,
		-decoration_color		=> 'white',
		-decoration_label_position => 'above',
		-decoration_label_color => 'black',
	);
	ok(1, 'track2 added');
}

# write image
my $png = $panel->png;
is($png,$panel->png,'png created');
my $imgfile = "t/data/imagemaps.png";
system("rm $imgfile") if (-e $imgfile);
open(IMG,">$imgfile") or die "could not write to file $imgfile";
print IMG $png;
close(IMG);
ok(-e $imgfile, 'imgfile created');
my $filesize = -s $imgfile;
isnt($filesize,0, 'check nonzero filesize');

my $html_file = "t/data/imagemaps.html";
my $image_map = $panel->create_web_map();
my $img_file_base = basename($imgfile);
is($image_map,$panel->create_web_map(),'image map created');
	system("rm $html_file") if (-e $html_file);
		open(HTML, ">$html_file") or Bio::Root::Exception("could not write to file $html_file");
		print HTML "<html>\n<body>\n";
		print HTML "<img src=\"imagemaps.png\" usemap=\"#map\" />\n";
		print HTML "$image_map";
		print HTML "</body>\n</html>\n";
		close(HTML);
	
ok (-e $html_file, "$html_file" );
$filesize = -s $html_file;
isnt($filesize,0, 'check nonzero filesize');

SKIP: {
    eval{ require GD::SVG };
    skip "GD::SVG not installed", 2 if $@;

	my $svg = $panel2->svg;
	#is($svg,$panel2->svg,'svg created');
	my $svgfile = "t/data/imagemaps.svg";
	system("rm $svgfile") if (-e $svgfile);
	open(IMG,">$svgfile") or die "could not write to file $svgfile";
	print IMG $svg;
	close(IMG);
	ok(-e $svgfile, 'svgfile created');
	$filesize = -s $svgfile;
	isnt($filesize,0, 'check nonzero filesize');
}

ok($image_map eq '<map name="map" id="map">
<area shape="rect" coords="846,27,871,36" href="VTS" title="VTS" />
<area shape="rect" coords="392,27,471,36" href="TM" title="TM" />
<area shape="rect" coords="239,27,378,36" href="TM" title="TM" />
<area shape="rect" coords="926,27,933,36" href="SP" title="SP" />
<area shape="rect" coords="215,26,933,37" href="cds_PFA0680c-2-2" title="cds_PFA0680c-2-2" />
<area shape="rect" coords="1042,27,1122,36" href="SP" title="SP" />
<area shape="rect" coords="1042,26,1122,37" href="cds_PFA0680c-1-1" title="cds_PFA0680c-1-1" />
<area shape="rect" coords="215,26,1122,37" href="isoform1" title="isoform1" />
<area shape="rect" coords="846,41,871,50" href="VTS" title="VTS" />
<area shape="rect" coords="926,41,933,50" href="SP" title="SP" />
<area shape="rect" coords="424,40,933,51" href="cds_PFA0680c-2-2" title="cds_PFA0680c-2-2" />
<area shape="rect" coords="1042,41,1122,50" href="SP" title="SP" />
<area shape="rect" coords="1042,40,1122,51" href="cds_PFA0680c-2-1" title="cds_PFA0680c-2-1" />
<area shape="rect" coords="424,40,1122,51" href="isoform2" title="isoform2" />
<area shape="rect" coords="215,26,1122,52" href="PFA0680c-minus" title="PFA0680c-minus" />
<area shape="rect" coords="846,72,871,81" href="VTS" title="VTS" />
<area shape="rect" coords="392,72,471,81" href="TM" title="TM" />
<area shape="rect" coords="239,72,378,81" href="TM" title="TM" />
<area shape="rect" coords="926,72,933,81" href="SP" title="SP" />
<area shape="rect" coords="215,71,933,82" href="cds_PFA0680c-2-2" title="cds_PFA0680c-2-2" />
<area shape="rect" coords="1042,72,1122,81" href="SP" title="SP" />
<area shape="rect" coords="1042,71,1122,82" href="cds_PFA0680c-1-1" title="cds_PFA0680c-1-1" />
<area shape="rect" coords="215,58,1122,82" href="isoform1" title="isoform1" />
<area shape="rect" coords="846,99,871,108" href="VTS" title="VTS" />
<area shape="rect" coords="926,99,933,108" href="SP" title="SP" />
<area shape="rect" coords="424,98,933,109" href="cds_PFA0680c-2-2" title="cds_PFA0680c-2-2" />
<area shape="rect" coords="1042,99,1122,108" href="SP" title="SP" />
<area shape="rect" coords="1042,98,1122,109" href="cds_PFA0680c-2-1" title="cds_PFA0680c-2-1" />
<area shape="rect" coords="424,85,1122,109" href="isoform2" title="isoform2" />
<area shape="rect" coords="215,58,1122,110" href="PFA0680c-minus" title="PFA0680c-minus" />
</map>
', 'image map correct');

