package Untappd;

=head1 NAME

Untappd - a Perl wrapper for the Untappd.com API.

=head1 SYNOPSIS

 use Untappd;

 my $untappd = Untappd->new({
    client_id     => "XXXXX",
    client_secret => "YYYYY",
    access_token  => "ZZZZZ",
 });

 my $user_info = $untappd->user_info({ username => "USERNAME" });

 print "Total Beers: ",  $user_info->{user}{stats}{total_beers};
 print "Total Badges: ", $user_info->{user}{stats}{total_badges};

 my $checkins = $untappd->checkin_recent();

 foreach my $checkin ( @{ $checkins->{checkins}{items} } ) {
     print "$checkin->{user}{first_name} $checkin->{user}{last_name} ",
           "had $checkin->{beer}{beer_name} by $checkin->{brewery}{brewery_name}\n";
 }

=head1 DESCRIPTION

This is a library for accessing the Untappd API.

You'll first need to register for an API key, which you can do here:

L<http://untappd.com/api/register>

The API that this library accesses is documented here:

L<https://untappd.com/api/docs/v4>

Once you have your API key, you'll want to obtain an access_token.  See the C<oath_authenticate> function
below for instructions on how to do that.

Parameters passed to the various methods below should be passed in as a hashref.

Responses are a multi-dimensional hashref, as provided by Untappd.com.

=head1 METHODS

=cut

$Untappd::VERSION="0.10";

use LWP::UserAgent;
use JSON;
use URI;

sub new {
    my ($class, $args) = @_;

    my $untappd = {
        client_id     => $args->{client_id}     || "",
        client_secret => $args->{client_secret} || "",
        access_token  => $args->{access_token}  || "",
        untappd_url   => "http://api.untappd.com/v4/",
    };

    bless ($untappd, $class);

    return $untappd;
}

=pod

=over 4

=item oath_authenticate()

Obtains OAuth authentication URL.

Application authentication with Untappd is handled via OAuth.

In order for most of these functions to work, you need to login to Untappd via the OAuth URL
returned by this function.  After authenticating, you will be redirected to the redirect_url you
provide.

It will look like this:

 http://REDIRECT_URL#access_token=TOKENHERE

You need to note the value of C<access_token>.

Your application will need to use that access_token in order to authenticate with Untappd.com.

B<Params>

C<redirect_url> (B<required>) - redirect to this URL after authenticating with Untappd.com.

L<https://untappd.com/api/docs/v4#authentication>

Example Usage:

 use Untappd;
 my $untappd = Untappd->new({
     client_id     => MY_CLIENT_ID,
     client_secret => MY_CLIENT_SECRET
 });
 print $untappd->oath_authenticate("http://redirect.url.tld");

Then, take the URL output above, paste it into your browser, login to Untappd, and when your browser
redirects, note the C<access_token> parameter in the URL string.

You should only have to perform this step once.  At this time, OAuth Tokens do not expire.

=back

=cut

sub oath_authenticate {
    my ($self, $redirect_url) = @_;

    die "The redirect_url parameter is required" unless $redirect_url;

    my $client_id     = $self->{client_id};
    my $client_secret = $self->{client_secret};

    return "https://untappd.com/oauth/authenticate/?client_id=$client_id&client_secret=$client_secret&response_type=token&redirect_url=$redirect_url";
}

=pod

=over 4

=item checkin_recent()

This method allows you the obtain all the friend check-in feed of the authenticated user.
This includes only beer checkin-ins from Friends. By default it will return at max 25 records.

B<Params>

C<max_id> (int, optional) - The checkin ID that you want the results to start with

C<limit> (int, optional) - The number of results to return, max of 50, default is 25

L<https://untappd.com/api/docs/v4#feed>

=back

=cut

sub checkin_recent {
    my ($self, $args) = @_;

    return $self->_call_untappd("GET", "checkin/recent", $args);
}

=pod

=over 4

=item user_checkins()

This method allows you the obtain all the check-in feed of the selected user.
By default it will return at max 25 records.

B<Params>

C<username> (optional) - The username that you wish to call the request upon. If you do not provide a username - the feed will return results from the authenticated user (if the access_token is provided)

