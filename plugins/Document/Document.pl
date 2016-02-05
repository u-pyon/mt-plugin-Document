package MT::Plugin::Document;

use strict;
use warnings;

use MT;
use Document::Plugin;

MT->add_plugin( Document::Plugin->instance() );

1;
