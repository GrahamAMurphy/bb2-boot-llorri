#!/usr/bin/perl

$xref_in = "" ;
$xref_out = "" ;

while ( @ARGV ) {
    if( $ARGV[0] eq "-in" ) {
	$xref_in = $ARGV[1] ;
	shift ;
    }
    shift ;
}

@a_name = () ;
@a_addr = () ;
@a_wid = () ;
@a_file = () ;
%k_ref = () ;
%n_ref = () ;
%w_ref = () ;
%n_cnts = () ;
%n_list = () ;
$p_fnd_addr = 1 ;

if ( $xref_in eq "" ) {
    $XREFIN = STDIN ;
    $XREFOUT1 = STDOUT ;
    $XREFOUT2 = STDOUT ;
} else {
    open( $XREFIN, "< $xref_in" ) or die "Could not open $xref_in\n" ;
    open( $XREFOUT1, "> ${xref_in}1" ) or die "Could not open ${xref_in}1\n" ;
    open( $XREFOUT2, "> ${xref_in}2" ) or die "Could not open ${xref_in}2\n" ;
}

while( <$XREFIN> ) {
    chomp() ;
    /(<.*>)([[:xdigit:]]{8}) ([[:xdigit:]]{4}) (.*)/ ;
    $name = $1 ;
    $addr = $2 ;
    $wid = $3 ;
    $file = $4 ;
    next if ( $name =~ /<-?[[:xdigit:]]+>/ ) ;
    $file =~ s;^.*/;; ;

    $eq_name = ( $a_name[$#a_name] eq $name ) ? 1 : 0 ;

    if ( ! $eq_name ) {
	$do_push = 1 ;
    } else {
	$do_push = 0 if ( $addr != 0 ) ;
	$do_push = 1 if ( $p_fnd_addr ) ;
    }

    $p_fnd_addr = ( $addr != 0 ) ;

    if ( $do_push ) {
	push @a_name, $name ;
	push @a_addr, $addr ;
	push @a_wid, $wid ;
	push @a_file, $file ;
    } else {
	$a_addr[$#a_name] = $addr ;
	$a_wid[$#a_name] = $wid ;
	$a_file[$#a_name] = $file ;
    }

    $k_ref{ $name, $wid } = -1 ;
    $n_ref{ $name, $wid } = $name ;
    $w_ref{ $name, $wid } = $wid ;
    $n_cnts{ $name } = 0 ;
    $n_list{ $name } = "" ;
}

close( $XREFIN ) ;
### print STDERR $#a_name . "\n" ;
$ifdef = 0 ;
$inref = 0 ;

foreach $i ( 0 .. $#a_name ) {
    $key = "$a_name[$i]$a_wid[$i]" ;
    if ( $ifdef ) { $ifdef = 0 ; next ; }
    if( $a_addr[$i] eq "00000000" ) {
	print $XREFOUT1 "$a_name[$i] $a_wid[$i] $a_file[$i]\n" ;
	if ( $k_ref { $a_name[$i], $a_wid[$i] } != -1 ) {
	    print STDERR "EEEK $i, $a_name[$i], $a_wid[$i]\n" ;
	    print STDERR "EEEK $k_ref{$a_name[$i], $a_wid[$i]}\n" ;
	    exit ;
	}
	$k_ref { $a_name[$i], $a_wid[$i] } = 0 ;
	$inref = 1 ;
    } else {
	$inref = 0 if ( $a_wid[$i] == 0 || $a_wid[$i] == 4 ) ;
	print $XREFOUT1 "    " if ( $inref == 1 ) ;
	print $XREFOUT1 "$a_name[$i] $a_wid[$i] $a_addr[$i]\n" ;
	if ( $k_ref { $a_name[$i], $a_wid[$i] } == -1 ) {
	    $k_ref { $a_name[$i], $a_wid[$i] } = 1 ;
	} else {
	    $k_ref{ $a_name[$i], $a_wid[$i] } ++ ;
	}
	$ifdef = 1 if ( $a_name[$i] eq "<[ifdef]>" ) ;
	$ifdef = 1 if ( $a_name[$i] eq "<[ifndef]>" ) ;
    }
}

foreach $i ( keys(%k_ref) ) {
    $n_i = $n_ref{ $i } ;
    $w_i = $w_ref{ $i } ;
    if ( $k_ref { $i } > 0 ) {
	$n_cnts{ $n_i } += $k_ref{$i} ;
	$n_list{ $n_i } .= "$k_ref{$i} $w_i " ;
    }
}

foreach $i ( sort( keys(%n_list) ) ) {
    print $XREFOUT2 sprintf( "%6d ", $n_cnts{$i} ) ;
    if ( $n_list{ $i } eq "" ) {
	print $XREFOUT2 "$i 0\n" ;
    } else {
	print $XREFOUT2 "$i $n_list{$i}\n" ;
    }
}

close( $XREFOUT1 ) ;
close( $XREFOUT2 ) ;
