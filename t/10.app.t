use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use MyApp;
use File::Copy;

copy('t/data/dvdzbr.db','t/tmp/dvdzbr.db') or die 'Copy failed: $!';

test_psgi( 
    app => MyApp->get_handler, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/");
        like( $res->content, qr/This is the home page/ );
        $res = $cb->(GET "/dvd");
        like( $res->content, qr/Jurassic Park II/ );
        $res = $cb->(POST '/dvd/record/5/edit', [ name => 'Not Jurassic Park' ] );
        ok( $res->is_redirect, 'Redirect after POST' );
        $res = $cb->(GET $res->header('Location'));
        like( $res->content, qr/Not Jurassic Park/ );
    } 
);

done_testing();
