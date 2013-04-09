use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Untappd',
    VERSION_FROM      => 'lib/Untappd.pm',
    PREREQ_PM         => {
                'JSON'           >= 0,
                'LWP::UserAgent' >= 0,
                'URI'            >= 0,
        },
    ($] >= 5.005 ?
      (ABSTRACT  => 'A Perl wrapper for the Untappd.com API',
       AUTHOR    => 'Eric Andreychek <eric@openthought.net>') : ()),
);

