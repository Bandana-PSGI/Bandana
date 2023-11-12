#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build;

my $abstraction = <<DESCRIPTION;
Bandana - run PSGI application
DESCRIPTION

my %dist_info = (
    dist_version  => 0.01,
    dist_name     => 'Bandana',
    dist_author   => 'backslash001',
    dist_abstract => $abstraction,
);

my %contact_info = (
    author => 'backslash001',
    email  => 'telegin.vlad132@gmail.com',
);

my %requires = (
    configure_requires => {
        'CPAN::Meta'    => 2.150010,
        'Module::Build' => 0.42,
    },
    requires     => {
        'Devel::Cover' => 1.37,
        'Data::Dumper' => 0,
    },
    test_requires => {
        'Test::Spec'        => 0.54,
        'CPAN::Meta::YAML'  => 0.018,
        'Parse::CPAN::Meta' => 2.150010,
    },
    recommends    => {
        'ExtUtils::Install'  => 2.20,
        'ExtUtils::Manifest' => 1.73,
    },
);

my %module_info = (
    name           => 'Bandana',
    version        => 0.01,
    license        => 'perl',
    release_status => 'unstable',
    module_name    => 'Bandana',
);

my %autofeature = (
    auto_features => {
        dist_authoring => {
            description => 'Creates a new description for author',
            requires => {
                'Archive::Tar' => 2.40,
            },
            recommends => {
                'Pod::Readme'        => 'v1.2.3',
                'Module::Signature'  => 0.88,
            },
        },
        license_creation => {
            description => 'Create license automatically in distro',
            requires    => {
                'Software::License' => 0.104004,
            },
        },
        manpage_support => {
            description => "Create Unix man pages",
            requires    => {'Pod::Man' => 0 },
        },
        HTML_support => {
            description => "Create HTML documentation",
            requires    => {'Pod::Html' => 0},
        },
    }
);

my $module = Module::Build->new(
    %dist_info,
    %contact_info,
    %module_info,
    %requires,
    %autofeature,
    allow_mb_mismatch => (
        $ENV{PERL5_CPANPLUS_IS_RUNNING} && ! $ENV{PERL5_CPAN_IS_RUNNING} ? 1 : 0
    ),
    meta_merge        => {
        resources => {
            MailingList => 'mailto:telegin.vlad132@gmail.com',
            repository  => 'https://github.com/100backslash001/Bandana',
        },
    },
);

$module->create_build_script();

if ( -f 'META.yml' && ! -f 'MYMETA.yml' ) {
    require File::Copy;
    
    File::Copy::copy( 'META.yml', 'MYMETA.yml' ) or warn "Error: $!\n";

    if ( -f 'MYMETA.yml' ) {
        warn "Copied META.yml to MYMETA.yml for bootstraping\n";
    }
    else {
        warn "Could not copy META.yml to MYMETA.yml. That's odd\n";
    }
}