C<max_id> (int, optional) - The checkin ID that you want the results to start with

C<limit> (int, optional) - The number of results to return, max of 50, default is 25

L<https://untappd.com/api/docs/v4#user_feed>

=back

=cut

sub user_checkins {
    my ($self, $args) = @_;

    return $self->_call_untappd("GET", "user/checkins", $args);
}

=pod

=over 4

=item thepub()

This method allows you the obtain all the public feed for Untappd. By default it will return at max 25 records.

B<Params>

C<min_id> (int, optional) - The numeric ID of the most recent check-in.

C<max_id> (int, optional) - The checkin ID that you want the results to start with

C<limit> (int, optional) - The number of results to return, max of 50, default is 25

L<https://untappd.com/api/docs/v4#thepub>

=back

=cut

sub thepub {
    my ($self, $args) = @_;

    return $self->_call_untappd("GET", "thepub", $args);
}

=pod

=over 4

=item thepub_local()

This method allows you the obtain all the public feed for Untappd. By default it will return at max 25 records.

B<Params>

C<min_id> (int, optional) - The numeric ID of the most recent check-in.

C<lng> (float, optional) - The numeric Latitude to filter the public feed.

C<lat> (float, optional) - The numeric Longitude to filter the public feed.

C<radius> (int, optional) - The max radius you would like the check-ins to start within

C<max_id> (int, optional) - The checkin ID that you want the results to start with

C<limit> (int, optional) - The number of results to return, max of 50, default is 25

L<https://untappd.com/api/docs/v4#thepublocal>

=back

=cut

sub thepub_local {
    my ($self, $args) = @_;

    return $self->_call_untappd("GET", "thepub/local", $args);
}

=pod

=over 4

=item venue_checkins()

This method allows you the obtain a feed for a single venue for Untappd. By default it will return at
 max 25 records.

B<Params>

C<venue_id> (B<required>) - The Brewery ID that you want to display checkins

C<min_id> (int, optional) - The numeric ID of the most recent check-in. New results will only be shown if there are checkins before this ID

C<max_id> (int, optional) - The checkin ID that you want the results to start with

C<limit> (int, optional) - The number of results to return, max of 50, default is 25

L<https://untappd.com/api/docs/v4#venue_checkins>

=back

=cut

sub venue_checkins {
    my ($self, $args) = @_;

    die "The venue_id parameter is required" unless $args->{venue_id};

    return $self->_call_untappd("GET", "venue/checkins/$args->{venue_id}", $args);
}

=pod

=over 4

=item beer_checkins()

This method allows you the obtain a feed for a single beer for Untappd. By default it will return at max 25 records.

B<Params>

C<bid> (B<required>) - The beer ID that you want to display checkins

C<min_id> (int, optional) - The numeric ID of the most recent check-in. This provided to you in the

C<next_query> attribute.

C<max_id> (int, optional) - The checkin ID that you want the results to start with

C<limit> (int, optional) - The number of results to return, maximum of 50, default fault is 25

L<https://untappd.com/api/docs/v4#beer_checkins>

=back

=cut

sub beer_checkins {
    my ($self, $args) = @_;

    die "The bid parameter is required" unless $args->{bid};

    return $self->_call_untappd("GET", "beer/checkins/$args->{bid}", $args);
}

=pod

=over 4

=item brewery_checkins()

This method allows you the obtain a feed for a single brewery for Untappd. This includes only beer
checkin-ins non private users by an authenticated user. By default it will return at max 25 records.

B<Params>

C<brewery_id> (B<required>) - The Brewery ID that you want to display checkins

C<min_id> (int, optional) - The numeric ID of the most recent check-in. New results will only be shown if
 there are checkins before this ID

C<max_id> (int, optional) - The checkin ID that you want the results to start with

C<limit> (int, optional) - The number of results to return, max of 50, default is 25

L<https://untappd.com/api/docs/v4#brewery_checkins>

=back

=cut

sub brewery_checkins {
    my ($self, $args) = @_;

    die "The brewery_id parameter is required" unless $args->{brewery_id};

    return $self->_call_untappd("GET", "brewery/checkins/$args->{brewery_id}", $args);
}

