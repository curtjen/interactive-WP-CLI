#!perl -w
use strict;
use warnings;
use diagnostics;
use POSIX;

our $VERSION = '0.1';

my $tempfile = tmpnam();
my $wpcli = "~/bin$tempfile";

unless( -f $wpcli) {
	print "Installing wp-cli...\r\n";
	unless( -e '~/bin/tmp/' ) {
		system 'mkdir ~/bin/tmp/';
	}
	system "curl -o $wpcli https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar";
	print "done...\r\n";
}

my $pkg = bless {}, __PACKAGE__;
$pkg->main();

sub main {
	print qq(
What you would like to do?
[1] Themes
	[1a] List all themes
	[1b] Switch themes
[2] Plugins
	[2a] List all plugins
	[2b] Deactivate a plugin
	[2c] Activate a plugin
	[2d] Deactivate all plugins
[q] Quit
\$:);

	my $option = <>;
	chomp $option;
	do_option($option);
	return;
}

sub do_option {
	my $option = shift;

	if( $option eq '1' || $option eq '1a' ) {
		list_themes();
	} elsif( $option eq '1b' ) {
		switch_themes();
	} elsif( $option eq '2' || $option eq '2a' ) {
		list_plugins();
	} elsif( $option eq '2b' ) {
		deactivate_plugin();
	} elsif( $option eq '2c' ) {
		activate_plugin();
	} elsif( $option eq '2d' ) {
		deactivate_all_plugins();
	} elsif( $option eq 'q' ) {
		unlink $wpcli;
		exit;
	} else {
		print "\nPlease select an option.\n\$:";
		main();
	}
	return;
}

sub continue_program {
	print "Continue? [y/n]\n\$:";
	my $continue = <>;
	chomp $continue;
	if( $continue eq 'y' || $continue eq 'Y' || $continue eq 'yes' || $continue eq 'Yes' ) {
		main();
	} else {
		unlink $wpcli;
		print "Goodbye\n";
	}
	return;
}

sub list_themes {
	system('php-cli '. $wpcli .' theme list');
	continue_program();
	return;
}

sub switch_themes {
	system 'php-cli '. $wpcli .' theme list';
	print qq(
Please select the theme you would like to activate:
\$:);
	my $theme = <>;
	chomp $theme;
	system("php-cli $wpcli theme activate $theme");
	continue_program();
	return;
}

sub list_plugins {
	system 'php-cli '. $wpcli .' plugin list';
	continue_program();
	return;
}

sub deactivate_plugin {
	system 'php-cli '. $wpcli .' plugin list';
	print qq(
Please select the plugin you would like to deactivate
\$:);
	my $plugin = <>;
	chomp $plugin;
	system "php-cli $wpcli plugin deactivate $plugin";
	continue_program();
	return;
}

sub activate_plugin {
	system 'php-cli '. $wpcli .' plugin list';
	print qq(
Please select the plugin you would like to activate
\$:);
	my $plugin = <>;
	chomp $plugin;
	system "php-cli $wpcli plugin activate $plugin";
	continue_program();
	return;
}

sub deactivate_all_plugins {
	system 'php-cli '. $wpcli .' plugin deactivate --all';
	continue_program();
	return;
}
