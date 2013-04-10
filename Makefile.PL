use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Untappd',
    VERSION_FROM => 'lib/Untappd.pm',
    PREREQ_PM => {
        'LWP::UserAgent' => 0,
        'URI'            => 0,
        'JSON'           => 0,
    },
    LICENSE => 'perl',
    META_MERGE => {
        resources => {
            repository => 'https://github.com/andreychek/untappd',
        },
    },
    ABSTRACT  => 'A Perl wrapper for the Untappd.com API',
    AUTHOR    => 'Eric Andreychek <eric@openthought.net>',
);