=pod

=over 4

=item brewery_info()

This method will allow you to see extended information about a brewery.

B<Params>

C<brewery_id> (B<required>) - The Brewery ID that you want to display information

L<https://untappd.com/api/docs/v4#brewery_info>

=back

=cut

sub brewery_info {
    my ($self, $args) = @_;

    die "The brewery_id parameter is required" unless $args->{brewery_id};

    return $self->_call_untappd("GET", "brewery/info/$args->{brewery_id}", $args);
}

=pod

=over 4

=item beer_info()

This method will allow you to see extended information about a beer.

B<Params>

C<bid> (B<required>) - The Beer ID that you want to display information

L<https://untappd.com/api/docs/v4#beer_info>

=back

=cut

sub beer_info {
    my ($self, $args) = @_;

    die "The bid parameter is required" unless $args->{bid};

    return $self->_call_untappd("GET", "beer/info/$args->{bid}", $args);
}

=pod

=over 4

=item venue_info()

This method will allow you to see extended information about a venue.

B<Params>

C<venue_id> (B<required>) - The Venue ID that you want to display information

L<https://untappd.com/api/docs/v4#venue_info>

=back

=cut

sub venue_info {
    my ($self, $args) = @_;

    die "The venue_id parameter is required" unless $args->{venue_id};

    return $self->_call_untappd("GET", "venue/info/$args->{venue_id}", $args);
}

=pod

=over 4

=item checkin_view()

This method will allow you to see extended details for a particular checkin, which includes location,
comments and toasts.

B<Params>

C<checkin_id> (B<required>) - The Checkin ID that you want to display information

L<https://untappd.com/api/docs/v4#details>

=back

=cut

sub checkin_view {
    my ($self, $args) = @_;

    die "The checkin_id parameter is required" unless $args->{checkin_id};

    return $self->_call_untappd("GET", "checkin/view/$args->{checkin_id}");
}

=pod

=over 4

=item user_info()

This method will return the user information for a selected user. If you want to obtain the
authenticated user's information, you don't need to pass the "user" query string.
Please note: The settings attribute will only be visible if the user that you are making the call on is
authenticated. Unauthenticated calls do not return this attribtue.

B<Params>

C<username> (B<required>) - The Username that you want to display information

L<https://untappd.com/api/docs/v4#user_info>

=back

=cut

sub user_info {
    my ($self, $args) = @_;

    die "The username parameter is required" unless $args->{username};

    return $self->_call_untappd("GET", "user/info/$args->{username}");
}

=pod

=over 4

=item user_badges()

This method will return a list of the last 50 the user's earned badges. If you want to obtain the
authenticated user's information, you don't need to pass the "USERNAME" parameter.

B<Params>

C<username> (B<required>) - The Username that you want to display information
C<offset> (int, optional) - The numeric offset that you what results to start

L<https://untappd.com/api/docs/v4#badges>

=back

=cut

sub user_badges {
    my ($self, $args) = @_;

    die "The username parameter is required" unless $args->{username};

    return $self->_call_untappd("GET", "user/badges/$args->{username}", $args);
}

=pod

=over 4

=item user_friends()

This method will return the last 25 friends for a selected. If you want to obtain the authenticated
user's information, you don't need to pass the C<username> parameter

B<Params>

C<username> (B<required>) - The Username that you want to display information

C<offset> (int, optional) - The numeric offset that you what results to start

C<limit> (optional) - The number of records that you will return (max 50)

L<https://untappd.com/api/docs/v4#friends>

=back

=cut

sub user_friends {
    my ($self, $args) = @_;

    die "The username parameter is required" unless $args->{username};

    return $self->_call_untappd("GET", "user/friends/$args->{username}", $args);
}

=pod

=over 4

=item user_wishlist()

This method will allow you to see all the user's wish listed beers.

B<Params>

C<username> (B<required>) - The Username that you want to display information

C<offset> (int, optional) - The numeric offset that you what results to start

L<https://untappd.com/api/docs/v4#wish_list>

=back

=cut

sub user_wishlist {
    my ($self, $args) = @_;

    die "The username parameter is required" unless $args->{username};

    return $self->_call_untappd("GET", "user/wishlist/$args->{username}", $args);
}

