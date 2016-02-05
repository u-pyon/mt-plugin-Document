package Document::CMS::Document;

use strict;
use Data::Dumper;
use MT::Util qw( offset_time_list );
use Time::Local qw( timegm );
use Document::Util qw(array_search);
use Encode;

sub list {
  my $app = shift;
  my %params = $app->param_hash();

  return $app->return_to_dashboard( redirect => 1 )
    unless $app->can_do( 'blog_administer' );

  my $tmpl = 'cms/document_list.tmpl';
  return $app->build_page($tmpl, \%params);
}

sub download {
  my $app = shift;
  my $q = $app->param;

  return $app->return_to_dashboard( redirect => 1 )
    unless $app->can_do( 'blog_administer' );

  my $plugin = $app->component('Document');
  my $site_iter = MT::Website->load_iter();
  if ( $q->param('template_list') ) {
    my $line = '';
    my $tmpl_list_name = $plugin->t('[_1]_TemplateList.csv', today());
    send_header($tmpl_list_name);
    send_csv_header();
    # global templates
    my $global_iter = MT::Template->load_iter({blog_id => 0}, {sort_by => 'type', order => 'descend'});
    my %tmpls = ();
    while ( my $tmpl = $global_iter->() ) {
      my $tmpl_type = $tmpl->type;
      next if array_search($tmpl_type, &invisible_templates());
      $tmpl_type = &check_type($tmpl_type);
      next if $q->param('no_system') && $tmpl_type eq 'system';
      next if $q->param('no_widget') && $tmpl_type =~ /widget/;
      my $line = join(',', (0, $plugin->translate('System'), '', '', $tmpl->id, $tmpl->name, $tmpl_type, $tmpl->outfile, $tmpl->identifier, $tmpl->linked_file));
      $tmpls{$tmpl_type} = [] unless defined $tmpls{$tmpl_type};
      push @{$tmpls{$tmpl_type}}, $line;
    }
    &print_each_type_lines(\%tmpls);
    my @site_pre_columns = ();
    while ( my $site = $site_iter->() ) {
      @site_pre_columns = ($site->id, $site->name);
      my $blog_iter = $app->model('blog')->load_iter({parent_id => $site->id}, { sort_by => 'id', order => 'ascend'});
      my @blog_pre_columns = ();
      while ( my $blog = $blog_iter->() ) {
        @blog_pre_columns = ($blog->id, $blog->name);
        my $tmpl_iter = MT::Template->load_iter({blog_id => $blog->id},{sort_by => 'type', order => 'descend'});
        my @tmpl_pre_columns = ();
        my %tmpls = ();
        while ( my $tmpl = $tmpl_iter->() ) {
          my $tmpl_type = $tmpl->type;
          next if array_search($tmpl_type, &invisible_templates());
          $tmpl_type = &check_type($tmpl_type);
          next if $q->param('no_system') && $tmpl_type eq 'system';
          next if $q->param('no_widget') && $tmpl_type =~ /widget/;
          @tmpl_pre_columns = ($tmpl->id, $tmpl->name, $tmpl_type);
          my @line_head = (@site_pre_columns, @blog_pre_columns, @tmpl_pre_columns);
          my @line = (@line_head, $tmpl->outfile, $tmpl->identifier, $tmpl->linked_file);
          $tmpls{$tmpl_type} = [] unless defined $tmpls{$tmpl_type};

          unless ( $tmpl->type eq 'individual' || $tmpl->type eq 'archive' ) {
            my $line = join(',', @line);
            push @{$tmpls{$tmpl_type}}, $line;
            next;
          }
          my @lines = ();
          my $map_iter = MT::TemplateMap->load_iter({template_id => $tmpl->id},{sort_by => 'id', order => 'descend'});
          my $i = 0;
          while ( my $map = $map_iter->() ) {
            if ( $i++ == 0 ) {
              $line[7] = $map->file_template;
              push @lines, join(',', @line, $map->archive_type,);
            } else {
              push @lines, join(',', (@line_head, $map->file_template, '','', $map->archive_type));
            }
          }
          next unless @lines;
          my $line = join("\r\n", @lines);
          push @{$tmpls{$tmpl_type}}, $line;
        }
        &print_each_type_lines(\%tmpls);
      }
    }
  }
  exit(1);
}

sub send_header {
  my $filename = shift;
  print "Content-Type: text/csv\n";
  print "Content-Disposition: attachment; filename=$filename\n\n";
}

sub send_csv_header {
  print join(',', qw(website_id website_name blog_id blog_name template_id template_name type outfile/map identifier linked_file archive_type)) ."\r\n";
}

sub redirect {
  my $app = shift;
  my $mode = shift;
  my %args = @_;
  return $app->redirect(
    $app->uri(mode => $mode, args => \%args));
}

sub today {
  my ( $sc, $mn, $hr, $dy, $mo, $yr );
  my $ts = Time::Local::timegm_nocheck( $sc, $mn, $hr, $dy, $mo - 1, $yr );
  ( $sc, $mn, $hr, $dy, $mo, $yr )
      = offset_time_list( $ts, undef, '-' );
  $yr += 1900;
  $mo += 1;
  sprintf( "%04d%02d%02d%02d%02d%02d",
      $yr, $mo, $dy, $hr, $mn, $sc );
}

sub invisible_templates {
  qw(comment_listing);
}

sub check_type {
  my $tmpl_type = shift;
  # global system templates
  if ( array_search($tmpl_type, qw(profile_error register_form new_password login_form profile_edit_form profile_view new_password_reset_form register_confirmation profile_feed) ) ) {
      $tmpl_type = 'system';
  }
  # website or blog
  if ( array_search($tmpl_type, qw(comment_preview search_results popup_image comment_response dynamic_error comment_listing) ) ) {
      $tmpl_type = 'system';
  }
  $tmpl_type;
}
sub print_each_type_lines {
  my $tmpls = shift;
  die "Invalid args 1. Args should be hash reference." unless ref($tmpls) eq 'HASH';
  for my $tmpl_type ( sort keys %$tmpls ) {
    my $line = join("\r\n", @{$tmpls->{$tmpl_type}});
    print MT::I18N::encode_text($line."\r\n", 'utf-8', 'sjis');
  }
}
1;
