use Test;
BEGIN { plan tests => 12 }
use XML::SAX::Base;
use vars qw/%events/;
require "t/sax_base/events.pl";

# Tests for ContentHandler classes using a filter

my $sax_it = SAXAutoload->new();
my $filter = Filter->new(ContentHandler => $sax_it);
my $driver = Driver->new(ContentHandler => $filter);
my %ret  = $driver->parse();

ok (scalar(keys(%ret)) == 11);

foreach my $meth (keys(%ret)){
    my $ok_cnt = 0;
    foreach my $key (keys (%{ $ret{$meth} })){
        $ok_cnt++ if $ret{$meth}->{$key} eq $events{$meth}->{$key};
    }
    ok(
       $ok_cnt == scalar(keys(%{$ret{$meth}})) &&
       $ok_cnt == scalar(keys(%{$events{$meth}}))
      ) || warn "failed for $meth\n";
}
# end main

package Filter;
use base qw(XML::SAX::Base);
# this space intentionally blank

1;

package Driver;
use base qw(XML::SAX::Base);

sub parse {
    my $self = shift;
    my %events = %main::events;
 
    $self->SUPER::start_document($events{start_document});
    $self->SUPER::processing_instruction($events{processing_instruction});
    $self->SUPER::set_document_locator($events{set_document_locator});
    $self->SUPER::start_prefix_mapping($events{start_prefix_mapping});
    $self->SUPER::start_element($events{start_element});
    $self->SUPER::characters($events{characters});
    $self->SUPER::ignorable_whitespace($events{ignorable_whitespace});
    $self->SUPER::skipped_entity($events{skipped_entity});
    $self->SUPER::end_element($events{end_element});
    $self->SUPER::end_prefix_mapping($events{end_prefix_mapping});
    return $self->SUPER::end_document($events{end_document});
}
1;

# basic single class SAX Handler
package SAXAutoload;
use vars qw($AUTOLOAD);
use strict;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %options = @_;
    $options{Methods} = {};
    return bless \%options, $class;
}
sub AUTOLOAD {
    my $self = shift;
    my $data = shift;
    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion
    return if $name eq 'DESTROY';
    $self->{Methods}->{$name} = $data ;
}

sub end_document {
    my $self = shift;
    my $data = shift;
    $self->{Methods}->{end_document} = $data;
    return %{$self->{Methods}};
}

1;