=pod

=over 4

=item user_beers()

This method will allow you to see all the user's distinct beers.

B<Params>

C<username> (B<required>) - The Username that you want to display information

C<sort> (string, optional) - Your can sort the results using these values:

=over 4

=item Sort Params

C<date> - sorts by date (default),

C<checkin> - sorted by highest checkin

C<highest_rated> - sorts by global rating descending order,

C<lowest_rated> - sorts by global rating ascending order

C<highest_rated_you> - the user's highest rated beer

C<lowest_rated_you> - the user's lowest rated beer

=back

C<offset> (int, optional) - The numeric offset that you what results to start

L<https://untappd.com/api/docs/v4#user_distinct>

=back

=cut

sub user_beers {
    my ($self, $args) = @_;

    die "The username parameter is required" unless $args->{username};

    return $self->_call_untappd("GET", "user/beers/$args->{username}", $args);
}

=pod

=over 4

=item search_brewery()

This method will allow you to see all to search the Untappd database of breweries.

B<Params>

C<q> (B<required>) - The search term that you want to search.

L<https://untappd.com/api/docs/v4#brewery_search>

=back

=cut

sub search_brewery {
    my ($self, $args) = @_;

    die "The q parameter is required" unless $args->{q};

    return $self->_call_untappd("GET", "search/brewery", $args);
}

=pod

=over 4

=item search_beer()

This method will allow you to see all to search the Untappd database of beers.

B<Params>

C<q> (B<required>) - The search term that you want to search.

C<sort> (optional): C<count> or C<name> (default) - This can let you choose if you want the results to be
returned in Alphabetical order (name) or by checkin count (count). By default the search returns all
values in Alphabetical order.

L<https://untappd.com/api/docs/v4#beer_search>

=back

=cut

sub search_beer {
    my ($self, $args) = @_;

    die "The q parameter is required" unless $args->{q};

    return $self->_call_untappd("GET", "search/beer", $args);
}

=pod

=over 4

=item trending()

This method will allow you see trending beers (macro and micro) globally.

L<https://untappd.com/api/docs/v4#trending>

=back

=cut

sub trending {
    my ($self) = @_;

    return $self->_call_untappd("GET", "trending");
}

=pod

=over 4

=item checkin_add()

This will allow you to perform a live checkin.

B<Params>

C<gmt_offset> (B<required>) - The numeric value of hours the user is away from the GMT (Greenwich Mean Time)

C<timezone> (B<required>) - The timezone of the user, such as EST or PST.

C<bid> (B<required>) - The numeric Beer ID you want to check into.

C<foursquare_id> (optional) - The MD5 hash ID of the Venue you want to attach the beer checkin. This HAS TO
BE the MD5 non-numeric hash from the foursquare v2.

C<geolat> (optional) - The numeric Latitude of the user. This is required if you add a location.

C<geolng> (optional) - The numeric Longitude of the user. This is required if you add a location.

C<shout> (optional) - The text you would like to include as a comment of the checkin. Max of 140 characters.

C<rating> (optional) - The rating score you would like to add for the beer. This can only be 1 to 5 and
whole numbers (no 4.2)

C<facebook> (optional) - Default = "off", Pass "on" to post to facebook

C<twitter> (optional) - Default = "off", Pass "on" to post to twitter

C<foursquare> (optional) - Default = "off", Pass "on" to checkin on foursquare

L<https://untappd.com/api/docs/v4#checkin>

=back

=cut

sub checkin_add {
    my ($self, $args) = @_;

    die "The gmt_offset parameter is required"  unless $args->{gmt_offset};
    die "The timezone parameter is required"    unless $args->{timezone};
    die "The bid parameter is required"         unless $args->{bid};

    return $self->_call_untappd("POST", "checkin/add", $args);
}

=pod

=over 4

=item checkin_addcomment()

This method will allow you comment on a checkin.

B<Params>

C<checkin_id> (B<required>) - The checkin ID you wish you toast.

C<comment> (B<required>) - The comment text that you would like to add. It must be less than 140
characters

L<https://untappd.com/api/docs/v4#add_comment>

=back

=cut

