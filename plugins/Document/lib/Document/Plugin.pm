package Document::Plugin;

use strict;
use warnings;

use base qw(MT::Plugin);

use vars qw( $VERSION $OLD_VERSION $SCHEMA_VERSION );
$VERSION = '1.00';


use Data::Dumper;
use MT;
use Document::L10N;
use Document::Util qw/array_search/;

my $plugin = Document::Plugin->new({
	id => 'Document',
	key => __PACKAGE__,
	name => 'Document',
	l10n_class => 'Document::L10N',
	description => '<__trans phrase="Utility for create documents.">',
  doc_link => 'http://github.com/u-pyon/mt-plugin-Document/',
  author_name => "Yuichi Oikawa",
  author_link => 'http://github.com/u-pyon/',
	settings => new MT::PluginSettings([
	]),
	version => $VERSION,
});

sub init_registry {
	my ($plugin) = @_;
	my $cfg = MT->config;
	$plugin->registry({
    applications => {
      cms => {
        menus => {
          document => {
            label => 'Document',
            mode => 'document_list',
            order => 3000,
            view => 'system',
            permission => 'administer_blog',
          },
          'document:download' => {
            label => 'Download',
            mode => 'document_list',
            order => 100,
            view => 'system',
            permission => 'administer_blog',
          },
        },
        methods => {
          document_list => '$Document::Document::CMS::Document::list',
          download_documents => '$Document::Document::CMS::Document::download',
        }
      }
    }
	});
}

sub instance {
	$plugin;
}

sub t {
	my $plugin = shift;
	$plugin->translate(@_);
}

1;
