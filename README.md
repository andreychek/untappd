# NAME

Untappd - a Perl wrapper for the Untappd.com API.

# SYNOPSIS

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

# DESCRIPTION

This is a library for accessing the Untappd API.

You'll first need to register for an API key, which you can do here:

[http://untappd.com/api/register](http://untappd.com/api/register)

The API that this library accesses is documented here:

[https://untappd.com/api/docs/v4](https://untappd.com/api/docs/v4)

Once you have your API key, you'll want to obtain an access\_token.  See the `oath_authenticate` function
below for instructions on how to do that.

Parameters passed to the various methods below should be passed in as a hashref.

Responses are a multi-dimensional hashref, as provided by Untappd.com.

# METHODS

- oath\_authenticate()

    Obtains OAuth authentication URL.

    Application authentication with Untappd is handled via OAuth.

    In order for most of these functions to work, you need to go login to Untappd via the OAuth URL
    returned by this function.  After authenticating, you will be redirected to the redirect\_url you
    provide.

    It will look like this:

        http://REDIRECT_URL#access_token=TOKENHERE

    You need to note the value of `access_token`.

    Your application will need to use that access\_token in order to authenticate with Untappd.com.

    __Params__

    `redirect_url` (__required__) - redirect to this URL after authenticating with Untappd.com.

    [https://untappd.com/api/docs/v4\#authentication](https://untappd.com/api/docs/v4\#authentication)

    Example Usage:

        use Untappd;
        my $untappd = Untappd->new({
            client_id     => MY_CLIENT_ID,
            client_secret => MY_CLIENT_SECRET
        });
        print $untappd->oath_authenticate("http://redirect.url.tld");

    Then, take the URL output above, paste it into your browser, login to Untappd, and when your browser
    redirects, note the `access_token` parameter in the URL string.

    You should only have to perform this step once.  At this time, OAuth Tokens do not expire.

- checkin\_recent()

    This method allows you the obtain all the friend check-in feed of the authenticated user.
    This includes only beer checkin-ins from Friends. By default it will return at max 25 records.

    __Params__

    `max_id` (int, optional) - The checkin ID that you want the results to start with

    `limit` (int, optional) - The number of results to return, max of 50, default is 25

    [https://untappd.com/api/docs/v4\#feed](https://untappd.com/api/docs/v4\#feed)

- user\_checkins()

    This method allows you the obtain all the check-in feed of the selected user.
    By default it will return at max 25 records.

    __Params__

    `username` (optional) - The username that you wish to call the request upon. If you do not provide a username - the feed will return results from the authenticated user (if the access\_token is provided)

    `max_id` (int, optional) - The checkin ID that you want the results to start with

    `limit` (int, optional) - The number of results to return, max of 50, default is 25

    [https://untappd.com/api/docs/v4\#user\_feed](https://untappd.com/api/docs/v4\#user\_feed)

- thepub()

    This method allows you the obtain all the public feed for Untappd. By default it will return at max 25 records.

    __Params__

    `min_id` (int, optional) - The numeric ID of the most recent check-in.

    `max_id` (int, optional) - The checkin ID that you want the results to start with

    `limit` (int, optional) - The number of results to return, max of 50, default is 25

    [https://untappd.com/api/docs/v4\#thepub](https://untappd.com/api/docs/v4\#thepub)

- thepub\_local()

    This method allows you the obtain all the public feed for Untappd. By default it will return at max 25 records.

    __Params__

    `min_id` (int, optional) - The numeric ID of the most recent check-in.

    `lng` (float, optional) - The numeric Latitude to filter the public feed.

    `lat` (float, optional) - The numeric Longitude to filter the public feed.

    `radius` (int, optional) - The max radius you would like the check-ins to start within

    `max_id` (int, optional) - The checkin ID that you want the results to start with

    `limit` (int, optional) - The number of results to return, max of 50, default is 25

    [https://untappd.com/api/docs/v4\#thepublocal](https://untappd.com/api/docs/v4\#thepublocal)

- venue\_checkins()

    This method allows you the obtain a feed for a single venue for Untappd. By default it will return at
     max 25 records.

    __Params__

    `venue_id` (__required__) - The Brewery ID that you want to display checkins

    `min_id` (int, optional) - The numeric ID of the most recent check-in. New results will only be shown if there are checkins before this ID

    `max_id` (int, optional) - The checkin ID that you want the results to start with

    `limit` (int, optional) - The number of results to return, max of 50, default is 25

    [https://untappd.com/api/docs/v4\#venue\_checkins](https://untappd.com/api/docs/v4\#venue\_checkins)

- beer\_checkins()

    This method allows you the obtain a feed for a single beer for Untappd. By default it will return at max 25 records.

    __Params__

    `bid` (__required__) - The beer ID that you want to display checkins

    `min_id` (int, optional) - The numeric ID of the most recent check-in. This provided to you in the

    `next_query` attribute.

    `max_id` (int, optional) - The checkin ID that you want the results to start with

    `limit` (int, optional) - The number of results to return, maximum of 50, default fault is 25

    [https://untappd.com/api/docs/v4\#beer\_checkins](https://untappd.com/api/docs/v4\#beer\_checkins)

- brewery\_checkins()

    This method allows you the obtain a feed for a single brewery for Untappd. This includes only beer
    checkin-ins non private users by an authenticated user. By default it will return at max 25 records.

    __Params__

    `brewery_id` (__required__) - The Brewery ID that you want to display checkins

    `min_id` (int, optional) - The numeric ID of the most recent check-in. New results will only be shown if
     there are checkins before this ID

    `max_id` (int, optional) - The checkin ID that you want the results to start with

    `limit` (int, optional) - The number of results to return, max of 50, default is 25

    [https://untappd.com/api/docs/v4\#brewery\_checkins](https://untappd.com/api/docs/v4\#brewery\_checkins)

- brewery\_info()

    This method will allow you to see extended information about a brewery.

    __Params__

    `brewery_id` (__required__) - The Brewery ID that you want to display information

    [https://untappd.com/api/docs/v4\#brewery\_info](https://untappd.com/api/docs/v4\#brewery\_info)

- beer\_info()

    This method will allow you to see extended information about a beer.

    __Params__

    `bid` (__required__) - The Beer ID that you want to display information

    [https://untappd.com/api/docs/v4\#beer\_info](https://untappd.com/api/docs/v4\#beer\_info)

- venue\_info()

    This method will allow you to see extended information about a venue.

    __Params__

    `venue_id` (__required__) - The Venue ID that you want to display information

    [https://untappd.com/api/docs/v4\#venue\_info](https://untappd.com/api/docs/v4\#venue\_info)

- checkin\_view()

    This method will allow you to see extended details for a particular checkin, which includes location,
    comments and toasts.

    __Params__

    `checkin_id` (__required__) - The Checkin ID that you want to display information

    [https://untappd.com/api/docs/v4\#details](https://untappd.com/api/docs/v4\#details)

- user\_info()

    This method will return the user information for a selected user. If you want to obtain the
    authenticated user's information, you don't need to pass the "user" query string.
    Please note: The settings attribute will only be visible if the user that you are making the call on is
    authenticated. Unauthenticated calls do not return this attribtue.

    __Params__

    `username` (__required__) - The Username that you want to display information

    [https://untappd.com/api/docs/v4\#user\_info](https://untappd.com/api/docs/v4\#user\_info)

- user\_badges()

    This method will return a list of the last 50 the user's earned badges. If you want to obtain the
    authenticated user's information, you don't need to pass the "USERNAME" parameter.

    __Params__

    `username` (__required__) - The Username that you want to display information
    `offset` (int, optional) - The numeric offset that you what results to start

    [https://untappd.com/api/docs/v4\#badges](https://untappd.com/api/docs/v4\#badges)

- user\_friends()

    This method will return the last 25 friends for a selected. If you want to obtain the authenticated
    user's information, you don't need to pass the `username` parameter

    __Params__

    `username` (__required__) - The Username that you want to display information

    `offset` (int, optional) - The numeric offset that you what results to start

    `limit` (optional) - The number of records that you will return (max 50)

    [https://untappd.com/api/docs/v4\#friends](https://untappd.com/api/docs/v4\#friends)

- user\_wishlist()

    This method will allow you to see all the user's wish listed beers.

    __Params__

    `username` (__required__) - The Username that you want to display information

    `offset` (int, optional) - The numeric offset that you what results to start

    [https://untappd.com/api/docs/v4\#wish\_list](https://untappd.com/api/docs/v4\#wish\_list)

- user\_beers()

    This method will allow you to see all the user's distinct beers.

    __Params__

    `username` (__required__) - The Username that you want to display information

    `sort` (string, optional) - Your can sort the results using these values:

    - Sort Params

        `date` - sorts by date (default),

        `checkin` - sorted by highest checkin

        `highest_rated` - sorts by global rating descending order,

        `lowest_rated` - sorts by global rating ascending order

        `highest_rated_you` - the user's highest rated beer

        `lowest_rated_you` - the user's lowest rated beer

    `offset` (int, optional) - The numeric offset that you what results to start

    [https://untappd.com/api/docs/v4\#user\_distinct](https://untappd.com/api/docs/v4\#user\_distinct)

- search\_brewery()

    This method will allow you to see all to search the Untappd database of breweries.

    __Params__

    `q` (__required__) - The search term that you want to search.

    [https://untappd.com/api/docs/v4\#brewery\_search](https://untappd.com/api/docs/v4\#brewery\_search)

- search\_beer()

    This method will allow you to see all to search the Untappd database of beers.

    __Params__

    `q` (__required__) - The search term that you want to search.

    `sort` (optional): `count` or `name` (default) - This can let you choose if you want the results to be
    returned in Alphabetical order (name) or by checkin count (count). By default the search returns all
    values in Alphabetical order.

    [https://untappd.com/api/docs/v4\#beer\_search](https://untappd.com/api/docs/v4\#beer\_search)

- trending()

    This method will allow you see trending beers (macro and micro) globally.

    [https://untappd.com/api/docs/v4\#trending](https://untappd.com/api/docs/v4\#trending)

- checkin\_add()

    This will allow you to perform a live checkin.

    __Params__

    `gmt_offset` (__required__) - The numeric value of hours the user is away from the GMT (Greenwich Mean Time)

    `timezone` (__required__) - The timezone of the user, such as EST or PST.

    `bid` (__required__) - The numeric Beer ID you want to check into.

    `foursquare_id` (optional) - The MD5 hash ID of the Venue you want to attach the beer checkin. This HAS TO
    BE the MD5 non-numeric hash from the foursquare v2.

    `geolat` (optional) - The numeric Latitude of the user. This is required if you add a location.

    `geolng` (optional) - The numeric Longitude of the user. This is required if you add a location.

    `shout` (optional) - The text you would like to include as a comment of the checkin. Max of 140 characters.

    `rating` (optional) - The rating score you would like to add for the beer. This can only be 1 to 5 and
    whole numbers (no 4.2)

    `facebook` (optional) - Default = "off", Pass "on" to post to facebook

    `twitter` (optional) - Default = "off", Pass "on" to post to twitter

    `foursquare` (optional) - Default = "off", Pass "on" to checkin on foursquare

    [https://untappd.com/api/docs/v4\#checkin](https://untappd.com/api/docs/v4\#checkin)

- checkin\_addcomment()

    This method will allow you comment on a checkin.

    __Params__

    `checkin_id` (__required__) - The checkin ID you wish you toast.

    `comment` (__required__) - The comment text that you would like to add. It must be less than 140
    characters

    [https://untappd.com/api/docs/v4\#add\_comment](https://untappd.com/api/docs/v4\#add\_comment)

- checkin\_deletecomment()

    This method will allow you to delete your comment on a checkin.

    __Params__

    `comment_id` (__required__) - The comment ID you wish to delete.

    [https://untappd.com/api/docs/v4\#delete\_comment](https://untappd.com/api/docs/v4\#delete\_comment)

- checkin\_toast()

    This method will allow you to toast a checkin. Please note, if the user has already toasted this
    check-in, it will delete the toast.

    __Params__

    `checkin_id` (__required__) - The checkin ID you wish you toast.

    [https://untappd.com/api/docs/v4\#toast](https://untappd.com/api/docs/v4\#toast)

- wishlist\_add()

    This method will allow you to add a beer to your wish list

    __Params__

    `bid` (__required__) - The numeric beer ID that you wish to add to your wishlist.

    [https://untappd.com/api/docs/v4\#add\_to\_wish](https://untappd.com/api/docs/v4\#add\_to\_wish)

- wishlist\_remove()

    This method will allow you to remove a beer from your wish list

    __Params__

    `bid` (__required__) - The numeric beer ID that you wish to remove from your wishlist.

    <https://untappd.com/api/docs/v4\#remove\_from\_wish>

- friend\_pending()

    This will allow you to return your pending friends requests

    [https://untappd.com/api/docs/v4\#friend\_pending](https://untappd.com/api/docs/v4\#friend\_pending)

- friend\_accept()

    This will allow you to accept a pending friend request

    __Params__

    `target_id` (__required__) - The target user id that you wish to accept.

    [https://untappd.com/api/docs/v4\#friend\_accept](https://untappd.com/api/docs/v4\#friend\_accept)

- friend\_reject()

    This will allow you to return you to ignore a pending friend request

    __Params__

    `target_id` (__required__) - The target user id that you wish to reject/ignore.

    [https://untappd.com/api/docs/v4\#friend\_reject](https://untappd.com/api/docs/v4\#friend\_reject)

- friend\_remove()

    This will allow you to return you to revoke a current friendship

    __Params__

    `target_id` (__required__) - The target user id that you wish to remove/revoke.

    [https://untappd.com/api/docs/v4\#friend\_revoke](https://untappd.com/api/docs/v4\#friend\_revoke)

- friend\_request()

    This will allow you to request to be someone's friend on Untappd

    __Params__

    `target_id` (__required__) - The target user id that you wish to request to be their friend.

    [https://untappd.com/api/docs/v4\#friend\_request](https://untappd.com/api/docs/v4\#friend\_request)

- notifications()

    This method will allow you pull in a feed of notifications (toasts and comments) on the authenticated
    user. It will return the 25 items by default and pagination is not supported. It will also show the
    last 25 news items in the order of created date.

    [https://untappd.com/api/docs/v4\#activity\_on\_you](https://untappd.com/api/docs/v4\#activity\_on\_you)

- foursquare\_lookup()

    This method will allow you to pass in a foursquare v2 ID and return a Untappd Venue ID to be used for /v4/venue/info or /v4/venue/checkins

    __Params__

    `venue_id` (__required__) - The foursquare venue v2 ID that you wish to translate into a Untappd

    [https://untappd.com/api/docs/v4\#foursquare\_lookup](https://untappd.com/api/docs/v4\#foursquare\_lookup)

# EXAMPLES

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

# SOURCE REPOSITORY

The current source for this module is available here:

[https://github.com/andreychek/untappd](https://github.com/andreychek/untappd)

# UNTAPPD

Untappd for Perl is not endorsed by or affiliated with Untappd.com.

Untappd.com and it's content are Copyright 10/18/10 Untappd. All Rights Reserved.

The descriptions of the above methods is taken from the Untappd.com API documentation.

Please be sure that your applications are in accordance with the Untappd.com Terms of Use:

    https://untappd.com/terms/api

# AUTHOR

Eric Andreychek (eric at openthought.net)

# COPYRIGHT and LICENSE

The Untappd for Perl module is Copyright (C) 2013 by Eric Andreychek.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl
itself.