sub checkin_addcomment {
    my ($self, $args) = @_;

    die "The checkin_id parameter is required" unless $args->{checkin_id};
    die "The comment parameter is required" unless $args->{comment};

    return $self->_call_untappd("POST", "checkin/addcomment/$args->{checkin_id}", $args);
}

=pod

=over 4

=item checkin_deletecomment()

This method will allow you to delete your comment on a checkin.

B<Params>

C<comment_id> (B<required>) - The comment ID you wish to delete.

L<https://untappd.com/api/docs/v4#delete_comment>

=back

=cut

sub deletecomment {
    my ($self, $args) = @_;

    die "The comment_id parameter is required" unless $args->{comment_id};

    return $self->_call_untappd("POST", "checkin/deletecomment/$args->{comment_id}");
}

=pod

=over 4

=item checkin_toast()

This method will allow you to toast a checkin. Please note, if the user has already toasted this
check-in, it will delete the toast.

B<Params>

C<checkin_id> (B<required>) - The checkin ID you wish you toast.

L<https://untappd.com/api/docs/v4#toast>

=back

=cut

sub checkin_toast {
    my ($self, $args) = @_;

    die "The checkin_id parameter is required" unless $args->{checkin_id};

    return $self->_call_untappd("GET", "checkin/toast/$args->{checkin_id}");
}

=pod

=over 4

=item wishlist_add()

This method will allow you to add a beer to your wish list

B<Params>

C<bid> (B<required>) - The numeric beer ID that you wish to add to your wishlist.

L<https://untappd.com/api/docs/v4#add_to_wish>

=back

=cut

sub wishlist_add {
    my ($self, $args) = @_;

    die "The bid parameter is required" unless $args->{bid};

    return $self->_call_untappd("GET", "user/wishlist/add", $args);
}

=pod

=over 4

=item wishlist_remove()

This method will allow you to remove a beer from your wish list

B<Params>

C<bid> (B<required>) - The numeric beer ID that you wish to remove from your wishlist.

<https://untappd.com/api/docs/v4#remove_from_wish>

=back

=cut

sub wishlist_remove {
    my ($self, $args) = @_;

    die "The bid parameter is required" unless $args->{bid};

    return $self->_call_untappd("GET", "user/wishlist/remove", $args);
}

=pod

=over 4

=item friend_pending()

This will allow you to return your pending friends requests

L<https://untappd.com/api/docs/v4#friend_pending>

=back

=cut

sub friend_pending {
    my ($self) = @_;

    return $self->_call_untappd("GET", "user/pending");
}

=pod

=over 4

=item friend_accept()

This will allow you to accept a pending friend request

B<Params>

C<target_id> (B<required>) - The target user id that you wish to accept.

L<https://untappd.com/api/docs/v4#friend_accept>

=back

=cut

sub friend_accept {
    my ($self, $args) = @_;

    die "The target_id parameter is required" unless $args->{target_id};

    return $self->_call_untappd("POST", "friend/accept/$args->{target_id}");
}

=pod

=over 4

=item friend_reject()

This will allow you to return you to ignore a pending friend request

B<Params>

C<target_id> (B<required>) - The target user id that you wish to reject/ignore.

L<https://untappd.com/api/docs/v4#friend_reject>

=back

=cut

sub friend_reject {
    my ($self, $args) = @_;

    die "The target_id parameter is required" unless $args->{target_id};

    return $self->_call_untappd("POST", "friend/reject/$args->{target_id}");
}

=pod

=over 4

=item friend_remove()

This will allow you to return you to revoke a current friendship

B<Params>

C<target_id> (B<required>) - The target user id that you wish to remove/revoke.

L<https://untappd.com/api/docs/v4#friend_revoke>

=back

=cut

sub friend_remove {
    my ($self, $args) = @_;

    die "The target_id parameter is required" unless $args->{target_id};

    return $self->_call_untappd("GET", "friend/remove/$args->{target_id}");
}

=pod

=over 4

=item friend_request()

This will allow you to request to be someone's friend on Untappd

B<Params>

C<target_id> (B<required>) - The target user id that you wish to request to be their friend.

L<https://untappd.com/api/docs/v4#friend_request>

