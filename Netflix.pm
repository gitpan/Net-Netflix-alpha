package Net::Netflix;

use WWW::Mechanize;

sub new {
  my $ref = shift;
  my $class = ref( $ref ) || $ref;

  my $self = bless {
    u => undef,
    p => undef,
    www => new WWW::Mechanize(),
    @_
  }, $class;

  die "Netflix requires a username and password" unless 
    ( $self->{u} && $self->{p} );

  $self->{www}->get('http://www.netflix.com/Login');
  $self->{www}->set_fields(
    email => $self->{u},
    password1 => $self->{p}
  );
  $self->{www}->submit();

  return $self;
}

sub getRatings {
  my ( $self ) = @_;

  my %ret;
  my $body = 'alt="Next"';
  my $cur = 0;

  while ( $body =~ /alt="Next"/i ) {
    $self->{www}->get( "http://www.netflix.com/MoviesYouveSeen?title_sort=t&pageNum=$cur" );
    $body = $self->{www}->content();
    while ( $body =~ /trkid=\d+">([^<]+).*?2,(\d)/gs ) {
      $ret{ $1 } = $2;
      print "$1 $2\n";
    }
    ++$cur;
  }

  return \%ret;
}
1;