=back

=cut

sub friend_request {
    my ($self, $args) = @_;

    die "The target_id parameter is required" unless $args->{target_id};

    return $self->_call_untappd("GET", "friend/request/$args->{target_id}");
}

=pod

=over 4

=item notifications()

This method will allow you pull in a feed of notifications (toasts and comments) on the authenticated
user. It will return the 25 items by default and pagination is not supported. It will also show the
last 25 news items in the order of created date.

L<https://untappd.com/api/docs/v4#activity_on_you>

=back

=cut

sub notifications {
    my ($self) = @_;

    return $self->_call_untappd("GET", "notifications");
}

=pod

=over 4

=item foursquare_lookup()

This method will allow you to pass in a foursquare v2 ID and return a Untappd Venue ID to be used for /v4/venue/info or /v4/venue/checkins

B<Params>

C<venue_id> (B<required>) - The foursquare venue v2 ID that you wish to translate into a Untappd

L<https://untappd.com/api/docs/v4#foursquare_lookup>

=back

=cut

sub foursquare_lookup {
    my ($self, $args) = @_;

    die "The venue_id parameter is required" unless $args->{venue_id};

    return $self->_call_untappd("GET", "venue/foursquare_lookup/$args->{venue_id}");
}



sub _call_untappd {
    my ($self, $method, $path, $args) = @_;

    $args = {
        client_id     => $self->{client_id},
        client_secret => $self->{client_secret},
        access_token  => $self->{access_token},
        %{ $args },
    };

    my $uri = URI->new("$self->{untappd_url}/$path");
    $uri->query_form($args);

    my $response;

    if ($method eq "GET") {
        $response = LWP::UserAgent->new()->get( $uri, [ ]);
    }
    elsif ($method eq "POST") {
        $response = LWP::UserAgent->new()->post( $uri, $args );
    }

    unless ($response->is_success) {
        die $response->status_line, $response->decoded_content;
    }

    my $json    = $response->decoded_content;
    my $content = decode_json($json);

    $self->{notifications} = $content->{notifications};
    $self->{meta} = $content->{meta};

    return $content->{response};
}

1;

=head1 EXAMPLES

Show recent checkins for Founders Imperial Stout

 my $checkins = $untappd->beer_checkins({ bid => 4586 });

 foreach my $checkin (@{ $checkins->{checkins}{items} }) {
     print "$checkin->{user}{first_name} at $checkin->{created_at}\n";
 }

Search for beer from Founders

 my $beers = $untappd->search_beer({ q => "founders" });

 foreach my $beer ( @{ $beers->{beers}{items} } ) {
     print "$beer->{beer}{beer_name}\n";
 }

Show extended info on Founders Kentucky Breakfast Stout

 my $beer = $untappd->beer_info({ bid => "9681" });

 print "$beer->{beer}{beer_name} by $beer->{beer}{brewery}{brewery_name} ",
       "in $beer->{beer}{brewery}{location}{brewery_city}, ",
       "$beer->{beer}{brewery}{location}{brewery_state} ",
       "rated $beer->{beer}{rating_score}\n ";

Comment on a checkin

 my $response = $untappd->checkin_addcomment({
     checkin_id => 26943020,
     comment    => "That's a fine beer!",
 });

Perform a checkin

 my $response = $untappd->checkin_add({
     gmt_offset => "-5",
     timezone   => "EST",
     bid        => 9681,
     shout      => "Yum!",
     rating     => 5,
 });

=head1 SOURCE REPOSITORY

The current source for this module is available here:

L<https://github.com/andreychek/untappd>

=head1 UNTAPPD

Untappd for Perl is not endorsed by or affiliated with Untappd.com.

Untappd.com and it's content are Copyright 10/18/10 Untappd. All Rights Reserved.

The descriptions of the above methods is taken from the Untappd.com API documentation.

Please be sure that your applications are in accordance with the Untappd.com Terms of Use:

  https://untappd.com/terms/api

=head1 AUTHOR

Eric Andreychek (eric at openthought.net)

=head1 COPYRIGHT and LICENSE

The Untappd for Perl module is Copyright (C) 2013 by Eric Andreychek.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl
itself.

